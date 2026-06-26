import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../providers/auth_provider.dart';
import 'widgets/auth_form_field.dart';
import 'widgets/google_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) context.go('/home');
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final cred = await repo.signInWithGoogle();
      if (cred != null && mounted) {
        context.go('/home');
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet,
                      size: 64, color: AppColors.primaryColor),
                  const SizedBox(height: 16),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    AppStrings.loginSubtitle,
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  AuthFormField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'masukkan email anda',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val == null || !val.contains('@')
                        ? 'Email tidak valid'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'masukkan password anda',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (val) => val == null || val.length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginEmail,
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
                          : const Text('Masuk',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GoogleSignInButton(
                      onPressed: _loginGoogle, isLoading: _isLoading),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Belum punya akun? ',
                          style: TextStyle(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.push('/auth/register'),
                        child: const Text('Daftar Sekarang',
                            style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
