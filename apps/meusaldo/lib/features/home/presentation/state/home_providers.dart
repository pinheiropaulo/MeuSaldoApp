import 'package:flutter_riverpod/flutter_riverpod.dart';

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
