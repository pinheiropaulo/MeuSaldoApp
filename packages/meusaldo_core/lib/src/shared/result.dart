/// Encapsula o resultado de uma operação que pode ser bem-sucedida ou falhar.
sealed class Result<S, F> {
  const Result();

  /// Cria um resultado de sucesso contendo [value].
  const factory Result.success(S value) = Success<S, F>;

  /// Cria um resultado de falha contendo [failure].
  const factory Result.failure(F failure) = FailureResult<S, F>;

  /// Indica se a operação foi bem-sucedida.
  bool get isSuccess => this is Success<S, F>;

  /// Indica se a operação falhou.
  bool get isFailure => this is FailureResult<S, F>;

  /// Retorna o valor em caso de sucesso, ou `null` em caso de falha.
  S? get valueOrNull => switch (this) {
    Success<S, F>(:final value) => value,
    FailureResult<S, F>() => null,
  };

  /// Retorna a falha em caso de insucesso, ou `null` em caso de sucesso.
  F? get failureOrNull => switch (this) {
    Success<S, F>() => null,
    FailureResult<S, F>(:final failure) => failure,
  };

  /// Executa [onSuccess] se for bem-sucedido ou [onFailure] se falhar.
  R when<R>({
    required R Function(S value) onSuccess,
    required R Function(F failure) onFailure,
  }) {
    return switch (this) {
      Success<S, F>(:final value) => onSuccess(value),
      FailureResult<S, F>(failure: final err) => onFailure(err),
    };
  }

  /// Mapeia o valor de sucesso aplicando [transform].
  Result<R, F> map<R>(R Function(S value) transform) {
    return switch (this) {
      Success<S, F>(:final value) => Result.success(transform(value)),
      FailureResult<S, F>(failure: final err) => Result.failure(err),
    };
  }

  /// Mapeia a falha aplicando [transform].
  Result<S, R> mapFailure<R>(R Function(F failure) transform) {
    return switch (this) {
      Success<S, F>(:final value) => Result.success(value),
      FailureResult<S, F>(failure: final err) => Result.failure(transform(err)),
    };
  }

  /// Encadeia outra operação que retorna [Result].
  Result<R, F> flatMap<R>(Result<R, F> Function(S value) transform) {
    return switch (this) {
      Success<S, F>(:final value) => transform(value),
      FailureResult<S, F>(failure: final err) => Result.failure(err),
    };
  }
}

/// Representação de sucesso no padrão `Result`.
final class Success<S, F> extends Result<S, F> {
  final S value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<S, F> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'Result.success($value)';
}

/// Representação de falha no padrão `Result`.
final class FailureResult<S, F> extends Result<S, F> {
  final F failure;

  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<S, F> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @override
  String toString() => 'Result.failure($failure)';
}
