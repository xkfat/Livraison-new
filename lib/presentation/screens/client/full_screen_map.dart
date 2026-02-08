import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/custom_marker_helper.dart';

class FullScreenMapScreen extends StatefulWidget {
  final LatLng driverLocation;
  final LatLng destinationLocation;
  final String driverName;

  const FullScreenMapScreen({
    super.key,
    required this.driverLocation,
    required this.destinationLocation,
    required this.driverName,
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
      ),
      // Destination
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destinationLocation,
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

  @override
  Widget build(BuildContext context) {
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
                    color: Color(0xFF1F2937),
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
                      color: Color(0xFF1F2937),
                      size: 15,
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  width: 48,
                  color: const Color(0xFFE5E7EB),
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
                      color: Color(0xFF1F2937),
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
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                        child: const Icon(
                          Icons.delivery_dining,
                          color: Color(0xFF2563EB),
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
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const Text(
                              'Arrivée estimée: 12:30',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
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
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '8 min',
                              style: TextStyle(
                                color: Color(0xFF10B981),
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
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'En transit',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '75%',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF2563EB),
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
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
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