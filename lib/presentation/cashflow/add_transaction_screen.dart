import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/datetime_extension.dart';
import '../../data/models/transaction_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';

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
    final activeCategories =
        _type == 'income' ? _incomeCategories : _expenseCategories;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.addTransaction,
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
                      _category = _type == 'income' ? 'salary' : 'food';
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Judul Transaksi',
                  hintText: 'mis. Beli makan siang',
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
                  hintText: '0',
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
                  hintText: 'catatan kecil...',
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
                    backgroundColor: _type == 'income'
                        ? AppColors.accentGreen
                        : AppColors.accentRed,
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
                      : const Text('Simpan Transaksi',
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
