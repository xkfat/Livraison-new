import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../data/models/tracking_model.dart';
import '../../widgets/custom_marker_helper.dart';

class FullScreenMapScreen extends StatefulWidget {
  final LatLng driverLocation;
  final LatLng destinationLocation;
  final String driverName;
  final TrackingModel? tracking; // ✅ Optional tracking data

  const FullScreenMapScreen({
    super.key,
    required this.driverLocation,
    required this.destinationLocation,
    required this.driverName,
    this.tracking, // ✅ Accept tracking data
  });

  @override
  State<FullScreenMapScreen> createState() => _FullScreenMapScreenState();
}

class _FullScreenMapScreenState extends State<FullScreenMapScreen> {
  GoogleMapController? _mapController;

  // Custom markers
  BitmapDescriptor? _bikeMarker;
  bool _markersLoaded = false;

  // Driver location
  late LatLng _currentDriverLocation;

  @override
  void initState() {
    super.initState();
    _currentDriverLocation = widget.driverLocation;
    _loadCustomMarkers();
  }

  Future<void> _loadCustomMarkers() async {
    _bikeMarker = await CustomMarkerHelper.createTruckMarker(
      size: 130,
    );
    if (mounted) {
      setState(() {
        _markersLoaded = true;
      });
    }
  }

  Set<Marker> _createMarkers() {
    return {
      // Delivery driver
      Marker(
        markerId: const MarkerId('driver'),
        position: _currentDriverLocation,
        icon: _bikeMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title: widget.driverName,
          snippet: 'Livreur',
        ),
      ),
      // Destination
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destinationLocation,
        infoWindow: InfoWindow(
          title: 'Destination',
          snippet: widget.tracking?.adresseText ?? 'Adresse de livraison',
        ),
      ),
    };
  }

  Set<Polyline> _createRoute() {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [_currentDriverLocation, widget.destinationLocation],
        color: AppColors.primaryBlue,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  void _fitBounds() {
    if (_mapController == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _currentDriverLocation.latitude < widget.destinationLocation.latitude
            ? _currentDriverLocation.latitude
            : widget.destinationLocation.latitude,
        _currentDriverLocation.longitude < widget.destinationLocation.longitude
            ? _currentDriverLocation.longitude
            : widget.destinationLocation.longitude,
      ),
      northeast: LatLng(
        _currentDriverLocation.latitude > widget.destinationLocation.latitude
            ? _currentDriverLocation.latitude
            : widget.destinationLocation.latitude,
        _currentDriverLocation.longitude > widget.destinationLocation.longitude
            ? _currentDriverLocation.longitude
            : widget.destinationLocation.longitude,
      ),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
    );
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  // ✅ Calculate progress percentage based on status (FRONTEND)
  double _getProgressPercentage() {
    if (widget.tracking == null) return 0.75;
    
    switch (widget.tracking!.statut.toLowerCase()) {
      case 'en attente':
      case 'créé':
        return 0.25;
      case 'en collecte':
      case 'collecte':
        return 0.50;
      case 'en cours':
      case 'en transit':
        return 0.75;
      case 'livré':
      case 'delivered':
        return 1.0;
      default:
        return 0.25;
    }
  }

  // ✅ Get status display text
  String _getStatusText() {
    if (widget.tracking == null) return 'En transit';
    return widget.tracking!.statut;
  }

  // ✅ Calculate accurate ETA based on real distance and realistic speed
  String _calculateETA() {
    final distance = _calculateDistance(
      _currentDriverLocation.latitude,
      _currentDriverLocation.longitude,
      widget.destinationLocation.latitude,
      widget.destinationLocation.longitude,
    );
    
    // Urban delivery speed: 15 km/h (realistic for city delivery with traffic)
    final hours = distance / 15;
    final minutes = (hours * 60).round();
    
    if (minutes < 1) return "< 1 min";
    if (minutes > 60) return "${(minutes / 60).round()}h ${minutes % 60}min";
    return "$minutes min";
  }

  // ✅ Get remaining distance in km
  String _getRemainingDistance() {
    final distance = _calculateDistance(
      _currentDriverLocation.latitude,
      _currentDriverLocation.longitude,
      widget.destinationLocation.latitude,
      widget.destinationLocation.longitude,
    );
    
    return '${distance.toStringAsFixed(1)} km restants';
  }

  // Helper: Calculate distance between two points (in kilometers)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * math.pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _getProgressPercentage();
    final statusText = _getStatusText();
    final eta = _calculateETA(); // ✅ Calculate accurate ETA
    final remainingDistance = _getRemainingDistance(); // ✅ Get km distance

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentDriverLocation,
              zoom: 14,
            ),
            markers: _createMarkers(),
            polylines: _createRoute(),
            onMapCreated: (controller) {
              _mapController = controller;
              Future.delayed(const Duration(milliseconds: 500), _fitBounds);
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Top bar - back button
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.of(context).padding.top + 16,
                20,
                16,
              ),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),

          // Zoom controls
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 230,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _zoomIn,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.textDark,
                      size: 15,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 48,
                  color: AppColors.divider,
                ),
                GestureDetector(
                  onTap: _zoomOut,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: AppColors.textDark,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.driverName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                            // ✅ REPLACED "Votre livreur" with remaining distance
                            Text(
                              remainingDistance,
                              style: const TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              eta, // ✅ Accurate ETA based on real distance
                              style: const TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            statusText,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: AppColors.inputBackground,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _fitBounds,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Recentrer la carte'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}