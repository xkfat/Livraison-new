import '../services/api_service.dart';
import '../models/tracking_model.dart';

class LocationRepository {
  final ApiService _apiService;

  LocationRepository(this._apiService);

  /// Update driver's current location
  /// Should be called every 5 seconds when driver is active
  Future<void> updateDriverLocation(double lat, double lng) async {
    await _apiService.post(
      '/driver/location/',
      body: {
        'lat': lat,
        'lng': lng,
      },
    );
  }

  /// Track a commande by tracking ID (public endpoint, no auth needed)
  Future<TrackingModel> trackCommande(String trackingId) async {
    final response = await _apiService.get(
      '/track/$trackingId/',
      needsAuth: false,
    );
    return TrackingModel.fromJson(response);
  }
}