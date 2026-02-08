import '../services/api_service.dart';
import '../models/user_model.dart';
import 'dart:io';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Login with username and password
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _apiService.post(
      '/auth/login/',
      body: {
        'username': username,
        'password': password,
      },
      needsAuth: false,
    );

    // Store tokens in API service
    _apiService.setTokens(response['access'], response['refresh']);

    return response;
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
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _apiService.post(
      '/auth/change-password/',
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
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