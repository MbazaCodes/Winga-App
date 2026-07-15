import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/earnings_repository.dart';
import '../../domain/transaction_model.dart';

final earningsRepositoryProvider = Provider((_) => EarningsRepository());

final transactionsProvider = FutureProvider<List<TransactionModel>>((ref) {
  return ref.read(earningsRepositoryProvider).getTransactions();
});

final earningsSummaryProvider = FutureProvider<Map<String, int>>((ref) {
  return ref.read(earningsRepositoryProvider).getEarningsSummary();
});
