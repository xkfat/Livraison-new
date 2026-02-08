import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'full_screen_map.dart';
import '../../widgets/custom_marker_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/tracking/tracking_cubit.dart';
import '../../../logic/cubit/tracking/tracking_state.dart';

class TrackingDetailsScreen extends StatefulWidget {
  final String trackingId;
  const TrackingDetailsScreen({super.key, required this.trackingId});

  @override
  State<TrackingDetailsScreen> createState() => _TrackingDetailsScreenState();
}

class _TrackingDetailsScreenState extends State<TrackingDetailsScreen> {
  // Custom markers
  BitmapDescriptor? _truckMarker;
  bool _markersLoaded = false;

  // Map controller
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    // Load tracking data from backend
    context.read<TrackingCubit>().trackCommande(widget.trackingId);
  }

  Future<void> _loadCustomMarkers() async {
    _truckMarker = await CustomMarkerHelper.createTruckMarker(
      size: 80,
    );
    if (mounted) {
      setState(() {
        _markersLoaded = true;
      });
    }
  }

  Set<Marker> _createMarkers(LatLng driverLocation, LatLng destinationLocation) {
    return {
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation,
        icon: _truckMarker ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        anchor: const Offset(0.5, 0.5),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destinationLocation,
      ),
    };
  }

  Set<Polyline> _createRoute(LatLng driverLocation, LatLng destinationLocation) {
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [driverLocation, destinationLocation],
        color: AppColors.primaryBlue,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
    };
  }

  Future<void> _callDriver(String? phoneNumber) async {
    if (phoneNumber == null) return;
    
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        _showPhoneBottomSheet(phoneNumber);
      }
    }
  }

  void _showPhoneBottomSheet(String phoneNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CircleAvatar(
              radius: 36,
              backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 36,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Votre livreur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.phone,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: phoneNumber));
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text('Numéro copié dans le presse-papiers'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, color: Colors.white),
                label: const Text(
                  'Copier le numéro',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        if (state is TrackingLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F4F6),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            ),
          );
        }

        if (state is TrackingError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TrackingNotFound) {
          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Numéro de suivi introuvable',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text('Retour'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is TrackingLoaded) {
          final tracking = state.tracking;
          
          // Use real driver location from backend
          final driverLocation = tracking.hasDriverLocation
              ? LatLng(tracking.livreurLat!, tracking.livreurLong!)
              : const LatLng(34.020882, -6.841650); // fallback

          // For destination, use a small offset from driver (you can enhance this later)
          final destinationLocation = LatLng(
            driverLocation.latitude + 0.004,
            driverLocation.longitude - 0.006,
          );

          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(26, 25, 20, 10),
                  color: const Color(0xFF2563EB),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        "Numéro de suivi",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Colis #${tracking.trackingId}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Statut: ${tracking.statut}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Google Map Card
                        if (tracking.hasDriverLocation)
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FullScreenMapScreen(
                                    driverLocation: driverLocation,
                                    destinationLocation: destinationLocation,
                                    driverName: tracking.livreurName ?? 'Votre livreur',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                children: [
                                  GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: driverLocation,
                                      zoom: 14,
                                    ),
                                    markers: _createMarkers(
                                      driverLocation,
                                      destinationLocation,
                                    ),
                                    polylines: _createRoute(
                                      driverLocation,
                                      destinationLocation,
                                    ),
                                    onMapCreated: (controller) {
                                      _mapController = controller;
                                    },
                                    zoomControlsEnabled: false,
                                    mapToolbarEnabled: false,
                                    scrollGesturesEnabled: false,
                                    zoomGesturesEnabled: false,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB).withOpacity(0.9),
                                        borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(12),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.fullscreen,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Appuyez pour agrandir",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 15),
                        const Text(
                          "INFORMATIONS",
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Info card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (tracking.clientName != null) ...[
                                    _buildInfoRow(
                                      'Client',
                                      tracking.clientName!,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (tracking.adresseText != null) ...[
                                    _buildInfoRow(
                                      'Adresse',
                                      tracking.adresseText!,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  if (tracking.montant != null) ...[
                                    _buildInfoRow(
                                      'Montant',
                                      '${tracking.montant!.toStringAsFixed(2)} DH',
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  _buildInfoRow('Statut', tracking.statut),
                                  if (tracking.livreurName != null) ...[
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      'Livreur',
                                      tracking.livreurName!,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Contact button (only if phone available)
                if (tracking.livreurPhone != null)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _callDriver(tracking.livreurPhone),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Contacter le livreur",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Chargement...')),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}