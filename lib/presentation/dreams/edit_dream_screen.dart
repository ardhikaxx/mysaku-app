import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/dream_model.dart';
import '../../providers/dream_provider.dart';
import '../../providers/user_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';

class EditDreamScreen extends ConsumerStatefulWidget {
  final DreamModel dream;

  const EditDreamScreen({
    super.key,
    required this.dream,
  });

  @override
  ConsumerState<EditDreamScreen> createState() => _EditDreamScreenState();
}

class _EditDreamScreenState extends ConsumerState<EditDreamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  late bool _isAchieved;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dream.name);
    _amountController = TextEditingController(
        text: widget.dream.targetAmount.toInt().toString());
    _descController = TextEditingController(text: widget.dream.description ?? '');
    _isAchieved = widget.dream.isAchieved;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''));
      final updated = DreamModel(
        dreamId: widget.dream.dreamId,
        name: _nameController.text.trim(),
        targetAmount: amount,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        isAchieved: _isAchieved,
        createdBy: widget.dream.createdBy,
        createdAt: widget.dream.createdAt,
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(dreamRepositoryProvider);
      await repo.updateDream(walletId, updated);
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

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Impian?',
      message: 'Impian keuangan ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
      confirmText: 'Ya, Hapus',
      icon: Icons.auto_awesome_rounded,
      iconColor: const Color(0xFFEF4444),
    );

    if (confirmed != true) return;
    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(dreamRepositoryProvider);
      await repo.deleteDream(walletId, widget.dream.dreamId);
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
      appBar: FloatingCapsuleAppBar(
        title: AppStrings.editDream,
        showBack: true,
        onLeadingTap: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: _isLoading ? null : _delete,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Tandai Sudah Tercapai',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Mengubah status pencapaian impian'),
                value: _isAchieved,
                activeColor: AppColors.accentGreen,
                onChanged: (val) => setState(() => _isAchieved = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Impian / Target',
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
                      : const Text('Perbarui Impian',
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
