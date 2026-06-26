import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../providers/invitation_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/wallet_provider.dart';

class InviteMemberScreen extends ConsumerStatefulWidget {
  const InviteMemberScreen({super.key});

  @override
  ConsumerState<InviteMemberScreen> createState() => _InviteMemberScreenState();
}

class _InviteMemberScreenState extends ConsumerState<InviteMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final wallet = ref.read(walletProvider).value;
    final user = ref.read(userProvider).value;
    if (wallet == null || user == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(invitationRepositoryProvider);
      await repo.sendInvitation(
        walletId: wallet.walletId,
        ownerId: user.uid,
        ownerName: user.name,
        walletName: wallet.name,
        invitedEmail: _emailController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Undangan berhasil dikirim!')));
        context.pop();
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.inviteMember,
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Undang pasangan atau keluarga untuk mencatat pengeluaran dan mencapai target impian di tabungan ini.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Tujuan',
                  hintText: 'mis. pasangan@gmail.com',
                  prefixIcon: const Icon(Icons.email_outlined,
                      color: AppColors.primaryColor),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
                validator: (val) => val == null || !val.contains('@')
                    ? 'Masukkan email yang valid'
                    : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Kirim Undangan',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
