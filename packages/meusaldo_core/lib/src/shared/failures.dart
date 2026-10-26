/// Classes de erro e falha do domínio financeiro.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() =>
      code != null ? 'Failure($code): $message' : 'Failure: $message';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          code == other.code;

  @override
  int get hashCode => Object.hash(runtimeType, message, code);
}

/// Falha genérica de validação de dados de entrada.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Falha quando uma entidade necessária não foi encontrada.
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Falha quando uma regra de negócio ou invariante financeira é violada.
class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure(super.message, {super.code});
}
