enum ExceptionType { internetFailure, somethingWentWrong }

class ServerException implements Exception {
  String exceptionMessage;
  ServerException(this.exceptionMessage);

  @override
  String toString() => exceptionMessage;
}

class CacheException implements Exception {
  String exceptionMessage;
  CacheException(this.exceptionMessage);

  @override
  String toString() => exceptionMessage;
}

class UnauthenticatedException implements Exception {
  String exceptionMessage;
  UnauthenticatedException(this.exceptionMessage);

  @override
  String toString() => exceptionMessage;
}
