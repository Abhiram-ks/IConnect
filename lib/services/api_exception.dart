/// Custom API Exception classes for error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'No internet connection. Please check your network.',
          statusCode: null,
        );
}

class ServerException extends ApiException {
  ServerException({String? message, super.statusCode})
      : super(
          message: message ?? 'Server error occurred. Please try again later.',
        );
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized access. Please check your credentials.',
          statusCode: 401,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Requested resource not found.',
          statusCode: 404,
        );
}

/// GraphQL-specific exception for handling Shopify Storefront API errors
class GraphQLException extends ApiException {
  final List<dynamic>? errors;
  final String? errorCode;
  final Map<String, dynamic>? extensions;
  final int? cost;
  final int? maxCost;
  final String? requestId;

  GraphQLException({
    required super.message,
    this.errors,
    this.errorCode,
    this.extensions,
    this.cost,
    this.maxCost,
    this.requestId,
    super.statusCode,
  });

  /// Factory constructor to parse GraphQL error response
  factory GraphQLException.fromResponse(Map<String, dynamic> response, {int? statusCode}) {
    final errorsList = response['errors'] as List<dynamic>?;
    
    if (errorsList == null || errorsList.isEmpty) {
      return GraphQLException(
        message: 'Unknown GraphQL error occurred',
        statusCode: statusCode,
      );
    }

    final firstError = errorsList.first as Map<String, dynamic>;
    final message = firstError['message'] as String? ?? 'GraphQL error occurred';
    final extensions = firstError['extensions'] as Map<String, dynamic>?;
    final errorCode = extensions?['code'] as String?;

    // Extract cost information for complexity errors
    final cost = extensions?['cost'] as int?;
    final maxCost = extensions?['maxCost'] as int?;

    // Extract request ID for internal errors
    String? requestId;
    if (message.contains('Request ID:')) {
      final match = RegExp(r'Request ID: ([\w-]+)').firstMatch(message);
      requestId = match?.group(1);
    }

    return GraphQLException(
      message: message,
      errors: errorsList,
      errorCode: errorCode,
      extensions: extensions,
      cost: cost,
      maxCost: maxCost,
      requestId: requestId,
      statusCode: statusCode,
    );
  }

  /// Check if this is a complexity exceeded error
  bool get isComplexityExceeded => errorCode == 'MAX_COMPLEXITY_EXCEEDED';

  /// Check if this is a throttled error
  bool get isThrottled => errorCode == 'THROTTLED';

  /// Check if this is an internal server error
  bool get isInternalError => errorCode == 'INTERNAL_SERVER_ERROR';

  /// Get user-friendly error message
  String get userFriendlyMessage {
    switch (errorCode) {
      case 'MAX_COMPLEXITY_EXCEEDED':
        return 'The request is too complex. Please try a simpler query.\n'
            'Cost: $cost / Max: $maxCost';
      case 'THROTTLED':
        return 'Too many requests. Please wait a moment and try again.';
      case 'INTERNAL_SERVER_ERROR':
        return 'Something went wrong on our end. Please try again later.\n'
            '${requestId != null ? 'Reference ID: $requestId' : ''}';
      default:
        return message;
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer('GraphQLException: $message');
    if (errorCode != null) buffer.write(' [Code: $errorCode]');
    if (cost != null && maxCost != null) {
      buffer.write(' [Cost: $cost/$maxCost]');
    }
    if (requestId != null) buffer.write(' [Request ID: $requestId]');
    return buffer.toString();
  }
}

/// Exception for when the shop is frozen (402 Payment Required)
class ShopFrozenException extends ApiException {
  ShopFrozenException({String? message})
      : super(
          message: message ?? 
              'The shop is currently unavailable. Please contact the store owner.',
          statusCode: 402,
        );
}

/// Exception for when the shop is forbidden (403)
class ShopForbiddenException extends ApiException {
  ShopForbiddenException({String? message})
      : super(
          message: message ?? 
              'Access to this shop is forbidden. The shop may be marked as fraudulent.',
          statusCode: 403,
        );
}

/// Exception for when the shop is locked (423)
class ShopLockedException extends ApiException {
  ShopLockedException({String? message})
      : super(
          message: message ?? 
              'The shop is temporarily locked. This may be due to rate limit violations.',
          statusCode: 423,
        );
}

/// Exception for Shopify security rejection (430)
class SecurityRejectionException extends ApiException {
  SecurityRejectionException({String? message})
      : super(
          message: message ?? 
              'Request rejected for security reasons. Please ensure you are not using automated tools.',
          statusCode: 430,
        );
}

/// Global exception handler for GraphQL/API responses
class ApiExceptionHandler {
  /// Parse and throw appropriate exception based on response
  static Never handleError(dynamic response, {int? statusCode}) {
    // Handle HTTP status code specific errors
    if (statusCode != null) {
      switch (statusCode) {
        case 402:
          throw ShopFrozenException();
        case 403:
          throw ShopForbiddenException();
        case 404:
          throw NotFoundException();
        case 423:
          throw ShopLockedException();
        case 430:
          throw SecurityRejectionException();
        case 401:
          throw UnauthorizedException();
        case >= 500:
          throw ServerException(
            message: 'Server error ($statusCode). Please try again later.',
            statusCode: statusCode,
          );
      }
    }

    // Handle GraphQL errors (200 OK with errors object)
    if (response is Map<String, dynamic> && response.containsKey('errors')) {
      throw GraphQLException.fromResponse(response, statusCode: statusCode);
    }

    // Handle generic bad request
    if (statusCode == 400) {
      final errorMessage = response is Map<String, dynamic> 
          ? response['errors']?.toString() ?? 'Bad request'
          : 'Bad request';
      throw ApiException(
        message: errorMessage,
        statusCode: 400,
      );
    }

    // Default error
    throw ApiException(
      message: response?.toString() ?? 'An unexpected error occurred',
      statusCode: statusCode,
    );
  }

  /// Check if response contains errors
  static bool hasErrors(dynamic response) {
    return response is Map<String, dynamic> && response.containsKey('errors');
  }

  /// Get user-friendly error message from exception
  static String getUserFriendlyMessage(dynamic error) {
    if (error is GraphQLException) {
      return error.userFriendlyMessage;
    } else if (error is NetworkException) {
      return error.message;
    } else if (error is ShopFrozenException ||
        error is ShopForbiddenException ||
        error is ShopLockedException ||
        error is SecurityRejectionException) {
      return error.message;
    } else if (error is ApiException) {
      return error.message;
    }
    return 'An unexpected error occurred. Please try again.';
  }
}

