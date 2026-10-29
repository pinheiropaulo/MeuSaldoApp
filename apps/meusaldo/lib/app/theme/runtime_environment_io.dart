import 'dart:io';

/// Identifica a execução de testes no Dart VM sem expor `dart:io` à Web.
bool get isRunningInFlutterTest =>
    Platform.environment.containsKey('FLUTTER_TEST');
