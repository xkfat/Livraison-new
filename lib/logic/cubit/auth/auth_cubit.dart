import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/dataproviders/exception.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Login with username and password
  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final loginResponse = await _authRepository.login(username, password);
      final user = await _authRepository.getUserProfile();

      // Save tokens to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', loginResponse['access']);
      await prefs.setString('refresh_token', loginResponse['refresh']);

      emit(AuthAuthenticated(
        user: user,
        accessToken: loginResponse['access'],
        refreshToken: loginResponse['refresh'],
      ));
    } on UnauthorisedException catch (e) {
      emit(AuthError(e.message));
    } on NoInternetException catch (e) {
      emit(AuthError(e.message));
    } on CustomException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Erreur de connexion'));
    }
  }

  /// Try auto login from saved tokens
  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken != null && refreshToken != null) {
        // Set tokens in repository
        // Note: We need to access the API service through repository
        // We'll create a method in repository for this
        
        try {
          final user = await _authRepository.getUserProfile();
          emit(AuthAuthenticated(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          ));
        } catch (e) {
          // Token might be expired, try to refresh
          final refreshed = await _authRepository.refreshToken();
          if (refreshed) {
            final user = await _authRepository.getUserProfile();
            // Get the new access token from SharedPreferences
            final newAccessToken = prefs.getString('access_token') ?? accessToken;
            
            emit(AuthAuthenticated(
              user: user,
              accessToken: newAccessToken,
              refreshToken: refreshToken,
            ));
          } else {
            emit(AuthUnauthenticated());
          }
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthUnauthenticated());
  }

  /// Toggle availability (for drivers)
  Future<void> toggleAvailability(bool isAvailable) async {
    if (state is AuthAuthenticated) {
      try {
        await _authRepository.updateAvailability(isAvailable);
        
        // Reload user profile to get updated availability
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
      } catch (e) {
        // Emit error but keep authenticated state
      }
    }
  }

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _authRepository.changePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto(File photoFile) async {
    if (state is AuthAuthenticated) {
      try {
        await _authRepository.uploadProfilePhoto(photoFile);
        
        // Reload user profile to get new photo URL
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    if (state is AuthAuthenticated) {
      try {
        await _authRepository.deleteProfilePhoto();
        
        // Reload user profile
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}