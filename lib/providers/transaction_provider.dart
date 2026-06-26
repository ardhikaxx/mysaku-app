import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/transaction_model.dart';
import '../data/repositories/transaction_repository.dart';
import 'user_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider = StreamProvider<List<TransactionModel>>((ref) {
  final walletId = ref.watch(activeWalletIdProvider);
  if (walletId == null || walletId.isEmpty) return Stream.value([]);

  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getTransactionsStream(walletId);
});

final walletBalanceProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];
  double income = 0;
  double expense = 0;
  for (final tx in transactions) {
    if (tx.isIncome) income += tx.amount;
    if (tx.isExpense) expense += tx.amount;
  }
  return income - expense;
});

final transactionFilterProvider = StateProvider<String>((ref) => 'all'); // 'all', 'income', 'expense'

final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final filter = ref.watch(transactionFilterProvider);
  final list = ref.watch(transactionsProvider).value ?? [];

  if (filter == 'income') return list.where((tx) => tx.isIncome).toList();
  if (filter == 'expense') return list.where((tx) => tx.isExpense).toList();
  return list;
});
