import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/constants/firebase_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import '../models/wallet_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await ensureUserInitialized(credential.user!);
        await _handlePostLogin(credential.user);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Login gagal', e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _initializeUserAndWallet(credential.user!, name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Registrasi gagal', e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await ensureUserInitialized(
          userCredential.user!,
          googleUser.displayName,
        );
        await _handlePostLogin(userCredential.user);
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'Google Sign-In gagal', e.code);
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_failed' || e.toString().contains('ApiException: 10')) {
        throw AppException(
            'Konfigurasi Google Sign-In gagal (SHA-1 fingerprint belum didaftarkan di Firebase Console).');
      }
      throw AppException(e.message ?? 'Google Sign-In gagal', e.code);
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw AppException(e.toString());
    }
  }

  Future<void> ensureUserInitialized(User authUser, [String? name]) async {
    try {
      final userDoc = await _firestore
          .collection(FirebaseConstants.users)
          .doc(authUser.uid)
          .get();
      if (!userDoc.exists) {
        final displayName = name ??
            authUser.displayName ??
            authUser.email?.split('@')[0] ??
            'User';
        await _initializeUserAndWallet(authUser, displayName);
      }
    } catch (e) {
      print('Gagal inisialisasi user di Firestore: $e');
    }
  }

  Future<void> _initializeUserAndWallet(User authUser, String name) async {
    final uid = authUser.uid;
    final email = authUser.email ?? '';
    final photoUrl = authUser.photoURL;

    final walletRef = _firestore.collection(FirebaseConstants.wallets).doc();
    final newWalletId = walletRef.id;
    final now = DateTime.now();

    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      personalWalletId: newWalletId,
      activeWalletId: newWalletId,
      createdAt: now,
      updatedAt: now,
    );

    final walletModel = WalletModel(
      walletId: newWalletId,
      name: 'Tabungan $name',
      ownerId: uid,
      memberIds: [uid],
      maxMembers: 5,
      createdAt: now,
      updatedAt: now,
    );

    final memberModel = MemberModel(
      uid: uid,
      name: name,
      email: email,
      photoUrl: photoUrl,
      role: 'owner',
      joinedAt: now,
    );

    final batch = _firestore.batch();

    // 1. User doc
    batch.set(
      _firestore.collection(FirebaseConstants.users).doc(uid),
      userModel.toJson(),
    );

    // 2. Wallet doc
    batch.set(walletRef, walletModel.toJson());

    // 3. Member doc in wallet
    batch.set(
      walletRef.collection(FirebaseConstants.members).doc(uid),
      memberModel.toJson(),
    );

    await batch.commit();
  }

  Future<void> _handlePostLogin(User? authUser) async {
    if (authUser == null) return;
    await ensureUserInitialized(authUser);
    final uid = authUser.uid;
    final userDocRef = _firestore.collection(FirebaseConstants.users).doc(uid);
    final userDoc = await userDocRef.get();

    if (!userDoc.exists) return;
    final user = UserModel.fromJson(userDoc.data()!);

    if (user.activeWalletId != user.personalWalletId) {
      final memberDoc = await _firestore
          .collection(FirebaseConstants.wallets)
          .doc(user.activeWalletId)
          .collection(FirebaseConstants.members)
          .doc(uid)
          .get();

      if (!memberDoc.exists) {
        await userDocRef.update({
          'activeWalletId': user.personalWalletId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      // Check pending invitations
      final invQuery = await _firestore
          .collection(FirebaseConstants.invitations)
          .where('invitedEmail', isEqualTo: user.email)
          .where('status', isEqualTo: 'pending')
          .get();

      if (invQuery.docs.isNotEmpty) {
        final invDoc = invQuery.docs.first;
        final invData = invDoc.data();
        final walletId = invData['walletId'] as String;
        final now = DateTime.now();

        final batch = _firestore.batch();
        // Update invitation status
        batch.update(
            invDoc.reference, {'status': 'accepted', 'invitedUid': uid});

        // Add to wallet memberIds
        final walletRef =
            _firestore.collection(FirebaseConstants.wallets).doc(walletId);
        batch.update(walletRef, {
          'memberIds': FieldValue.arrayUnion([uid]),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create member doc in wallet
        final memberModel = MemberModel(
          uid: uid,
          name: user.name,
          email: user.email,
          photoUrl: user.photoUrl,
          role: 'member',
          joinedAt: now,
        );
        batch.set(
          walletRef.collection(FirebaseConstants.members).doc(uid),
          memberModel.toJson(),
        );

        // Update activeWalletId
        batch.update(userDocRef, {
          'activeWalletId': walletId,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        await batch.commit();
      }
    }
  }
}
