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
      print('📱 AuthCubit: Starting login process...');
      
      // Step 1: Login and get tokens
      final loginResponse = await _authRepository.login(username, password);
      
      final accessToken = loginResponse['access'] as String;
      final refreshToken = loginResponse['refresh'] as String;
      
      print('📱 AuthCubit: Login successful, tokens received');
      
      // Step 2: Save tokens to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      
      print('📱 AuthCubit: Tokens saved to SharedPreferences');
      
      // Step 3: Set tokens in repository (already done in login, but ensure it's set)
      _authRepository.setTokens(accessToken, refreshToken);
      
      // Step 4: Get user profile
      print('📱 AuthCubit: Fetching user profile...');
      final user = await _authRepository.getUserProfile();
      
      print('📱 AuthCubit: User profile loaded - ${user.username} (${user.role})');

      // Step 5: Emit authenticated state
      emit(AuthAuthenticated(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      ));
      
      print('✅ AuthCubit: Login complete!');
      
    } on UnauthorisedException catch (e) {
      print('❌ AuthCubit: Login failed - ${e.message}');
      emit(AuthError(e.message));
    } on BadRequestException catch (e) {
      print('❌ AuthCubit: Login failed - ${e.message}');
      emit(AuthError(e.message));
    } on NoInternetException catch (e) {
      print('❌ AuthCubit: Login failed - ${e.message}');
      emit(AuthError(e.message));
    } on FetchDataException catch (e) {
      print('❌ AuthCubit: Login failed - ${e.message}');
      emit(AuthError(e.message));
    } on CustomException catch (e) {
      print('❌ AuthCubit: Login failed - ${e.message}');
      emit(AuthError(e.message));
    } catch (e) {
      print('❌ AuthCubit: Login failed - Unknown error: $e');
      emit(const AuthError('Erreur de connexion. Veuillez réessayer'));
    }
  }

  /// Try auto login from saved tokens
  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final refreshToken = prefs.getString('refresh_token');

      if (accessToken != null && refreshToken != null) {
        print('🔄 AuthCubit: Found saved tokens, attempting auto-login...');
        
        // ✅ CRITICAL: Set tokens in ApiService BEFORE any API call
        _authRepository.setTokens(accessToken, refreshToken);
        
        try {
          final user = await _authRepository.getUserProfile();
          
          print('✅ AuthCubit: Auto-login successful - ${user.username}');
          
          emit(AuthAuthenticated(
            user: user,
            accessToken: accessToken,
            refreshToken: refreshToken,
          ));
        } catch (e) {
          print('⚠️ AuthCubit: Saved token expired, attempting refresh...');
          
          // Token might be expired, try to refresh
          final refreshed = await _authRepository.refreshToken();
          if (refreshed) {
            // Get new tokens after refresh
            final newAccessToken = prefs.getString('access_token') ?? accessToken;
            
            // ✅ Set new tokens in ApiService
            _authRepository.setTokens(newAccessToken, refreshToken);
            
            final user = await _authRepository.getUserProfile();
            
            print('✅ AuthCubit: Token refreshed successfully');
            
            emit(AuthAuthenticated(
              user: user,
              accessToken: newAccessToken,
              refreshToken: refreshToken,
            ));
          } else {
            print('❌ AuthCubit: Token refresh failed');
            // Refresh failed, clear tokens
            await prefs.clear();
            emit(AuthUnauthenticated());
          }
        }
      } else {
        print('📍 AuthCubit: No saved tokens found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ AuthCubit: Auto-login error - $e');
      // Clear invalid tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      emit(AuthUnauthenticated());
    }
  }

  /// Logout
  Future<void> logout() async {
    print('🔓 AuthCubit: Logging out...');
    await _authRepository.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AuthUnauthenticated());
    print('✅ AuthCubit: Logout complete');
  }

  /// Toggle availability (for drivers)
  Future<void> toggleAvailability(bool isAvailable) async {
    if (state is AuthAuthenticated) {
      try {
        print('🔄 AuthCubit: Updating availability to $isAvailable...');
        
        await _authRepository.updateAvailability(isAvailable);
        
        // Reload user profile to get updated availability
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
        
        print('✅ AuthCubit: Availability updated');
      } catch (e) {
        print('❌ AuthCubit: Failed to update availability - $e');
        // Emit error but keep authenticated state
      }
    }
  }

  /// Change password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      print('🔄 AuthCubit: Changing password...');
await _authRepository.changePassword(
  oldPassword: oldPassword,
  newPassword: newPassword,
);      print('✅ AuthCubit: Password changed successfully');
      return true;
    } catch (e) {
      print('❌ AuthCubit: Failed to change password - $e');
      return false;
    }
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto(File photoFile) async {
    if (state is AuthAuthenticated) {
      try {
        print('🔄 AuthCubit: Uploading profile photo...');
        
        await _authRepository.uploadProfilePhoto(photoFile);
        
        // Reload user profile to get new photo URL
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
        
        print('✅ AuthCubit: Profile photo uploaded');
        return true;
      } catch (e) {
        print('❌ AuthCubit: Failed to upload photo - $e');
        return false;
      }
    }
    return false;
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    if (state is AuthAuthenticated) {
      try {
        print('🔄 AuthCubit: Deleting profile photo...');
        
        await _authRepository.deleteProfilePhoto();
        
        // Reload user profile
        final user = await _authRepository.getUserProfile();
        final currentState = state as AuthAuthenticated;
        
        emit(AuthAuthenticated(
          user: user,
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ));
        
        print('✅ AuthCubit: Profile photo deleted');
        return true;
      } catch (e) {
        print('❌ AuthCubit: Failed to delete photo - $e');
        return false;
      }
    }
    return false;
  }
}