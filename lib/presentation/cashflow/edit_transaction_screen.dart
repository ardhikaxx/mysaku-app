import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../home/widgets/floating_capsule_app_bar.dart';
import '../shared/widgets/confirm_dialog.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  final TransactionModel tx;

  const EditTransactionScreen({
    super.key,
    required this.tx,
  });

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends ConsumerState<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  late String _type;
  late String _category;
  late DateTime _date;
  bool _isLoading = false;

  final Map<String, String> _incomeCategories = {
    'salary': 'Gaji',
    'freelance': 'Freelance',
    'investment': 'Investasi',
    'bonus': 'Bonus',
    'gift': 'Hadiah / Pemberian',
    'other_income': 'Lainnya',
  };

  final Map<String, String> _expenseCategories = {
    'food': 'Makan & Minum',
    'transport': 'Transportasi',
    'bills': 'Tagihan',
    'shopping': 'Belanja',
    'health': 'Kesehatan',
    'education': 'Pendidikan',
    'entertainment': 'Hiburan',
    'savings': 'Tabungan / Investasi',
    'other_expense': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.tx.name);
    _amountController =
        TextEditingController(text: widget.tx.amount.toInt().toString());
    _descController = TextEditingController(text: widget.tx.description ?? '');
    _type = widget.tx.type;
    _category = widget.tx.category;
    _date = widget.tx.transactionDate;
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

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''));
      final updatedTx = TransactionModel(
        transactionId: widget.tx.transactionId,
        type: _type,
        name: _nameController.text.trim(),
        amount: amount,
        category: _category,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        transactionDate: _date,
        createdBy: widget.tx.createdBy,
        createdByName: widget.tx.createdByName,
        createdAt: widget.tx.createdAt,
        updatedAt: DateTime.now(),
      );

      final repo = ref.read(transactionRepositoryProvider);
      await repo.updateTransaction(walletId, updatedTx);
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

  Future<void> _delete() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hapus Transaksi?',
      message: 'Transaksi ini akan dihapus secara permanen dan tidak dapat dikembalikan.',
      confirmText: 'Ya, Hapus',
    );

    if (confirmed != true) return;
    final walletId = ref.read(activeWalletIdProvider);
    if (walletId == null) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(walletId, widget.tx.transactionId);
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
    final activeCategories =
        _type == 'income' ? _incomeCategories : _expenseCategories;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: FloatingCapsuleAppBar(
        title: AppStrings.editTransaction,
        showBack: true,
        onLeadingTap: () => context.pop(),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: _isLoading ? null : _delete,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Jenis Transaksi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: 'income',
                        label: Text('Pemasukan',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    ButtonSegment(
                        value: 'expense',
                        label: Text('Pengeluaran',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  selected: {_type},
                  onSelectionChanged: (val) {
                    setState(() {
                      _type = val.first;
                      if (!activeCategories.containsKey(_category)) {
                        _category = _type == 'income' ? 'salary' : 'food';
                      }
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Judul Transaksi',
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
                  labelText: 'Nominal (Rp)',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
                items: activeCategories.entries
                    .map((e) =>
                        DropdownMenuItem(value: e.key, child: Text(e.value)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Tanggal Transaksi',
                    filled: true,
                    fillColor: AppColors.surfaceWhite,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_date.toShortDate),
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: AppColors.primaryColor),
                    ],
                  ),
                ),
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
                      : const Text('Perbarui Transaksi',
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
