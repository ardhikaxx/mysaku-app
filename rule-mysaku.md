# rule-mysaku.md
# MySAKU — My Smart Saving & Cashflow Utility
# Blueprint Arsitektur Aplikasi Mobile
# Versi: 1.0.0 | Flutter + Firebase | Collaborative Personal Finance Management

---

## 1. IDENTITAS PROYEK

| Atribut         | Detail                                                              |
|-----------------|---------------------------------------------------------------------|
| Nama Aplikasi   | MySAKU — My Smart Saving & Cashflow Utility                        |
| Versi           | 1.0.0                                                               |
| Platform        | Flutter (Android & iOS)                                             |
| Backend         | Firebase (Authentication, Cloud Firestore, Cloud Storage)          |
| State Management| Riverpod                                                            |
| Navigasi        | go_router                                                           |
| Bahasa Kode     | Dart                                                                |
| Bahasa UI       | Bahasa Indonesia                                                    |
| Konsep Utama    | Collaborative Personal Finance Management (Wallet-Centric)         |

---

## 2. KONSEP INTI & FILOSOFI ARSITEKTUR

### 2.1 Prinsip Wallet-Centric

MySAKU bukan aplikasi pencatatan keuangan pribadi biasa. Inti dari sistem ini adalah entitas **Wallet** sebagai pusat seluruh data keuangan. Tidak ada data transaksi, saldo, maupun impian yang melekat langsung pada akun pengguna (User). Semua data keuangan melekat pada sebuah **Wallet**. Akun pengguna hanya memiliki **hak akses** terhadap wallet.

```
USER  ──(owns)──►  WALLET PRIBADI
USER  ──(member)►  WALLET ORANG LAIN  (opsional, maks. 1 wallet aktif)
WALLET ──────────► TRANSACTIONS (subcollection)
WALLET ──────────► DREAMS       (subcollection)
WALLET ──────────► MEMBERS      (subcollection)
```

### 2.2 Pemisahan Identitas dan Kepemilikan Data

| Entitas        | Tanggung Jawab                                                          |
|----------------|-------------------------------------------------------------------------|
| `users`        | Menyimpan identitas: nama, email, foto, activeWalletId, personalWalletId|
| `wallets`      | Menyimpan data keuangan: saldo agregat, owner, daftar member            |
| `transactions` | Subcollection di bawah wallet — pemasukan & pengeluaran                 |
| `dreams`       | Subcollection di bawah wallet — target keuangan                        |
| `members`      | Subcollection di bawah wallet — daftar pengguna yang memiliki akses     |
| `invitations`  | Koleksi top-level — undangan masuk yang belum diterima/ditolak          |

### 2.3 Collaborative Wallet

- Satu wallet dapat dimiliki oleh satu **Owner** dan diakses bersama oleh maksimal **4 Member tambahan** (total 5 orang).
- Setiap perubahan transaksi langsung terrefleksi secara **realtime** ke semua perangkat anggota aktif.
- Owner dan Member bekerja pada **dataset yang sama** secara bersamaan.
- Pengguna hanya dapat aktif di **satu wallet pada satu waktu**: wallet pribadi atau satu wallet bersama.

---

## 3. TECH STACK & DEPENDENCY

### 3.1 Flutter Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase Core
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  firebase_storage: ^12.x.x

  # Google Sign-In
  google_sign_in: ^6.x.x

  # State Management
  flutter_riverpod: ^2.x.x
  riverpod_annotation: ^2.x.x

  # Navigation
  go_router: ^14.x.x

  # UI & Utilities
  intl: ^0.19.x                    # Format tanggal & mata uang
  cached_network_image: ^3.x.x     # Cache foto profil Google
  flutter_svg: ^2.x.x              # Aset SVG
  shimmer: ^3.x.x                  # Loading skeleton
  gap: ^3.x.x                      # Spacing widget
  uuid: ^4.x.x                     # Generate UUID lokal

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x.x
  riverpod_generator: ^2.x.x
  flutter_lints: ^4.x.x
```

### 3.2 Firebase Services yang Digunakan

| Service                 | Fungsi                                                    |
|-------------------------|-----------------------------------------------------------|
| Firebase Authentication | Login email/password + Login with Google                  |
| Cloud Firestore         | Database utama realtime (semua koleksi)                   |
| Firebase Storage        | Upload foto profil custom (opsional)                      |
| Firebase Security Rules | Pembatasan akses baca/tulis berbasis keanggotaan wallet   |

---

## 4. STRUKTUR FOLDER PROYEK

```
mysaku/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   ├── app_sizes.dart
│   │   │   └── firebase_constants.dart
│   │   ├── extensions/
│   │   │   ├── currency_extension.dart
│   │   │   └── datetime_extension.dart
│   │   ├── utils/
│   │   │   ├── currency_formatter.dart
│   │   │   └── date_formatter.dart
│   │   └── errors/
│   │       └── app_exception.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── wallet_model.dart
│   │   │   ├── transaction_model.dart
│   │   │   ├── dream_model.dart
│   │   │   ├── member_model.dart
│   │   │   └── invitation_model.dart
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── user_repository.dart
│   │       ├── wallet_repository.dart
│   │       ├── transaction_repository.dart
│   │       ├── dream_repository.dart
│   │       └── invitation_repository.dart
│   │
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── wallet_provider.dart
│   │   ├── transaction_provider.dart
│   │   ├── dream_provider.dart
│   │   └── invitation_provider.dart
│   │
│   ├── presentation/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── widgets/
│   │   │       ├── google_sign_in_button.dart
│   │   │       └── auth_form_field.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home_screen.dart           # Shell/scaffold utama dengan bottom nav
│   │   │   └── widgets/
│   │   │       └── bottom_nav_bar.dart
│   │   │
│   │   ├── cashflow/
│   │   │   ├── cashflow_screen.dart       # Menu 1 — Cashflow utama
│   │   │   ├── add_transaction_screen.dart
│   │   │   ├── edit_transaction_screen.dart
│   │   │   └── widgets/
│   │   │       ├── balance_card.dart
│   │   │       ├── summary_card.dart
│   │   │       ├── transaction_list.dart
│   │   │       └── transaction_item_card.dart
│   │   │
│   │   ├── dreams/
│   │   │   ├── dreams_screen.dart         # Menu 2 — Impian / Target
│   │   │   ├── add_dream_screen.dart
│   │   │   ├── edit_dream_screen.dart
│   │   │   └── widgets/
│   │   │       ├── dream_card.dart
│   │   │       └── dream_progress_bar.dart
│   │   │
│   │   └── profile/
│   │       ├── profile_screen.dart        # Menu 3 — Profil & Pengaturan
│   │       ├── invite_member_screen.dart
│   │       ├── manage_members_screen.dart
│   │       └── widgets/
│   │           ├── profile_header.dart
│   │           ├── settings_tile.dart
│   │           └── member_item_card.dart
│   │
│   └── router/
│       └── app_router.dart
│
├── assets/
│   ├── images/
│   └── icons/
│
├── firebase.json
├── firestore.rules
├── firestore.indexes.json
└── pubspec.yaml
```

---

## 5. DESAIN SISTEM & TEMA

### 5.1 Color Palette

| Token               | Hex        | Penggunaan                                        |
|---------------------|------------|---------------------------------------------------|
| `primaryColor`      | `#1E88E5`  | Warna utama — button, aksen aktif                 |
| `primaryDark`       | `#1565C0`  | Hover / pressed state                             |
| `accentGreen`       | `#43A047`  | Pemasukan / income                                |
| `accentRed`         | `#E53935`  | Pengeluaran / expense                             |
| `accentAmber`       | `#FFB300`  | Impian / progress bar                             |
| `backgroundLight`   | `#F5F7FA`  | Background halaman                                |
| `surfaceWhite`      | `#FFFFFF`  | Card, bottom sheet, dialog                        |
| `textPrimary`       | `#1A1A2E`  | Teks utama                                        |
| `textSecondary`     | `#6B7280`  | Teks keterangan / label                           |
| `divider`           | `#E5E7EB`  | Separator                                         |

### 5.2 Typography

| Peran               | Font           | Weight | Size   |
|---------------------|----------------|--------|--------|
| App Bar Title       | Plus Jakarta Sans | 700 | 18sp  |
| Card Title          | Plus Jakarta Sans | 600 | 16sp  |
| Body Text           | Plus Jakarta Sans | 400 | 14sp  |
| Caption / Label     | Plus Jakarta Sans | 400 | 12sp  |
| Nominal / Angka     | JetBrains Mono   | 600 | 16–24sp|

### 5.3 Komponen Visual Kunci

- **Balance Card**: Gradient `primaryColor → primaryDark`, teks putih, nominal menggunakan JetBrains Mono, sudut rounded 20px.
- **Transaction Card**: Surface white, border-left berwarna `accentGreen` untuk pemasukan dan `accentRed` untuk pengeluaran.
- **Dream Card**: Gradient amber subtle, progress bar linear dengan persentase, badge "Target Tercapai" saat 100%.
- **Bottom Navigation**: 3 item (Cashflow, Impian, Profil), ikon + label, indikator titik pada item aktif.

---

## 6. ARSITEKTUR DATABASE FIRESTORE

### 6.1 Koleksi `users`

```
/users/{uid}
```

| Field             | Tipe      | Keterangan                                          |
|-------------------|-----------|-----------------------------------------------------|
| `uid`             | String    | UID Firebase Auth                                   |
| `name`            | String    | Nama lengkap pengguna                               |
| `email`           | String    | Alamat email                                        |
| `photoUrl`        | String?   | URL foto profil (Google atau Storage)               |
| `personalWalletId`| String    | ID wallet pribadi yang dibuat saat registrasi       |
| `activeWalletId`  | String    | ID wallet yang sedang aktif digunakan               |
| `createdAt`       | Timestamp | Waktu registrasi                                    |
| `updatedAt`       | Timestamp | Waktu update terakhir                               |

> **Catatan**: `activeWalletId` = `personalWalletId` secara default. Berubah ketika pengguna menerima undangan. Kembali ke `personalWalletId` ketika keluar dari wallet bersama.

---

### 6.2 Koleksi `wallets`

```
/wallets/{walletId}
```

| Field          | Tipe        | Keterangan                                           |
|----------------|-------------|------------------------------------------------------|
| `walletId`     | String      | Auto-generated document ID                          |
| `name`         | String      | Nama wallet (default: "Tabungan [Nama Owner]")       |
| `ownerId`      | String      | UID Firebase dari pemilik wallet                     |
| `memberIds`    | List<String>| Daftar UID anggota aktif (termasuk owner, maks. 5)   |
| `maxMembers`   | Integer     | Batas anggota, default: 5                            |
| `createdAt`    | Timestamp   | Waktu wallet dibuat                                  |
| `updatedAt`    | Timestamp   | Waktu update terakhir                                |

#### Subcollection: `wallets/{walletId}/transactions`

| Field            | Tipe      | Keterangan                                         |
|------------------|-----------|----------------------------------------------------|
| `transactionId`  | String    | Auto-generated document ID                        |
| `type`           | String    | `"income"` atau `"expense"`                        |
| `name`           | String    | Nama / judul transaksi                             |
| `amount`         | Number    | Nominal dalam Rupiah (integer, tanpa desimal)      |
| `category`       | String    | Kategori transaksi (lihat section 6.5)             |
| `description`    | String?   | Keterangan tambahan (opsional)                     |
| `transactionDate`| Timestamp | Tanggal transaksi (dipilih user)                   |
| `createdBy`      | String    | UID pengguna yang membuat transaksi                |
| `createdByName`  | String    | Nama pengguna yang membuat (snapshot saat dibuat)  |
| `createdAt`      | Timestamp | Timestamp server saat data dibuat                  |
| `updatedAt`      | Timestamp | Timestamp server saat data terakhir diubah         |

#### Subcollection: `wallets/{walletId}/dreams`

| Field          | Tipe      | Keterangan                                           |
|----------------|-----------|------------------------------------------------------|
| `dreamId`      | String    | Auto-generated document ID                          |
| `name`         | String    | Nama impian / target                                 |
| `targetAmount` | Number    | Target nominal dalam Rupiah                          |
| `description`  | String?   | Deskripsi impian (opsional)                          |
| `isAchieved`   | Boolean   | Status tercapai (default: false)                     |
| `createdBy`    | String    | UID yang membuat impian                              |
| `createdAt`    | Timestamp | Waktu impian dibuat                                  |
| `updatedAt`    | Timestamp | Waktu update terakhir                                |

> **Catatan**: Tidak ada field `currentAmount`. Nilai saldo diambil secara realtime dari agregasi transaksi. Progress dihitung di sisi client.

#### Subcollection: `wallets/{walletId}/members`

| Field       | Tipe      | Keterangan                                              |
|-------------|-----------|---------------------------------------------------------|
| `uid`       | String    | Document ID = UID anggota                               |
| `name`      | String    | Nama anggota (snapshot)                                 |
| `email`     | String    | Email anggota (snapshot)                                |
| `photoUrl`  | String?   | Foto profil anggota (snapshot)                          |
| `role`      | String    | `"owner"` atau `"member"`                               |
| `joinedAt`  | Timestamp | Waktu bergabung                                         |

---

### 6.3 Koleksi `invitations`

```
/invitations/{invitationId}
```

| Field          | Tipe      | Keterangan                                           |
|----------------|-----------|------------------------------------------------------|
| `invitationId` | String    | Auto-generated document ID                          |
| `walletId`     | String    | ID wallet yang mengundang                            |
| `ownerId`      | String    | UID owner yang mengirim undangan                     |
| `ownerName`    | String    | Nama owner (snapshot)                                |
| `walletName`   | String    | Nama wallet (snapshot)                               |
| `invitedEmail` | String    | Email calon anggota yang diundang                    |
| `invitedUid`   | String?   | UID calon anggota (diisi setelah login)              |
| `status`       | String    | `"pending"` → `"accepted"` / `"declined"` / `"expired"` |
| `createdAt`    | Timestamp | Waktu undangan dibuat                                |
| `expiresAt`    | Timestamp | Masa berlaku undangan (opsional, default 7 hari)     |

---

### 6.4 Kalkulasi Saldo (Aggregation Logic)

Saldo **tidak disimpan** sebagai field statis. Saldo dihitung secara realtime:

```dart
// Formula Saldo
double totalBalance = totalIncome - totalExpense;

// totalIncome  = SUM(amount) WHERE type == "income"
// totalExpense = SUM(amount) WHERE type == "expense"
```

Di Flutter, ini diimplementasikan menggunakan `StreamProvider` Riverpod yang listen ke subcollection `transactions`. Setiap perubahan dokumen akan memicu rebuild otomatis pada widget balance card dan dream progress.

```dart
// Contoh provider kalkulasi saldo
@riverpod
Stream<double> walletBalance(WalletBalanceRef ref, String walletId) {
  return FirebaseFirestore.instance
      .collection('wallets')
      .doc(walletId)
      .collection('transactions')
      .snapshots()
      .map((snapshot) {
    double income = 0;
    double expense = 0;
    for (final doc in snapshot.docs) {
      final tx = TransactionModel.fromJson(doc.data());
      if (tx.type == 'income') income += tx.amount;
      if (tx.type == 'expense') expense += tx.amount;
    }
    return income - expense;
  });
}
```

### 6.5 Kategori Transaksi

#### Kategori Pemasukan (`income`)

| ID            | Label              |
|---------------|--------------------|
| `salary`      | Gaji               |
| `freelance`   | Freelance          |
| `investment`  | Investasi          |
| `bonus`       | Bonus              |
| `gift`        | Hadiah / Pemberian |
| `other_income`| Lainnya            |

#### Kategori Pengeluaran (`expense`)

| ID             | Label               |
|----------------|---------------------|
| `food`         | Makan & Minum       |
| `transport`    | Transportasi        |
| `bills`        | Tagihan             |
| `shopping`     | Belanja             |
| `health`       | Kesehatan           |
| `education`    | Pendidikan          |
| `entertainment`| Hiburan             |
| `savings`      | Tabungan / Investasi|
| `other_expense`| Lainnya             |

---

## 7. ALUR SISTEM (FLOW)

### 7.1 Alur Registrasi & Inisialisasi Wallet

```
Pengguna buka app
    │
    ▼
Halaman Login/Register
    │
    ▼ [Registrasi berhasil]
Firebase Auth createUser()
    │
    ▼
Buat dokumen /users/{uid}
    │
    ▼
Buat dokumen /wallets/{newWalletId}
  - ownerId = uid
  - memberIds = [uid]
    │
    ▼
Buat subcollection /wallets/{newWalletId}/members/{uid}
  - role = "owner"
    │
    ▼
Update /users/{uid}
  - personalWalletId = newWalletId
  - activeWalletId   = newWalletId
    │
    ▼
Navigate ke Home (Cashflow)
```

### 7.2 Alur Login & Resolusi Wallet Aktif

```
Login berhasil (email/Google)
    │
    ▼
Ambil dokumen /users/{uid}
    │
    ├─► activeWalletId != personalWalletId?
    │       │
    │       ▼ YES
    │   Cek apakah uid masih ada di
    │   /wallets/{activeWalletId}/members/{uid}
    │       │
    │       ├─► Masih ada → Buka wallet bersama
    │       │
    │       └─► Sudah tidak ada → Reset activeWalletId
    │                              ke personalWalletId
    │
    └─► activeWalletId == personalWalletId
            │
            ▼
        Cek /invitations WHERE invitedEmail == userEmail
                               AND status == "pending"
            │
            ├─► Ada undangan aktif →
            │     Update invitation status = "accepted"
            │     Tambah uid ke wallet memberIds
            │     Buat member doc di wallet
            │     Update activeWalletId user
            │     Buka wallet bersama
            │
            └─► Tidak ada undangan → Buka wallet pribadi
                                      (personalWalletId)
```

### 7.3 Alur Invite Member

```
Owner buka menu Invite Member
    │
    ▼
Hitung jumlah anggota di
/wallets/{walletId}/members
    │
    ├─► count >= 5 → Tombol Invite nonaktif, tampilkan info
    │
    └─► count < 5 → Tampilkan form input email
            │
            ▼
        Owner masukkan Gmail calon anggota
            │
            ▼
        Validasi: Cek apakah email terdaftar
        di Firebase Auth (via Cloud Function / lookup)
            │
            ├─► Tidak terdaftar → Tampilkan pesan
            │     "Pengguna belum terdaftar di MySAKU"
            │
            └─► Terdaftar → Cek: apakah sudah member?
                    │
                    ├─► Sudah member → Tampilkan pesan
                    │     "Pengguna sudah menjadi anggota"
                    │
                    └─► Belum → Buat dokumen
                          /invitations/{newId}
                            - walletId, ownerId, ownerName
                            - invitedEmail, status: "pending"
                            - expiresAt = now + 7 hari
                          Tampilkan konfirmasi sukses
```

### 7.4 Alur Keluar dari Wallet Bersama

```
Member buka Profil → Keluar dari Tabungan
    │
    ▼
Dialog konfirmasi: "Yakin keluar dari wallet ini?"
    │
    ▼ [Konfirmasi YA]
Hapus dokumen /wallets/{walletId}/members/{uid}
    │
    ▼
Hapus uid dari /wallets/{walletId}/memberIds
    │
    ▼
Update /users/{uid}
  activeWalletId = personalWalletId
    │
    ▼
Navigate ke Home (Cashflow) dengan wallet pribadi
  — seluruh data pribadi sebelumnya tetap tersedia —
```

---

## 8. MODEL DATA (DART)

### 8.1 UserModel

```dart
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String personalWalletId;
  final String activeWalletId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.personalWalletId,
    required this.activeWalletId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    photoUrl: json['photoUrl'] as String?,
    personalWalletId: json['personalWalletId'] as String,
    activeWalletId: json['activeWalletId'] as String,
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'personalWalletId': personalWalletId,
    'activeWalletId': activeWalletId,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
```

### 8.2 WalletModel

```dart
class WalletModel {
  final String walletId;
  final String name;
  final String ownerId;
  final List<String> memberIds;
  final int maxMembers;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isFull => memberIds.length >= maxMembers;
  bool get canInvite => memberIds.length < maxMembers;
  int get availableSlots => maxMembers - memberIds.length;
}
```

### 8.3 TransactionModel

```dart
class TransactionModel {
  final String transactionId;
  final String type;             // "income" | "expense"
  final String name;
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;
  final String createdBy;        // UID
  final String createdByName;    // Nama snapshot
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
```

### 8.4 DreamModel

```dart
class DreamModel {
  final String dreamId;
  final String name;
  final double targetAmount;
  final String? description;
  final bool isAchieved;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Progress dihitung di luar model, butuh currentBalance dari wallet
  double calculateProgress(double currentBalance) {
    if (targetAmount <= 0) return 0;
    return (currentBalance / targetAmount * 100).clamp(0, 100);
  }
}
```

### 8.5 InvitationModel

```dart
class InvitationModel {
  final String invitationId;
  final String walletId;
  final String ownerId;
  final String ownerName;
  final String walletName;
  final String invitedEmail;
  final String? invitedUid;
  final String status;           // "pending" | "accepted" | "declined" | "expired"
  final DateTime createdAt;
  final DateTime? expiresAt;

  bool get isPending => status == 'pending';
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isValid => isPending && !isExpired;
}
```

---

## 9. NAVIGASI (go_router)

### 9.1 Route Map

```
/                           → SplashScreen (cek auth state)
/auth/login                 → LoginScreen
/auth/register              → RegisterScreen
/home                       → HomeScreen (ShellRoute — bottom nav)
  /home/cashflow            → CashflowScreen (default tab)
  /home/cashflow/add        → AddTransactionScreen
  /home/cashflow/edit/:id   → EditTransactionScreen
  /home/dreams              → DreamsScreen
  /home/dreams/add          → AddDreamScreen
  /home/dreams/edit/:id     → EditDreamScreen
  /home/profile             → ProfileScreen
  /home/profile/invite      → InviteMemberScreen
  /home/profile/members     → ManageMembersScreen
```

### 9.2 Guard & Redirect Logic

```dart
// app_router.dart
redirect: (context, state) {
  final isAuthenticated = ref.read(authStateProvider).value != null;
  final isAuthRoute = state.matchedLocation.startsWith('/auth');

  if (!isAuthenticated && !isAuthRoute) return '/auth/login';
  if (isAuthenticated && isAuthRoute) return '/home';
  return null;
}
```

---

## 10. STATE MANAGEMENT (Riverpod)

### 10.1 Provider Hierarchy

```
authStateProvider           → Stream<User?> dari Firebase Auth
    │
    └─► userProvider        → Stream<UserModel?> dari /users/{uid}
            │
            └─► activeWalletIdProvider  → String (dari userProvider)
                    │
                    ├─► walletProvider           → Stream<WalletModel>
                    ├─► transactionsProvider     → Stream<List<TransactionModel>>
                    ├─► walletBalanceProvider    → Stream<double>
                    ├─► dreamsProvider           → Stream<List<DreamModel>>
                    └─► membersProvider          → Stream<List<MemberModel>>
```

### 10.2 Provider Utama

```dart
// Auth state
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

// User data
@riverpod
Stream<UserModel?> user(UserRef ref) {
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(auth.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
}

// Active wallet ID
@riverpod
String? activeWalletId(ActiveWalletIdRef ref) {
  return ref.watch(userProvider).value?.activeWalletId;
}

// Wallet balance (realtime)
@riverpod
Stream<double> walletBalance(WalletBalanceRef ref) {
  final walletId = ref.watch(activeWalletIdProvider);
  if (walletId == null) return Stream.value(0.0);
  return FirebaseFirestore.instance
      .collection('wallets')
      .doc(walletId)
      .collection('transactions')
      .snapshots()
      .map((snap) {
        double income = 0, expense = 0;
        for (final doc in snap.docs) {
          final tx = TransactionModel.fromJson(doc.data());
          tx.isIncome ? income += tx.amount : expense += tx.amount;
        }
        return income - expense;
      });
}
```

---

## 11. FIREBASE SECURITY RULES

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper: Cek apakah user adalah anggota wallet
    function isMember(walletId) {
      return request.auth != null &&
             request.auth.uid in get(/databases/$(database)/documents/wallets/$(walletId)).data.memberIds;
    }

    // Helper: Cek apakah user adalah owner wallet
    function isOwner(walletId) {
      return request.auth != null &&
             request.auth.uid == get(/databases/$(database)/documents/wallets/$(walletId)).data.ownerId;
    }

    // Koleksi users: hanya bisa baca/tulis data sendiri
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Koleksi wallets: hanya anggota yang bisa mengakses
    match /wallets/{walletId} {
      allow read: if isMember(walletId);
      allow create: if request.auth != null;
      allow update: if isOwner(walletId);
      allow delete: if isOwner(walletId);

      // Subcollection transactions
      match /transactions/{transactionId} {
        allow read: if isMember(walletId);
        allow create: if isMember(walletId);
        allow update: if isMember(walletId) &&
                         (isOwner(walletId) ||
                          resource.data.createdBy == request.auth.uid);
        allow delete: if isMember(walletId) &&
                         (isOwner(walletId) ||
                          resource.data.createdBy == request.auth.uid);
      }

      // Subcollection dreams
      match /dreams/{dreamId} {
        allow read: if isMember(walletId);
        allow create: if isMember(walletId);
        allow update: if isMember(walletId);
        allow delete: if isOwner(walletId) ||
                         resource.data.createdBy == request.auth.uid;
      }

      // Subcollection members
      match /members/{memberId} {
        allow read: if isMember(walletId);
        allow write: if isOwner(walletId);
      }
    }

    // Koleksi invitations
    match /invitations/{invitationId} {
      // Owner bisa membuat undangan
      allow create: if request.auth != null;
      // Penerima bisa membaca undangannya sendiri
      allow read: if request.auth != null &&
                     (resource.data.ownerId == request.auth.uid ||
                      resource.data.invitedEmail == request.auth.token.email);
      // Update status: hanya penerima atau owner
      allow update: if request.auth != null &&
                       (resource.data.ownerId == request.auth.uid ||
                        resource.data.invitedEmail == request.auth.token.email);
      allow delete: if request.auth != null &&
                       resource.data.ownerId == request.auth.uid;
    }
  }
}
```

---

## 12. PERMISSION MATRIX

| Aksi                              | Owner | Member |
|-----------------------------------|:-----:|:------:|
| Lihat semua transaksi             |  ✅   |   ✅   |
| Tambah transaksi pemasukan        |  ✅   |   ✅   |
| Tambah transaksi pengeluaran      |  ✅   |   ✅   |
| Edit transaksi milik sendiri      |  ✅   |   ✅   |
| Hapus transaksi milik sendiri     |  ✅   |   ✅   |
| Edit transaksi milik orang lain   |  ✅   |   ❌   |
| Hapus transaksi milik orang lain  |  ✅   |   ❌   |
| Lihat semua impian                |  ✅   |   ✅   |
| Tambah impian baru                |  ✅   |   ✅   |
| Edit impian                       |  ✅   |   ✅   |
| Hapus impian milik sendiri        |  ✅   |   ✅   |
| Hapus impian milik orang lain     |  ✅   |   ❌   |
| Lihat daftar anggota              |  ✅   |   ✅   |
| Undang anggota baru               |  ✅   |   ❌   |
| Keluarkan anggota lain            |  ✅   |   ❌   |
| Keluar dari wallet bersama        |  ❌   |   ✅   |
| Ganti nama wallet                 |  ✅   |   ❌   |
| Hapus wallet                      |  ✅   |   ❌   |

---

## 13. HALAMAN & KOMPONEN UI

### 13.1 CashflowScreen

**Komponen utama:**
1. `BalanceCard` — Total Saldo (realtime)
   - Background gradient, teks putih
   - Nominal menggunakan font JetBrains Mono
   - Subtitle: nama wallet + jumlah anggota
2. `SummaryRow` — dua card sejajar
   - `SummaryCard` Total Pemasukan (accentGreen)
   - `SummaryCard` Total Pengeluaran (accentRed)
3. `TransactionList` — ListView.builder stream
   - Filter: Semua / Pemasukan / Pengeluaran
   - Header tanggal (group by date)
4. FAB `+` → AddTransactionScreen

**Transaction Item Card fields:**
- Ikon kategori (leading)
- Nama transaksi (bold)
- Keterangan + nama pembuat (caption)
- Tanggal transaksi
- Nominal ± (colored, JetBrains Mono)

### 13.2 AddTransactionScreen / EditTransactionScreen

**Form fields:**
| Field            | Widget                   | Validasi                      |
|------------------|--------------------------|-------------------------------|
| Jenis Transaksi  | SegmentedButton          | Required                      |
| Nama Transaksi   | TextFormField            | Required, min 2 char          |
| Nominal          | TextFormField (number)   | Required, > 0                 |
| Kategori         | DropdownButtonFormField  | Required                      |
| Tanggal          | DatePicker               | Required, tidak boleh future  |
| Keterangan       | TextFormField multiline  | Optional, max 200 char        |

### 13.3 DreamsScreen

**Komponen:**
1. ListView dream cards
2. FAB `+` → AddDreamScreen

**Dream Card:**
- Nama impian (bold)
- Target: Rp X.XXX.XXX
- Saldo saat ini: Rp X.XXX.XXX (realtime dari walletBalanceProvider)
- LinearProgressIndicator (0–100%)
- Badge "🎯 Target Tercapai" saat progress >= 100%
- Tombol Edit (icon)

### 13.4 ProfileScreen

**Sections:**
1. Header: Foto profil, nama, email
2. Info Wallet: Nama wallet, status (Pribadi / Bersama), jumlah anggota
3. Menu:
   - **Invite Member** (hanya muncul jika isOwner && canInvite)
   - **Kelola Anggota** (hanya muncul jika isOwner)
   - **Keluar dari Tabungan** (hanya muncul jika bukan personalWallet)
   - Pengaturan Profil
   - Keluar (Logout)

### 13.5 InviteMemberScreen

**Flow UI:**
1. Tampilkan jumlah slot tersisa (misal "Tersisa 3 slot dari 5")
2. Input email Gmail calon anggota
3. Tombol "Kirim Undangan"
4. Loading state saat validasi email
5. Snackbar sukses / error

---

## 14. HANDLING EDGE CASES

| Skenario                                | Penanganan                                                           |
|-----------------------------------------|----------------------------------------------------------------------|
| Saldo negatif                           | Tampilkan nominal merah dengan prefix "-" — tidak diblokir sistem   |
| Member unduh app tapi belum login       | Undangan tetap pending, berlaku sampai expiresAt                    |
| Owner hapus akun                        | Wallet tetap ada, tapi tanpa owner — reserved untuk v2               |
| Dua undangan ke email sama              | Cek duplikasi sebelum buat undangan baru, tolak jika pending ada    |
| Member coba akses wallet lain via ID    | Security Rules menolak — uid tidak ada di memberIds wallet tersebut |
| Transaksi dibuat saat offline           | Firestore offline persistence aktif — sync otomatis saat online     |
| Dream targetAmount = 0                  | Validasi form: target minimal Rp 1.000                              |

---

## 15. KONFIGURASI FIREBASE

### 15.1 Firebase Offline Persistence

```dart
// main.dart
await FirebaseFirestore.instance.enablePersistence(
  const PersistenceSettings(synchronizeTabs: false),
);
```

### 15.2 Firestore Indexes (firestore.indexes.json)

```json
{
  "indexes": [
    {
      "collectionGroup": "transactions",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "transactionDate", "order": "DESCENDING" },
        { "fieldPath": "type", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "invitations",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "invitedEmail", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## 16. FORMAT & UTILITAS

### 16.1 Format Mata Uang

```dart
// currency_formatter.dart
import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(double amount) => _formatter.format(amount);

  static String formatCompact(double amount) {
    if (amount >= 1000000) return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    return format(amount);
  }
}
```

### 16.2 Format Tanggal

```dart
// date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  static final _full = DateFormat('dd MMMM yyyy', 'id_ID');
  static final _short = DateFormat('dd MMM yyyy', 'id_ID');
  static final _time = DateFormat('HH:mm', 'id_ID');

  static String full(DateTime date) => _full.format(date);
  static String short(DateTime date) => _short.format(date);
  static String time(DateTime date) => _time.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays <= 7) return '${diff.inDays} hari lalu';
    return short(date);
  }
}
```

---

## 17. ROADMAP PENGEMBANGAN

### Phase 1 — MVP (Versi 1.0) ✅ Blueprint ini
- Auth (email + Google)
- Wallet personal otomatis
- CRUD Transaksi (pemasukan & pengeluaran)
- CRUD Impian + progress realtime
- Invite member (maks. 5 orang)
- Keluar dari wallet bersama
- Firebase Security Rules

### Phase 2 — Enhancement (Versi 1.1)
- Grafik pengeluaran bulanan (chart per kategori)
- Filter transaksi per bulan / kategori
- Ringkasan bulanan (summary per bulan)
- Push notification undangan baru
- Deep link undangan via email

### Phase 3 — Advanced (Versi 2.0)
- Export laporan PDF per bulan
- Audit log aktivitas anggota
- Pengingat transaksi rutin (recurring)
- Notifikasi saat target impian tercapai
- Multi-wallet (premium feature)
- Backup & restore data

---

## 18. KONVENSI KODE

| Aspek                 | Konvensi                                                          |
|-----------------------|-------------------------------------------------------------------|
| Penamaan file         | `snake_case.dart`                                                 |
| Penamaan class        | `PascalCase`                                                      |
| Penamaan variabel     | `camelCase`                                                       |
| Penamaan konstanta    | `kCamelCase`                                                      |
| Riverpod provider     | Gunakan `@riverpod` annotation + code generation                  |
| Firestore collection  | `camelCase` (users, wallets, transactions, dreams, invitations)   |
| Firestore document ID | Auto-generated kecuali `users/{uid}` dan `members/{uid}`          |
| Timestamp             | Selalu gunakan `FieldValue.serverTimestamp()` untuk `createdAt`   |
| Error handling        | Setiap repository method wrap dalam try-catch, throw AppException |
| Loading state         | Gunakan `AsyncValue` dari Riverpod secara konsisten               |

---

*rule-mysaku.md — MySAKU Blueprint v1.0.0*
*Dibuat untuk: Flutter + Firebase | Collaborative Personal Finance Management*
*Wallet-Centric Architecture | Realtime Sync | Multi-Member Support*
