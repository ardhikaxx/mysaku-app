import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/dream_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dream_provider.dart';
import '../../providers/user_provider.dart';

class AddDreamScreen extends ConsumerStatefulWidget {
  const AddDreamScreen({super.key});

  @override
  ConsumerState<AddDreamScreen> createState() => _AddDreamScreenState();
}

class _AddDreamScreenState extends ConsumerState<AddDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''));
      final dream = DreamModel(
        dreamId: '',
        name: _nameController.text.trim(),
        targetAmount: amount,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        isAchieved: false,
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(dreamRepositoryProvider);
      await repo.addDream(walletId, dream);
      if (mounted) context.pop();
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
        title: const Text(AppStrings.addDream,
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Impian / Target',
                  hintText: 'mis. Liburan ke Bali',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
                validator: (val) => val == null || val.trim().length < 2
                    ? 'Minimal 2 karakter'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Dana (Rp)',
                  hintText: '10000000',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Target wajib diisi';
                  final parsed = double.tryParse(
                      val.replaceAll('.', '').replaceAll(',', ''));
                  if (parsed == null || parsed <= 0) {
                    return 'Target harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  labelText: 'Keterangan Tambahan (Opsional)',
                  hintText: 'rencana...',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentAmber,
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
                      : const Text('Buat Impian Baru',
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
