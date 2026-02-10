// lib/services/location_service.dart
import 'dart:async';
import 'package:deliverli/data/repositories/location_repository.dart';
import 'package:location/location.dart';

class LocationService {
  Timer? _locationTimer;
  late Location _location;
  final LocationRepository _locationRepository; // ✅ This is correct
  
  LocationService(this._locationRepository) {
    _location = Location();
  }

  Future<bool> _checkPermissions() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }
    
    return true;
  }

  Future<void> startLocationUpdates() async {
    final hasPermission = await _checkPermissions();
    if (!hasPermission) {
      print('❌ Location permissions denied');
      return;
    }

    print('✅ Starting location updates every 5 seconds...');
    
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      try {
        final locationData = await _location.getLocation();
        
        if (locationData.latitude != null && locationData.longitude != null) {
          await _locationRepository.updateDriverLocation(
            locationData.latitude!, 
            locationData.longitude!
          );
          
          print('📍 Location updated: ${locationData.latitude}, ${locationData.longitude}');
        }
      } catch (e) {
        print('❌ Error updating location: $e');
      }
    });
  }

  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
    print('🛑 Location updates stopped');
  }
  
  bool get isTracking => _locationTimer?.isActive ?? false;
}