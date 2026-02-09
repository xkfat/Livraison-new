import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../dataproviders/exception.dart';

class ApiService {
  // ⚠️ IMPORTANT: CHANGE THIS TO YOUR BACKEND IP ADDRESS
  // For Android Emulator: use 10.0.2.2
  // For iOS Simulator: use 127.0.0.1
  // For real device: use your computer's local IP (check with ipconfig/ifconfig)
  //static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.XXX:8000/api'; // Real Device
  
  String? _accessToken;
  String? _refreshToken;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Timeout durations
 static const Duration requestTimeout = Duration(seconds: 10); 
  static const Duration uploadTimeout = Duration(seconds: 60);

 // Check if authenticated
  bool get isAuthenticated => _accessToken != null;

  // Set tokens
  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
    print('🔑 ApiService: Global token has been set: ${access.substring(0, 10)}...');
    print('✅ ApiService: Tokens set successfully');
  }

  // Clear tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    print('🗑️ ApiService: Tokens cleared');
  }

 
  // Common headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (needsAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
      print('🔑 ApiService: Sending request with token: ${_accessToken?.substring(0, 20)}...');
    } else if (needsAuth && _accessToken == null) {
      print('❌ ApiService: Token is NULL but auth required!');
    }
    
    return headers;
  }

  /// Generic GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _buildHeaders(headers, needsAuth);

      print('🔄 API GET: $url');

      final response = await http
          .get(url, headers: requestHeaders)
          .timeout(requestTimeout, onTimeout: () {
        throw TimeoutException('La connexion a expiré. Vérifiez votre connexion internet.');
      });

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException(
        'Impossible de se connecter au serveur.\n'
        'Vérifiez que:\n'
        '• Le serveur Django est démarré\n'
        '• Vous êtes sur le même réseau\n'
        '• L\'adresse IP est correcte'
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de connexion dépassé');
    } on http.ClientException {
      throw NoInternetException(
        'Erreur de connexion au serveur.\n'
        'Le serveur est peut-être arrêté.'
      );
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur inattendue: ${e.toString()}');
    }
  }

   /// Generic POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _buildHeaders(headers, needsAuth);

      print('🔄 API POST: $url');
      if (body != null) {
        print('📦 Request Body: ${body.keys.map((k) => k == 'password' ? '$k: ***' : '$k: ${body[k]}').join(', ')}');
      }

      final response = await http
          .post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout, onTimeout: () {
        throw TimeoutException('La connexion a expiré. Vérifiez votre connexion internet.');
      });

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException(
        'Impossible de se connecter au serveur.\n'
        'Vérifiez que:\n'
        '• Le serveur Django est démarré\n'
        '• Vous êtes sur le même réseau\n'
        '• L\'adresse IP est correcte'
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de connexion dépassé');
    } on http.ClientException {
      throw NoInternetException(
        'Erreur de connexion au serveur.\n'
        'Le serveur est peut-être arrêté.'
      );
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Generic PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _buildHeaders(headers, needsAuth);

      print('🔄 API PATCH: $url');

      final response = await http
          .patch(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout, onTimeout: () {
        throw TimeoutException('La connexion a expiré');
      });

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException(
        'Impossible de se connecter au serveur.\n'
        'Le serveur est peut-être arrêté.'
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de connexion dépassé');
    } on http.ClientException {
      throw NoInternetException('Erreur de connexion au serveur');
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur: ${e.toString()}');
    }
  }

  /// Generic PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _buildHeaders(headers, needsAuth);

      final response = await http
          .put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(requestTimeout, onTimeout: () {
        throw TimeoutException('La connexion a expiré');
      });

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException('Impossible de se connecter au serveur');
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de connexion dépassé');
    } on http.ClientException {
      throw NoInternetException('Erreur de connexion au serveur');
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur: ${e.toString()}');
    }
  }

  /// Generic DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = _buildHeaders(headers, needsAuth);

      final response = await http
          .delete(url, headers: requestHeaders)
          .timeout(requestTimeout, onTimeout: () {
        throw TimeoutException('La connexion a expiré');
      });

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException('Impossible de se connecter au serveur');
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de connexion dépassé');
    } on http.ClientException {
      throw NoInternetException('Erreur de connexion au serveur');
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur: ${e.toString()}');
    }
  }

  /// Upload file (e.g., profile photo)
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fileField = 'file',
    Map<String, String>? additionalFields,
    bool needsAuth = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('PATCH', url);

      // Add headers
      if (needsAuth && _accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fileField, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(
        uploadTimeout,
        onTimeout: () {
          throw TimeoutException('Le téléchargement a expiré');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException(
        'Impossible de se connecter au serveur.\n'
        'Vérifiez votre connexion.'
      );
    } on TimeoutException catch (e) {
      throw TimeoutException(e.message ?? 'Délai de téléchargement dépassé');
    } on http.ClientException {
      throw NoInternetException('Erreur de connexion au serveur');
    } catch (e) {
      if (e is CustomException) {
        rethrow;
      }
      throw CustomException('Erreur de téléchargement: ${e.toString()}');
    }
  }

  /// Build headers
  Map<String, String> _buildHeaders(
    Map<String, String>? customHeaders,
    bool needsAuth,
  ) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Handle HTTP response - IMPROVED ERROR HANDLING
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    print('📡 API Response: $statusCode - ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    }

    // Handle error responses - Parse backend error messages properly
    String errorMessage = 'Une erreur est survenue';
    Map<String, dynamic>? errorDetails;
    
    try {
      final errorBody = jsonDecode(response.body);
      if (errorBody is Map<String, dynamic>) {
        // Extract error details for validation errors
        errorDetails = errorBody;
        
        // Priority order for error message extraction
        if (errorBody.containsKey('detail')) {
          errorMessage = errorBody['detail'];
        } else if (errorBody.containsKey('error')) {
          errorMessage = errorBody['error'];
        } else if (errorBody.containsKey('message')) {
          errorMessage = errorBody['message'];
        } else if (errorBody.containsKey('non_field_errors')) {
          final errors = errorBody['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            errorMessage = errors.first.toString();
          }
        } else {
          // Extract first field error
          final fieldErrors = <String>[];
          errorBody.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors.add(value.first.toString());
            } else if (value is String) {
              fieldErrors.add(value);
            }
          });
          if (fieldErrors.isNotEmpty) {
            errorMessage = fieldErrors.first;
          }
        }
      }
    } catch (e) {
      errorMessage = response.body.isNotEmpty 
          ? response.body 
          : 'Erreur du serveur (${response.statusCode})';
    }

    print('🔍 API Error - Status: $statusCode, Message: $errorMessage');

    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
        // Use backend message if available, otherwise default
        if (errorMessage.contains('Invalid credentials') || 
errorMessage.contains('Unable to log in') ||
      errorMessage.contains('Incorrect') ||
      errorMessage.contains('incorrect') ||
      errorMessage.contains('No active account found')) { // <--- AJOUTEZ CECI
    throw UnauthorisedException('Nom d\'utilisateur ou mot de passe incorrect');
  
        }
        throw UnauthorisedException(errorMessage.isNotEmpty ? errorMessage : 'Session expirée. Veuillez vous reconnecter.');
      case 403:
        throw UnauthorisedException(errorMessage.isNotEmpty ? errorMessage : 'Accès refusé');
      case 404:
        throw NotFoundException(errorMessage.isNotEmpty ? errorMessage : 'Ressource non trouvée');
      case 422:
        throw InvalidInputException(errorMessage);
      case 500:
      case 502:
      case 503:
        throw FetchDataException(
          'Erreur du serveur.\n'
          'Vérifiez que le serveur Django fonctionne correctement.'
        );
      default:
        throw FetchDataException(errorMessage);
    }
  }

  /// Refresh access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await post(
        '/auth/token/refresh/',
        body: {'refresh': _refreshToken},
        needsAuth: false,
      );

      if (response['access'] != null) {
        _accessToken = response['access'];
        
        // Save new token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);
        
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}