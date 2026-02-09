import '../services/api_service.dart';
import '../models/commande_model.dart';

class CommandeRepository {
  final ApiService _apiService;

  CommandeRepository(this._apiService);

  /// Get all commandes (filtered by role on backend)
  Future<List<CommandeModel>> getCommandes() async {
    final response = await _apiService.get('/commandes/', needsAuth: true);
    
    if (response is List) {
      return response
          .map((json) => CommandeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Get single commande by ID
  Future<CommandeModel> getCommande(int id) async {
    final response = await _apiService.get('/commandes/$id/');
    return CommandeModel.fromJson(response);
  }

  /// Update commande status (for drivers)
  Future<void> updateCommandeStatus(int id, String newStatus) async {
    await _apiService.patch(
      '/commandes/$id/update_statut/',
      body: {'statut': newStatus},
    );
  }

  /// Get commandes by status
  Future<List<CommandeModel>> getCommandesByStatus(String status) async {
    final allCommandes = await getCommandes();
    return allCommandes.where((c) => c.statut == status).toList();
  }

  /// Get today's commandes for driver
  Future<List<CommandeModel>> getTodayCommandes() async {
    final allCommandes = await getCommandes();
    final today = DateTime.now();
    
    return allCommandes.where((c) {
      return c.dateLivraison != null &&
          c.dateLivraison!.year == today.year &&
          c.dateLivraison!.month == today.month &&
          c.dateLivraison!.day == today.day;
    }).toList();
  }

  /// Get delivery history (completed deliveries)
  Future<Map<String, dynamic>> getDeliveryHistory() async {
    final response = await _apiService.get('/commandes/history/');
    
    final deliveries = (response['deliveries'] as List)
        .map((json) => CommandeModel.fromJson(json as Map<String, dynamic>))
        .toList();
    
    return {
      'total_delivered': response['total_delivered'] as int,
      'total_revenue': response['total_revenue'] as double,
      'deliveries': deliveries,
    };
  }

  /// Get commandes for a specific date
  Future<List<CommandeModel>> getCommandesByDate(DateTime date) async {
    final allCommandes = await getCommandes();
    
    return allCommandes.where((c) {
      return c.dateLivraison != null &&
          c.dateLivraison!.year == date.year &&
          c.dateLivraison!.month == date.month &&
          c.dateLivraison!.day == date.day;
    }).toList();
  }

  /// Create new commande (for admin/gestionnaire)
  Future<CommandeModel> createCommande(Map<String, dynamic> commandeData) async {
    final response = await _apiService.post(
      '/commandes/',
      body: commandeData,
    );
    return CommandeModel.fromJson(response);
  }

  /// Update commande (for admin/gestionnaire)
  Future<CommandeModel> updateCommande(int id, Map<String, dynamic> commandeData) async {
    final response = await _apiService.patch(
      '/commandes/$id/',
      body: commandeData,
    );
    return CommandeModel.fromJson(response);
  }

  /// Delete commande (for admin/gestionnaire)
  Future<void> deleteCommande(int id) async {
    await _apiService.delete('/commandes/$id/');
  }
}