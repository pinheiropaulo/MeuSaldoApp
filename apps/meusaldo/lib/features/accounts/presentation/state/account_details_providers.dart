import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/accounts/presentation/state/account_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/transaction_providers.dart';
import 'package:meusaldo_core/meusaldo_core.dart';

/// Provedor que recupera uma conta financeira específica pelo seu ID.
final accountByIdProvider =
    Provider.family<FinancialAccount?, String>((ref, id) {
  final accounts = ref.watch(accountsListProvider).value ?? const [];
  return accounts.where((a) => a.id == id).firstOrNull;
});

/// Provedor que filtra os lançamentos de uma conta específica em ordem cronológica inversa.
final accountTransactionsProvider =
    Provider.family<List<Transaction>, String>((ref, accountId) {
  final all = ref.watch(transactionsListProvider).value ?? const [];
  final filtered = all
      .where((tx) =>
          tx.accountId == accountId || tx.destinationAccountId == accountId)
      .toList();
  filtered.sort((a, b) => b.date.compareTo(a.date));
  return filtered;
});

/// Estatísticas mensais de entradas e saídas de uma conta financeira específica.
class AccountMonthlyStats {
  final Money monthlyIncome;
  final Money monthlyExpense;

  const AccountMonthlyStats({
    required this.monthlyIncome,
    required this.monthlyExpense,
  });
}

/// Provedor de cálculo das entradas e saídas do mês corrente para a conta informada.
final accountMonthlyStatsProvider =
    Provider.family<AccountMonthlyStats, String>((ref, accountId) {
  final transactions = ref.watch(accountTransactionsProvider(accountId));
  final now = DateTime.now();

  var incomeCents = 0;
  var expenseCents = 0;

  for (final tx in transactions) {
    if (tx.date.year == now.year &&
        tx.date.month == now.month &&
        tx.isCompleted) {
      if (tx.isIncome && tx.accountId == accountId) {
        incomeCents += tx.amount.cents;
      } else if (tx.isExpense && tx.accountId == accountId && !tx.isCardExpense) {
        expenseCents += tx.amount.cents;
      } else if (tx.isTransfer) {
        if (tx.destinationAccountId == accountId) {
          incomeCents += tx.amount.cents;
        } else if (tx.accountId == accountId) {
          expenseCents += tx.amount.cents;
        }
      }
    }
  }

  return AccountMonthlyStats(
    monthlyIncome: Money.fromCents(incomeCents),
    monthlyExpense: Money.fromCents(expenseCents),
  );
});

/// Notifier do estado de visibilidade do saldo da conta (ocultar / exibir).
class AccountBalanceVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
}

final accountBalanceVisibilityProvider =
    NotifierProvider<AccountBalanceVisibilityNotifier, bool>(
  AccountBalanceVisibilityNotifier.new,
);
