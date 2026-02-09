import 'package:flutter_bloc/flutter_bloc.dart';
import 'commande_state.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../../data/dataproviders/exception.dart';

class CommandeCubit extends Cubit<CommandeState> {
  final CommandeRepository _commandeRepository;

  CommandeCubit(this._commandeRepository) : super(CommandeInitial());

  /// Load all commandes - IMPROVED ERROR HANDLING
  Future<void> loadCommandes() async {
    if (isClosed) return;
    
    emit(CommandeLoading());
    try {
      print('📦 CommandeCubit: Loading all commandes...');
      final commandes = await _commandeRepository.getCommandes();
      print('✅ CommandeCubit: ${commandes.length} commandes loaded');
      
      if (!isClosed) {
        emit(CommandeLoaded(commandes));
      }
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Unauthorized - ${e.message}');
      if (!isClosed) emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
    } on NoInternetException catch (e) {
      print('❌ CommandeCubit: No internet - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on TimeoutException catch (e) {
      print('❌ CommandeCubit: Timeout - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on FetchDataException catch (e) {
      print('❌ CommandeCubit: Server error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Custom error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } catch (e) {
      print('❌ CommandeCubit: Unexpected error - $e');
      if (!isClosed) emit(CommandeError('Erreur lors du chargement des commandes'));
    }
  }

  /// Load today's commandes
  Future<void> loadTodayCommandes() async {
    if (isClosed) return;
    
    emit(CommandeLoading());
    try {
      print('📦 CommandeCubit: Loading today\'s commandes...');
      final commandes = await _commandeRepository.getTodayCommandes();
      print('✅ CommandeCubit: ${commandes.length} today\'s commandes loaded');
      
      if (!isClosed) {
        emit(CommandeLoaded(commandes));
      }
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Unauthorized - ${e.message}');
      if (!isClosed) emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
    } on NoInternetException catch (e) {
      print('❌ CommandeCubit: No internet - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on TimeoutException catch (e) {
      print('❌ CommandeCubit: Timeout - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on FetchDataException catch (e) {
      print('❌ CommandeCubit: Server error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Custom error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } catch (e) {
      print('❌ CommandeCubit: Unexpected error - $e');
      if (!isClosed) emit(CommandeError('Erreur lors du chargement'));
    }
  }

  /// Load commandes by status
  Future<void> loadCommandesByStatus(String status) async {
    if (isClosed) return;
    
    emit(CommandeLoading());
    try {
      print('📦 CommandeCubit: Loading commandes by status: $status');
      final commandes = await _commandeRepository.getCommandesByStatus(status);
      print('✅ CommandeCubit: ${commandes.length} commandes loaded for status $status');
      
      if (!isClosed) {
        emit(CommandeLoaded(commandes));
      }
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Unauthorized - ${e.message}');
      if (!isClosed) emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
    } on BadRequestException catch (e) {
      print('❌ CommandeCubit: Bad request - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Custom error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } catch (e) {
      print('❌ CommandeCubit: Unexpected error - $e');
      if (!isClosed) emit(CommandeError('Erreur lors du chargement'));
    }
  }

  /// Load commandes by date
  Future<void> loadCommandesByDate(DateTime date) async {
    if (isClosed) return;
    
    emit(CommandeLoading());
    try {
      print('📦 CommandeCubit: Loading commandes by date: ${date.toString()}');
      final commandes = await _commandeRepository.getCommandesByDate(date);
      print('✅ CommandeCubit: ${commandes.length} commandes loaded for date ${date.toString()}');
      
      if (!isClosed) {
        emit(CommandeLoaded(commandes));
      }
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Unauthorized - ${e.message}');
      if (!isClosed) emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Custom error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } catch (e) {
      print('❌ CommandeCubit: Unexpected error - $e');
      if (!isClosed) emit(CommandeError('Erreur lors du chargement'));
    }
  }

  /// Update status (for driver) - IMPROVED ERROR HANDLING
  Future<void> updateStatus(int commandeId, String newStatus) async {
    if (isClosed) return;
    
    final previousState = state;
    emit(CommandeStatusUpdating());
    
    try {
      print('🔄 CommandeCubit: Updating status for commande $commandeId to $newStatus');
      await _commandeRepository.updateCommandeStatus(commandeId, newStatus);
      print('✅ CommandeCubit: Status updated successfully');
      
      // Reload commandes after update
      await loadCommandes();
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Update failed - Unauthorized - ${e.message}');
      if (!isClosed) {
        emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
        _restorePreviousStateAfterDelay(previousState);
      }
    } on BadRequestException catch (e) {
      print('❌ CommandeCubit: Update failed - Bad request - ${e.message}');
      if (!isClosed) {
        emit(CommandeError(e.message));
        _restorePreviousStateAfterDelay(previousState);
      }
    } on NotFoundException catch (e) {
      print('❌ CommandeCubit: Update failed - Not found - ${e.message}');
      if (!isClosed) {
        emit(CommandeError('Commande introuvable'));
        _restorePreviousStateAfterDelay(previousState);
      }
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Update failed - Custom error - ${e.message}');
      if (!isClosed) {
        emit(CommandeError(e.message));
        _restorePreviousStateAfterDelay(previousState);
      }
    } catch (e) {
      print('❌ CommandeCubit: Update failed - Unexpected error - $e');
      if (!isClosed) {
        emit(CommandeError('Erreur lors de la mise à jour'));
        _restorePreviousStateAfterDelay(previousState);
      }
    }
  }

  /// Helper to restore previous state after error
  void _restorePreviousStateAfterDelay(CommandeState previousState) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!isClosed && previousState is CommandeLoaded) {
        emit(previousState);
      }
    });
  }

  /// Refresh commandes
  Future<void> refresh() async {
    await loadCommandes();
  }

  /// Get single commande - IMPROVED ERROR HANDLING
  Future<void> loadCommande(int id) async {
    if (isClosed) return;
    
    emit(CommandeLoading());
    try {
      print('📦 CommandeCubit: Loading commande $id');
      final commande = await _commandeRepository.getCommande(id);
      print('✅ CommandeCubit: Commande $id loaded');
      
      if (!isClosed) {
        emit(CommandeLoaded([commande]));
      }
    } on NotFoundException catch (e) {
      print('❌ CommandeCubit: Commande not found - ${e.message}');
      if (!isClosed) emit(CommandeError('Commande introuvable'));
    } on UnauthorisedException catch (e) {
      print('❌ CommandeCubit: Unauthorized - ${e.message}');
      if (!isClosed) emit(CommandeError('Session expirée. Veuillez vous reconnecter'));
    } on CustomException catch (e) {
      print('❌ CommandeCubit: Custom error - ${e.message}');
      if (!isClosed) emit(CommandeError(e.message));
    } catch (e) {
      print('❌ CommandeCubit: Unexpected error - $e');
      if (!isClosed) emit(CommandeError('Erreur lors du chargement'));
    }
  }
}