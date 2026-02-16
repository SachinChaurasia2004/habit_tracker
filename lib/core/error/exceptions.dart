/// Base exception class for data layer errors
class CacheException implements Exception {
  final String message;
  
  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception for server/API errors (for future use)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

/// Exception for network errors (for future use)
class NetworkException implements Exception {
  final String message;
  
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception for authentication errors (for future use)
class AuthException implements Exception {
  final String message;
  
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception for validation errors
class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;
  
  ValidationException(this.message, {this.errors});

  @override
  String toString() {
    if (errors != null) {
      return 'ValidationException: $message - Errors: $errors';
    }
    return 'ValidationException: $message';
  }
}