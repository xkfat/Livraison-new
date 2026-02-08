import 'package:equatable/equatable.dart';
import '../../../data/models/commande_model.dart';

abstract class CommandeState extends Equatable {
  const CommandeState();

  @override
  List<Object?> get props => [];
}

class CommandeInitial extends CommandeState {}

class CommandeLoading extends CommandeState {}

class CommandeLoaded extends CommandeState {
  final List<CommandeModel> commandes;

  const CommandeLoaded(this.commandes);

  @override
  List<Object?> get props => [commandes];

  // Helper getters for filtering
  List<CommandeModel> get enAttente => 
      commandes.where((c) => c.statut == 'En attente').toList();
  
  List<CommandeModel> get enCours => 
      commandes.where((c) => c.statut == 'En cours').toList();
  
  List<CommandeModel> get livre => 
      commandes.where((c) => c.statut == 'Livré').toList();
  
  List<CommandeModel> get annule => 
      commandes.where((c) => c.statut == 'Annulé').toList();
  
  // Count helpers
  int get totalEnAttente => enAttente.length;
  int get totalEnCours => enCours.length;
  int get totalLivre => livre.length;
  int get totalAnnule => annule.length;
  int get total => commandes.length;

  // Get today's deliveries
  List<CommandeModel> get todayDeliveries {
    final today = DateTime.now();
    return commandes.where((c) {
      return c.dateLivraison != null &&
          c.dateLivraison!.year == today.year &&
          c.dateLivraison!.month == today.month &&
          c.dateLivraison!.day == today.day;
    }).toList();
  }
}

class CommandeError extends CommandeState {
  final String message;

  const CommandeError(this.message);

  @override
  List<Object?> get props => [message];
}

class CommandeStatusUpdating extends CommandeState {}

class CommandeStatusUpdated extends CommandeState {
  final CommandeModel commande;

  const CommandeStatusUpdated(this.commande);

  @override
  List<Object?> get props => [commande];
}