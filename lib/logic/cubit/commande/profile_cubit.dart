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

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepository _authRepository;

  ProfileCubit(this._authRepository) : super(ProfileInitial());

  /// Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(ProfileLoading());
    
    try {
      print('📱 ProfileCubit: Starting password change...');
      
      // Validate inputs
      if (oldPassword.isEmpty) {
        emit(ProfileError('L\'ancien mot de passe est requis'));
        return;
      }
      
      if (newPassword.isEmpty) {
        emit(ProfileError('Le nouveau mot de passe est requis'));
        return;
      }
      
      if (newPassword.length < 8) {
        emit(ProfileError('Le nouveau mot de passe doit contenir au moins 8 caractères'));
        return;
      }
      
      if (oldPassword == newPassword) {
        emit(ProfileError('Le nouveau mot de passe doit être différent de l\'ancien'));
        return;
      }
      
      // Call API
      final response = await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      
      final message = response['message'] as String? ?? 'Mot de passe modifié avec succès';
      
      print('✅ ProfileCubit: Password changed successfully');
      emit(ProfileSuccess(message));
      
    } on BadRequestException catch (e) {
      print('❌ ProfileCubit: Bad request - ${e.message}');
      
      // Parse error message from Django
      String errorMsg = e.message;
      if (errorMsg.contains('incorrect')) {
        errorMsg = 'Ancien mot de passe incorrect';
      } else if (errorMsg.contains('8 caractères')) {
        errorMsg = 'Le nouveau mot de passe doit contenir au moins 8 caractères';
      }
      
      emit(ProfileError(errorMsg));
      
    } on UnauthorisedException catch (e) {
      print('❌ ProfileCubit: Unauthorized - ${e.message}');
      emit(ProfileError('Session expirée. Veuillez vous reconnecter'));
      
    } catch (e) {
      print('❌ ProfileCubit: Unexpected error - $e');
      emit(ProfileError('Erreur lors du changement de mot de passe'));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(ProfileInitial());
  }
}