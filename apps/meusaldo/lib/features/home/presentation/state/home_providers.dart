import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meusaldo/features/cards/presentation/state/card_providers.dart';
import 'package:meusaldo/features/transactions/presentation/state/bill_schedule_providers.dart';

/// Notifier que gerencia a visibilidade dos saldos na tela inicial (privacidade do usuário).
class BalanceVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  /// Alterna a visibilidade entre visível e oculto.
  void toggle() => state = !state;
}

/// Provedor reativo da visibilidade dos saldos.
final isBalanceVisibleProvider =
    NotifierProvider<BalanceVisibilityNotifier, bool>(
  BalanceVisibilityNotifier.new,
);

/// Modelo de dados de alerta para a seção "Próximo compromisso" da Home.
class UpcomingAlertData {
  final String title;
  final String description;
  final String badgeText;
  final IconData icon;

  const UpcomingAlertData({
    required this.title,
    required this.description,
    required this.badgeText,
    this.icon = Icons.credit_card,
  });
}

/// Provedor reativo que avalia se há contas em atraso, faturas próximas do fechamento
/// ou contas a vencer. Retorna `null` caso o usuário não possua nenhum compromisso iminente.
final homeUpcomingAlertProvider = Provider<UpcomingAlertData?>((ref) {
  // 1. Contas atrasadas (prioridade máxima)
  final overdueBills = ref.watch(overdueBillsProvider);
  if (overdueBills.isNotEmpty) {
    final first = overdueBills.first;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = today
        .difference(DateTime(first.date.year, first.date.month, first.date.day))
        .inDays;
    return UpcomingAlertData(
      title: 'Conta em atraso: ${first.description}',
      description:
          'Venceu há $days dia(s) no valor de ${first.amount.formatted}.',
      badgeText: 'Atrasada',
      icon: Icons.warning_amber_rounded,
    );
  }

  // 2. Faturas de cartões de crédito que fecham nos próximos 7 dias
  final cards = ref.watch(cardsListProvider).value ?? const [];
  if (cards.isNotEmpty) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final card in cards) {
      final thisMonthClosing = DateTime(now.year, now.month, card.closingDay);
      DateTime nextClosing;
      if (!thisMonthClosing.isBefore(today)) {
        nextClosing = thisMonthClosing;
      } else {
        final nextMonth = now.month == 12 ? 1 : now.month + 1;
        final nextYear = now.month == 12 ? now.year + 1 : now.year;
        nextClosing = DateTime(nextYear, nextMonth, card.closingDay);
      }

      final diffDays = nextClosing.difference(today).inDays;
      if (diffDays >= 0 && diffDays <= 7) {
        final invoice = ref.watch(currentInvoiceProvider).value;
        final amountText = invoice != null
            ? ' no valor de ${invoice.totalAmount.formatted}'
            : '';
        final daysText = diffDays == 0
            ? 'hoje'
            : (diffDays == 1 ? 'amanhã' : 'em $diffDays dias');

        return UpcomingAlertData(
          title: 'Fatura ${card.name} fecha $daysText',
          description:
              'Estimativa atual$amountText. Revise os lançamentos antes do fechamento.',
          badgeText: diffDays == 0 ? 'Hoje' : '$diffDays dias',
          icon: Icons.credit_card,
        );
      }
    }
  }

  // 3. Contas a vencer nos próximos 5 dias
  final upcomingBills = ref.watch(upcomingBillsProvider);
  if (upcomingBills.isNotEmpty) {
    final first = upcomingBills.first;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final billDate = DateTime(first.date.year, first.date.month, first.date.day);
    final diffDays = billDate.difference(today).inDays;
    if (diffDays <= 5) {
      final daysText = diffDays == 0
          ? 'hoje'
          : (diffDays == 1 ? 'amanhã' : 'em $diffDays dias');
      return UpcomingAlertData(
        title: 'Conta a vencer: ${first.description}',
        description:
            'Vencimento $daysText no valor de ${first.amount.formatted}.',
        badgeText: diffDays == 0 ? 'Hoje' : '$diffDays dias',
        icon: Icons.calendar_today_outlined,
      );
    }
  }

  return null;
});
