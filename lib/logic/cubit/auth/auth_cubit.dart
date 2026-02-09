import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/dataproviders/exception.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Login with username and password - IMPROVED ERROR HANDLING
  Future<void> login(String username, String password) async {
    if (isClosed) return;
    
    emit(AuthLoading());
    
    try {
      print('📱 AuthCubit: Starting login process...');
      
      // Validate inputs locally first
      if (username.trim().isEmpty || password.isEmpty) {
        emit(const AuthError('Veuillez remplir tous les champs'));
        return;
      }
      
      // Step 1: Login and get tokens
      final loginResponse = await _authRepository.login(username.trim(), password);
      
      final accessToken = loginResponse['access'] as String;
      final refreshToken = loginResponse['refresh'] as String;
      
      print('📱 AuthCubit: Login successful, tokens received');
      
      // Step 2: Save tokens to SharedPreferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      
      print('📱 AuthCubit: Tokens saved to SharedPreferences');
      
      // Step 3: Get user profile
      print('📱 AuthCubit: Fetching user profile...');
      final user = await _authRepository.getUserProfile();
      
      print('📱 AuthCubit: User profile loaded - ${user.username} (${user.role})');

      // Step 4: Emit authenticated state
      if (!isClosed) {
        emit(AuthAuthenticated(
          user: user,
          accessToken: accessToken,
          refreshToken: refreshToken,
        ));
      }
      
      print('✅ AuthCubit: Login complete!');
      
    } on UnauthorisedException catch (e) {
      print('❌ AuthCubit: Login failed - Unauthorized: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } on BadRequestException catch (e) {
      print('❌ AuthCubit: Login failed - Bad Request: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } on NoInternetException catch (e) {
      print('❌ AuthCubit: Login failed - No Internet: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } on FetchDataException catch (e) {
      print('❌ AuthCubit: Login failed - Server Error: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } on TimeoutException catch (e) {
      print('❌ AuthCubit: Login failed - Timeout: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } on CustomException catch (e) {
      print('❌ AuthCubit: Login failed - Custom: ${e.message}');
      if (!isClosed) emit(AuthError(e.message));
    } catch (e) {
      print('❌ AuthCubit: Login failed - Unknown error: $e');
      if (!isClosed) emit(const AuthError('Erreur de connexion inattendue'));
    }
  }

  /// Try auto login from saved tokens
  Future<void> tryAutoLogin() async {
    if (isClosed) return;
    
    try {
      print('🔄 AuthCubit: Attempting auto-login...');
      
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
          
          if (!isClosed) {
            emit(AuthAuthenticated(
              user: user,
              accessToken: accessToken,
              refreshToken: refreshToken,
            ));
          }
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
            
            if (!isClosed) {
              emit(AuthAuthenticated(
                user: user,
                accessToken: newAccessToken,
                refreshToken: refreshToken,
              ));
            }
          } else {
            print('❌ AuthCubit: Token refresh failed');
            // Refresh failed, clear tokens
            await prefs.clear();
            if (!isClosed) emit(AuthUnauthenticated());
          }
        }
      } else {
        print('📍 AuthCubit: No saved tokens found');
        if (!isClosed) emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ AuthCubit: Auto-login error - $e');
      // Clear invalid tokens
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!isClosed) emit(AuthUnauthenticated());
    }
  }

  /// Logout
  Future<void> logout() async {
    print('🔓 AuthCubit: Logging out...');
    try {
      await _authRepository.logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!isClosed) emit(AuthUnauthenticated());
      print('✅ AuthCubit: Logout complete');
    } catch (e) {
      print('⚠️ AuthCubit: Logout error (non-critical): $e');
      // Still emit unauthenticated even if logout fails
      if (!isClosed) emit(AuthUnauthenticated());
    }
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
        
        if (!isClosed) {
          emit(AuthAuthenticated(
            user: user,
            accessToken: currentState.accessToken,
            refreshToken: currentState.refreshToken,
          ));
        }
        
        print('✅ AuthCubit: Availability updated');
      } catch (e) {
        print('❌ AuthCubit: Failed to update availability - $e');
        // Could emit an error state or just ignore for availability toggle
      }
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
        
        if (!isClosed) {
          emit(AuthAuthenticated(
            user: user,
            accessToken: currentState.accessToken,
            refreshToken: currentState.refreshToken,
          ));
        }
        
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
        
        if (!isClosed) {
          emit(AuthAuthenticated(
            user: user,
            accessToken: currentState.accessToken,
            refreshToken: currentState.refreshToken,
          ));
        }
        
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