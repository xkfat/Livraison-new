/// Base custom exception class
class CustomException implements Exception {
  final dynamic _message;
  final dynamic _prefix;
  
  CustomException([this._message, this._prefix]);
  
  @override
  String toString() {
    return '$_prefix: $_message';
  }
  
  String get message => _message?.toString() ?? 'Une erreur est survenue';
}

/// Network/Server errors (500)
class FetchDataException extends CustomException {
  FetchDataException([String? message])
      : super(message ?? 'Erreur de communication avec le serveur', 
              'Erreur de Communication');
}

/// Invalid request (400)
class BadRequestException extends CustomException {
  BadRequestException([message]) 
      : super(message ?? 'Requête invalide', 'Requête Invalide');
}

/// Resource not found (404)
class NotFoundException extends CustomException {
  NotFoundException([message]) 
      : super(message ?? 'Ressource introuvable', 'Non Trouvé');
}

/// Authentication errors (401)
class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) 
      : super(message ?? 'Session expirée', 'Non Autorisé');
}

/// Validation errors (422)
class InvalidInputException extends CustomException {
  InvalidInputException([String? message]) 
      : super(message ?? 'Données invalides', 'Entrée Invalide');
}

/// Network connectivity errors
class NoInternetException extends CustomException {
  NoInternetException() 
      : super('Pas de connexion Internet', 'Erreur de Connexion');
}

/// Timeout errors
class TimeoutException extends CustomException {
  TimeoutException() 
      : super('Délai d\'attente dépassé', 'Timeout');
}

/// Failure class for detailed error information
class Failure {
  final int? code;
  final String? message;
  final Map<String, dynamic>? details;
  
  Failure({
    this.message, 
    this.code,
    this.details,
  });
  
  @override
  String toString() => message ?? 'Une erreur est survenue';
  
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
    return message ?? 'Une erreur est survenue';
  }
}