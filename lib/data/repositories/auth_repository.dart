import 'package:deliverli/data/dataproviders/exception.dart';

import '../services/api_service.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login with username and password
/// Login with username and password
Future<Map<String, dynamic>> login(String username, String password) async {
  try {
    print('🔐 Attempting login for user: $username');
    
    final response = await _apiService.post(
      '/auth/login/',
      body: {
        'username': username,
        'password': password,
      },
      needsAuth: false,
    );

    print('✅ Login successful');
    
    // Validate response has required fields
    if (response['access'] == null || response['refresh'] == null) {
      throw FetchDataException('Invalid response from server');
    }

    // Store tokens in API service
    _apiService.setTokens(response['access'], response['refresh']);
    
    print('✅ Tokens stored in API service');

    return response;
    
  } on UnauthorisedException catch (e) {
    print('❌ Login failed - Unauthorized: ${e.message}');
    rethrow; // Re-throw to be caught by Cubit
  } on BadRequestException catch (e) {
    print('❌ Login failed - Bad Request: ${e.message}');
    rethrow;
  } on NoInternetException catch (e) {
    print('❌ Login failed - No Internet: ${e.message}');
    rethrow;
  } catch (e) {
    print('❌ Login failed - Unknown error: $e');
    throw FetchDataException('Erreur de connexion au serveur');
  }
}
  /// Get current user profile
  Future<UserModel> getUserProfile() async {
    final response = await _apiService.get('/auth/profile/');
    return UserModel.fromJson(response);
  }

  /// Logout
  Future<void> logout() async {
    _apiService.clearTokens();
  }

  /// Update availability (for drivers)
  Future<void> updateAvailability(bool isAvailable) async {
    await _apiService.patch(
      '/driver/availability/',
      body: {'is_available': isAvailable},
    );
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 AuthRepository: Attempting to change password...');
      
      final response = await _apiService.post(
        '/auth/change-password/',
        body: {
          'old_password': oldPassword,  // ✅ Match Django field names exactly
          'new_password': newPassword,
        },
        needsAuth: true,  // ✅ Authentication required
      );

      print('✅ Password changed successfully');
      return response as Map<String, dynamic>;
    } on BadRequestException catch (e) {
      print('❌ Change password failed - Bad Request: ${e.message}');
      rethrow;
    } on UnauthorisedException catch (e) {
      print('❌ Change password failed - Unauthorized: ${e.message}');
      rethrow;
    } catch (e) {
      print('❌ Change password failed - Error: $e');
      throw FetchDataException('Erreur lors du changement de mot de passe');
    }
  }


  /// Upload profile photo
  Future<String> uploadProfilePhoto(File photoFile) async {
    final response = await _apiService.uploadFile(
      '/auth/profile/photo/',
      photoFile,
      fileField: 'profile_photo',
    );
    return response['profile_photo_url'] as String;
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto() async {
    await _apiService.delete('/auth/profile/photo/');
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _apiService.isAuthenticated;
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    return await _apiService.refreshAccessToken();
  }

  /// Set tokens (for auto-login)
  void setTokens(String accessToken, String refreshToken) {
    _apiService.setTokens(accessToken, refreshToken);
  }
}