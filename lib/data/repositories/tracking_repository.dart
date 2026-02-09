import '../services/api_service.dart';
import '../models/tracking_model.dart'; // Import your existing model

class TrackingRepository {
  final ApiService _apiService;

  TrackingRepository(this._apiService);

  Future<TrackingModel> getTrackingDetails(String trackingId) async {
    // Calls the Django endpoint: /api/track/TRK-XXXXX/
    // needsAuth: false because usually tracking is public for the client
    final response = await _apiService.get('/track/$trackingId/', needsAuth: false);
    
    return TrackingModel.fromJson(response);
  }
}