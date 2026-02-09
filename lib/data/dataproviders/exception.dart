/// Base custom exception class
class CustomException implements Exception {
  final String message;
  
  const CustomException(this.message);

  @override
  String toString() => message;
}

/// Network/Server errors (500, 502, 503)
class FetchDataException extends CustomException {
  const FetchDataException([String? message])
      : super(message ?? 'Erreur de communication avec le serveur');
}

/// Invalid request (400)
class BadRequestException extends CustomException {
  const BadRequestException([String? message])
      : super(message ?? 'Requête invalide');
}

/// Resource not found (404)
class NotFoundException extends CustomException {
  const NotFoundException([String? message])
      : super(message ?? 'Ressource introuvable');
}

/// Authentication errors (401, 403)
class UnauthorisedException extends CustomException {
  const UnauthorisedException([String? message])
      : super(message ?? 'Session expirée. Veuillez vous reconnecter.');
}

/// Validation errors (422)
class InvalidInputException extends CustomException {
  const InvalidInputException([String? message])
      : super(message ?? 'Données invalides');
}

/// Network connectivity errors
class NoInternetException extends CustomException {
  const NoInternetException([String? message])
      : super(message ?? 'Pas de connexion Internet.\nVérifiez votre connexion.');
}

/// Timeout errors
class TimeoutException extends CustomException {
  const TimeoutException([String? message])
      : super(message ?? 'Délai d\'attente dépassé');
}

/// Failure class for detailed error information
class Failure {
  final int? code;
  final String message;
  final Map<String, dynamic>? details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => message;

  /// Get user-friendly error message
  String get userMessage {
    if (details != null && details!.isNotEmpty) {
      final errors = <String>[];
      details!.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          errors.add(value.first.toString());
        } else if (value is String) {
          errors.add(value);
        }
      });
      if (errors.isNotEmpty) {
        return errors.join('\n');
      }
    }
    return message;
  }
}