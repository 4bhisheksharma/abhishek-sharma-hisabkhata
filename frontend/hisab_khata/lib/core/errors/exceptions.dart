enum ExceptionType {
  internetFailure,
  somethingWentWrong,
}

class ServerException implements Exception {
  String exceptionMessage;
  ServerException(
    this.exceptionMessage,
  );
}

class CacheException implements Exception {
  String exceptionMessage;
  CacheException(
    this.exceptionMessage,
  );
}

class UnauthenticatedException implements Exception {
  String exceptionMessage;
  UnauthenticatedException(
    this.exceptionMessage,
  );
}