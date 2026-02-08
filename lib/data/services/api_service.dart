import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../dataproviders/exception.dart';

class ApiService {
  // ⚠️ IMPORTANT: CHANGE THIS TO YOUR BACKEND IP ADDRESS
  static const String baseUrl = 'http://192.168.1.100:8000/api';
  
  String? _accessToken;
  String? _refreshToken;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  // Set tokens
  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  // Clear tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  // Check if authenticated
  bool get isAuthenticated => _accessToken != null;

  // Common headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (needsAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {bool needsAuth = true}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Generic POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Generic PATCH request
  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Generic PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool needsAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint, {bool needsAuth = true}) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(needsAuth: needsAuth),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException(),
      );

      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Multipart request for file uploads
  Future<dynamic> uploadFile(
    String endpoint,
    File file, {
    String fileField = 'profile_photo',
    Map<String, String>? additionalFields,
    bool needsAuth = true,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl$endpoint'),
      );

      // Add headers
      if (needsAuth && _accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
        ),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException(),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw TimeoutException();
    } on http.ClientException {
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  // Handle HTTP response and errors
  dynamic _handleResponse(http.Response response) {
    // Parse response body
    final body = response.body.isEmpty ? '{}' : response.body;
    dynamic data;
    
    try {
      data = jsonDecode(body);
    } catch (e) {
      throw FetchDataException('Réponse invalide du serveur');
    }

    // Check if Django returned an error flag
    if (data is Map && data['error'] == true) {
      final message = data['message']?.toString();
      final details = data['details'];
      final code = data['code'] ?? response.statusCode;

      final failure = Failure(
        code: code,
        message: message,
        details: details is Map ? Map<String, dynamic>.from(details) : null,
      );

      switch (code) {
        case 400:
          throw BadRequestException(failure.userMessage);
        case 401:
          throw UnauthorisedException(failure.userMessage);
        case 403:
          throw BadRequestException(failure.userMessage);
        case 404:
          throw NotFoundException(failure.userMessage);
        case 422:
          throw InvalidInputException(failure.userMessage);
        case 500:
        default:
          throw FetchDataException(failure.userMessage);
      }
    }

    // Handle standard HTTP status codes
    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 204:
        return null;
      case 400:
        throw BadRequestException(
          data['message'] ?? 'Requête invalide'
        );
      case 401:
        throw UnauthorisedException(
          data['detail'] ?? 'Session expirée'
        );
      case 403:
        throw BadRequestException(
          data['detail'] ?? 'Accès refusé'
        );
      case 404:
        throw NotFoundException(
          data['detail'] ?? 'Ressource non trouvée'
        );
      case 422:
        throw InvalidInputException(
          data['message'] ?? 'Données invalides'
        );
      case 500:
      case 502:
      case 503:
        throw FetchDataException('Erreur serveur');
      default:
        throw FetchDataException(
          'Erreur ${response.statusCode}'
        );
    }
  }

  // Refresh access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await post(
        '/auth/refresh/',
        body: {'refresh': _refreshToken},
        needsAuth: false,
      );
      
      _accessToken = response['access'];
      return true;
    } catch (e) {
      clearTokens();
      return false;
    }
  }
}