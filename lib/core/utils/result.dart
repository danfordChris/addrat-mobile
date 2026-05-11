sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(String message, Exception? cause) onFailure,
  ) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final message, :final cause) => onFailure(message, cause),
    };
  }

  T? getOrNull() => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? cause;
  const Failure(this.message, [this.cause]);
}
