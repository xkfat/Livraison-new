import 'package:deliverli/data/dataproviders/exception.dart';

import '../services/api_service.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login with username and password - IMPROVED ERROR HANDLING
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 AuthRepository: Attempting login for user: $username');
      
      final response = await _apiService.post(
        '/auth/login/',
        body: {
          'username': username.trim(),
          'password': password,
        },
        needsAuth: false,
      );

      print('✅ AuthRepository: Login successful');
      
      // Validate response has required fields
      if (response['access'] == null || response['refresh'] == null) {
        throw FetchDataException('Réponse invalide du serveur');
      }

      // Store tokens in API service
      _apiService.setTokens(response['access'], response['refresh']);
      
      print('✅ AuthRepository: Tokens stored in API service');

      return response;
      
    } on UnauthorisedException {
      // Pass through the backend error message
      print('❌ AuthRepository: Login failed - Unauthorized');
      rethrow;
    } on BadRequestException {
      print('❌ AuthRepository: Login failed - Bad Request');
      rethrow;
    } on NoInternetException {
      print('❌ AuthRepository: Login failed - No Internet');
      rethrow;
    } on FetchDataException {
      print('❌ AuthRepository: Login failed - Server Error');
      rethrow;
    } catch (e) {
      print('❌ AuthRepository: Login failed - Unknown error: $e');
      throw FetchDataException('Erreur de connexion au serveur');
    }
  }

  /// Get current user profile
  Future<UserModel> getUserProfile() async {
    try {
      print('👤 AuthRepository: Fetching user profile...');
      final response = await _apiService.get('/auth/profile/');
      print('✅ AuthRepository: User profile fetched successfully');
      return UserModel.fromJson(response);
    } on UnauthorisedException {
      print('❌ AuthRepository: Profile fetch failed - Unauthorized');
      rethrow;
    } catch (e) {
      print('❌ AuthRepository: Profile fetch failed - $e');
      throw FetchDataException('Erreur lors de la récupération du profil');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      print('🔓 AuthRepository: Logging out...');
      // Optionally call backend logout endpoint
      // await _apiService.post('/auth/logout/', needsAuth: true);
      _apiService.clearTokens();
      print('✅ AuthRepository: Logout successful');
    } catch (e) {
      print('⚠️ AuthRepository: Logout error (non-critical): $e');
      _apiService.clearTokens(); // Clear tokens anyway
    }
  }

  /// Update availability (for drivers)
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      print('🔄 AuthRepository: Updating availability to $isAvailable...');
      await _apiService.patch(
        '/driver/availability/',
        body: {'is_available': isAvailable},
      );
      print('✅ AuthRepository: Availability updated');
    } catch (e) {
      print('❌ AuthRepository: Failed to update availability - $e');
      rethrow;
    }
  }

  /// Change password - IMPROVED ERROR HANDLING
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 AuthRepository: Attempting to change password...');
      
      final response = await _apiService.post(
        '/auth/change-password/',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        needsAuth: true,
      );

      print('✅ AuthRepository: Password changed successfully');
      return response as Map<String, dynamic>;
    } on BadRequestException {
      // Let the backend error message pass through
      print('❌ AuthRepository: Change password failed - Bad Request');
      rethrow;
    } on UnauthorisedException {
      print('❌ AuthRepository: Change password failed - Unauthorized');
      rethrow;
    } catch (e) {
      print('❌ AuthRepository: Change password failed - Error: $e');
      throw FetchDataException('Erreur lors du changement de mot de passe');
    }
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(File photoFile) async {
    try {
      print('📸 AuthRepository: Uploading profile photo...');
      final response = await _apiService.uploadFile(
        '/auth/profile/photo/',
        photoFile,
        fileField: 'profile_photo',
      );
      print('✅ AuthRepository: Profile photo uploaded');
      return response['profile_photo_url'] as String;
    } catch (e) {
      print('❌ AuthRepository: Failed to upload photo - $e');
      throw FetchDataException('Erreur lors du téléchargement de la photo');
    }
  }

  /// Delete profile photo
  Future<void> deleteProfilePhoto() async {
    try {
      print('🗑️ AuthRepository: Deleting profile photo...');
      await _apiService.delete('/auth/profile/photo/');
      print('✅ AuthRepository: Profile photo deleted');
    } catch (e) {
      print('❌ AuthRepository: Failed to delete photo - $e');
      throw FetchDataException('Erreur lors de la suppression de la photo');
    }
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    return _apiService.isAuthenticated;
  }

  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      print('🔄 AuthRepository: Refreshing token...');
      final result = await _apiService.refreshAccessToken();
      if (result) {
        print('✅ AuthRepository: Token refreshed successfully');
      } else {
        print('❌ AuthRepository: Token refresh failed');
      }
      return result;
    } catch (e) {
      print('❌ AuthRepository: Token refresh error - $e');
      return false;
    }
  }

  /// Set tokens (for auto-login)
  void setTokens(String accessToken, String refreshToken) {
    _apiService.setTokens(accessToken, refreshToken);
  }
}