import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/dataproviders/exception.dart';

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {
  final String message;
  ProfileSuccess(this.message);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// Cubit - IMPROVED ERROR HANDLING
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit(this._authRepository) : super(ProfileInitial());

  /// Change password - IMPROVED ERROR HANDLING
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (isClosed) return;
    
    emit(ProfileLoading());
    
    try {
      print('📱 ProfileCubit: Starting password change...');
      
      // Client-side validation
      if (oldPassword.trim().isEmpty) {
        emit(ProfileError('L\'ancien mot de passe est requis'));
        return;
      }
      
      if (newPassword.trim().isEmpty) {
        emit(ProfileError('Le nouveau mot de passe est requis'));
        return;
      }
      
      if (newPassword.length < 8) {
        emit(ProfileError('Le nouveau mot de passe doit contenir au moins 8 caractères'));
        return;
      }
      
      if (oldPassword.trim() == newPassword.trim()) {
        emit(ProfileError('Le nouveau mot de passe doit être différent de l\'ancien'));
        return;
      }
      
      // Call API - let backend handle validation and provide error messages
      final response = await _authRepository.changePassword(
        oldPassword: oldPassword.trim(),
        newPassword: newPassword.trim(),
      );
      
      // Extract success message from backend
      final message = response['message'] as String? ?? 
                     response['detail'] as String? ?? 
                     'Mot de passe modifié avec succès';
      
      print('✅ ProfileCubit: Password changed successfully');
      if (!isClosed) {
        emit(ProfileSuccess(message));
      }
      
    } on BadRequestException catch (e) {
      print('❌ ProfileCubit: Bad request - ${e.message}');
      
      // The backend error message should be displayed as-is
      // Backend should provide user-friendly error messages
      if (!isClosed) {
        emit(ProfileError(e.message));
      }
      
    } on UnauthorisedException catch (e) {
      print('❌ ProfileCubit: Unauthorized - ${e.message}');
      if (!isClosed) {
        emit(ProfileError('Session expirée. Veuillez vous reconnecter'));
      }
      
    } on NoInternetException catch (e) {
      print('❌ ProfileCubit: No internet - ${e.message}');
      if (!isClosed) {
        emit(ProfileError(e.message));
      }
      
    } on TimeoutException catch (e) {
      print('❌ ProfileCubit: Timeout - ${e.message}');
      if (!isClosed) {
        emit(ProfileError(e.message));
      }
      
    } on FetchDataException catch (e) {
      print('❌ ProfileCubit: Server error - ${e.message}');
      if (!isClosed) {
        emit(ProfileError(e.message));
      }
      
    } on CustomException catch (e) {
      print('❌ ProfileCubit: Custom error - ${e.message}');
      if (!isClosed) {
        emit(ProfileError(e.message));
      }
      
    } catch (e) {
      print('❌ ProfileCubit: Unexpected error - $e');
      if (!isClosed) {
        emit(ProfileError('Une erreur inattendue est survenue'));
      }
    }
  }

  /// Reset to initial state
  void reset() {
    if (!isClosed) {
      emit(ProfileInitial());
    }
  }
}