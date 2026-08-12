abstract class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  DatabaseFailure(super.message);
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}

class NotFoundFailure extends Failure {
  NotFoundFailure(super.message);
}
