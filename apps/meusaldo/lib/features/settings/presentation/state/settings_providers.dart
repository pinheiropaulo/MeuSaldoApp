import 'package:flutter_riverpod/flutter_riverpod.dart';

class HideCentsNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final hideCentsProvider =
    NotifierProvider<HideCentsNotifier, bool>(HideCentsNotifier.new);

class BiometricsEnabledNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final biometricsEnabledProvider =
    NotifierProvider<BiometricsEnabledNotifier, bool>(
  BiometricsEnabledNotifier.new,
);

class InvoiceAlertsNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final invoiceAlertsEnabledProvider =
    NotifierProvider<InvoiceAlertsNotifier, bool>(
  InvoiceAlertsNotifier.new,
);

class BudgetAlertsNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void set(bool value) => state = value;
  void toggle() => state = !state;
}

final budgetAlertsEnabledProvider =
    NotifierProvider<BudgetAlertsNotifier, bool>(BudgetAlertsNotifier.new);

class StartDayOfMonthNotifier extends Notifier<int> {
  @override
  int build() => 1;
  void set(int day) => state = day;
}

final startDayOfMonthProvider =
    NotifierProvider<StartDayOfMonthNotifier, int>(
  StartDayOfMonthNotifier.new,
);
