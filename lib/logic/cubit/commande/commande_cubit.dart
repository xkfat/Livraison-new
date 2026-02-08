import 'package:flutter_bloc/flutter_bloc.dart';
import 'commande_state.dart';
import '../../../data/repositories/commande_repository.dart';
import '../../../data/dataproviders/exception.dart';

class CommandeCubit extends Cubit<CommandeState> {
  final CommandeRepository _commandeRepository;

  CommandeCubit(this._commandeRepository) : super(CommandeInitial());

  /// Load all commandes
  Future<void> loadCommandes() async {
    emit(CommandeLoading());
    try {
      final commandes = await _commandeRepository.getCommandes();
      emit(CommandeLoaded(commandes));
    } on NoInternetException catch (e) {
      emit(CommandeError(e.message));
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
    } catch (e) {
      emit(CommandeError('Erreur de chargement des commandes'));
    }
  }

  /// Load today's commandes
  Future<void> loadTodayCommandes() async {
    emit(CommandeLoading());
    try {
      final commandes = await _commandeRepository.getTodayCommandes();
      emit(CommandeLoaded(commandes));
    } on NoInternetException catch (e) {
      emit(CommandeError(e.message));
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
    } catch (e) {
      emit(CommandeError('Erreur de chargement'));
    }
  }

  /// Load commandes by status
  Future<void> loadCommandesByStatus(String status) async {
    emit(CommandeLoading());
    try {
      final commandes = await _commandeRepository.getCommandesByStatus(status);
      emit(CommandeLoaded(commandes));
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
    } catch (e) {
      emit(CommandeError('Erreur de chargement'));
    }
  }

  /// Load commandes by date
  Future<void> loadCommandesByDate(DateTime date) async {
    emit(CommandeLoading());
    try {
      final commandes = await _commandeRepository.getCommandesByDate(date);
      emit(CommandeLoaded(commandes));
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
    } catch (e) {
      emit(CommandeError('Erreur de chargement'));
    }
  }

  /// Update status (for driver)
  Future<void> updateStatus(int commandeId, String newStatus) async {
    final previousState = state;
    emit(CommandeStatusUpdating());
    
    try {
      await _commandeRepository.updateCommandeStatus(commandeId, newStatus);
      
      // Reload commandes after update
      await loadCommandes();
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
      // Restore previous state after showing error
      Future.delayed(const Duration(seconds: 2), () {
        if (previousState is CommandeLoaded) {
          emit(previousState);
        }
      });
    } catch (e) {
      emit(CommandeError('Erreur de mise à jour'));
      Future.delayed(const Duration(seconds: 2), () {
        if (previousState is CommandeLoaded) {
          emit(previousState);
        }
      });
    }
  }

  /// Refresh commandes
  Future<void> refresh() async {
    await loadCommandes();
  }

  /// Get single commande
  Future<void> loadCommande(int id) async {
    emit(CommandeLoading());
    try {
      final commande = await _commandeRepository.getCommande(id);
      emit(CommandeLoaded([commande]));
    } on NotFoundException catch (e) {
      emit(CommandeError(e.message));
    } on CustomException catch (e) {
      emit(CommandeError(e.message));
    } catch (e) {
      emit(CommandeError('Erreur de chargement'));
    }
  }
}