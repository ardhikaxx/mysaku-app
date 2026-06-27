import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  String _type = 'expense'; // 'income' or 'expense'
  String _category = 'food';
  DateTime _date = DateTime.now();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    _category = _type == 'income' ? 'salary' : 'food';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

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
      final tx = TransactionModel(
        transactionId: '',
        type: _type,
        name: _nameController.text.trim(),
        amount: amount,
        category: _category,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        transactionDate: _date,
        createdBy: user.uid,
        createdByName: user.displayName ?? 'User',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(transactionRepositoryProvider);
      await repo.addTransaction(walletId, tx);
      if (mounted) context.pop();
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
    final incCategories = ref.watch(customIncomeCategoriesProvider);
    final expCategories = ref.watch(customExpenseCategoriesProvider);
    final activeCategories = _type == 'income' ? incCategories : expCategories;
    final isIncome = _type == 'income';
    final activeColor = isIncome ? AppColors.accentGreen : AppColors.accentRed;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: AppStrings.addTransaction,
        showBack: true,
        onLeadingTap: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 140),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Type Switcher
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isIncome) {
                            setState(() {
                              _type = 'income';
                              _category = 'salary';
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isIncome ? AppColors.accentGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isIncome
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isIncome ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isIncome) {
                            setState(() {
                              _type = 'expense';
                              _category = 'food';
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isIncome ? AppColors.accentRed : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: !isIncome
                                ? [
                                    BoxShadow(
                                      color: AppColors.accentRed.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: !isIncome ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Hero Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: activeColor.withValues(alpha: 0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Nominal Transaksi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: activeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [ThousandsFormatter()],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: activeColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Rp 0',
                        hintStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.divider,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Nominal wajib diisi';
                        final parsed = double.tryParse(
                            val.replaceAll('.', '').replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Nominal harus lebih dari 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Grouped Form Fields Card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // Judul Transaksi
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        child: TextFormField(
                          controller: _nameController,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.edit_note_rounded, color: AppColors.primaryColor, size: 26),
                            labelText: 'Judul Transaksi',
                            labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            hintText: 'mis. Beli makan siang',
                            hintStyle: TextStyle(color: AppColors.divider, fontWeight: FontWeight.normal),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          validator: (val) => val == null || val.trim().length < 2
                              ? 'Minimal 2 karakter'
                              : null,
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 56),

                      // Kategori Dropdown
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        child: DropdownButtonFormField<String>(
                          value: _category,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.category_rounded, color: AppColors.accentAmber, size: 24),
                            labelText: 'Kategori',
                            labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                          items: activeCategories.entries
                              .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                  ))
                              .toList(),
                          onChanged: (val) => setState(() => _category = val!),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 56),

                      // Tanggal Transaksi
                      InkWell(
                        onTap: _pickDate,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Color(0xFF3B82F6), size: 22),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Tanggal Transaksi', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 2),
                                    Text(_date.toShortDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: AppColors.divider, size: 22),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.divider, indent: 56),

                      // Keterangan Tambahan
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                        child: TextFormField(
                          controller: _descController,
                          maxLines: 2,
                          maxLength: 200,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            icon: Icon(Icons.notes_rounded, color: Color(0xFF8B5CF6), size: 24),
                            labelText: 'Catatan Tambahan (Opsional)',
                            labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            hintText: 'Tulis catatan...',
                            hintStyle: TextStyle(color: AppColors.divider),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Action Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Simpan Transaksi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
