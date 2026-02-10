import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'full_screen_map.dart';
import '../../widgets/custom_marker_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/tracking/tracking_cubit.dart';
import '../../../logic/cubit/tracking/tracking_state.dart';
import '../../../data/models/tracking_model.dart';

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
    // Load tracking data when screen initializes
    context.read<TrackingCubit>().trackCommande(widget.trackingId);
  }

  Future<void> _loadCustomMarkers() async {
    _truckMarker = await CustomMarkerHelper.createTruckMarker(
      size: 80,
    );
    setState(() {
      _markersLoaded = true;
    });
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

  Future<void> _callDriver(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        _showDriverContactSheet(phoneNumber);
      }
    }
  }

  void _showDriverContactSheet(String phoneNumber) {
    final state = context.read<TrackingCubit>().state;
    String driverName = 'Livreur';
    
    if (state is TrackingLoaded) {
      driverName = state.tracking.livreurName ?? 'Livreur';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
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
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: const Icon(Icons.person, size: 36, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 12),
            Text(
              driverName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
          
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phone, color: AppColors.primaryBlue, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppColors.textDark,
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
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: AppColors.textLight, size: 20),
                            SizedBox(width: 10),
                            Text('Numéro copié dans le presse-papiers'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, color: AppColors.textLight),
                label: const Text(
                  'Copier le numéro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textLight),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Fermer',
                style: TextStyle(color: AppColors.textGrey, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _getTimelineStatus(String statut) {
    // Map backend status to timeline steps
    switch (statut.toLowerCase()) {
      case 'en attente':
      case 'créé':
        return 'created';
      case 'en collecte':
      case 'collecte':
        return 'collecting';
      case 'en cours':
      case 'en transit':
        return 'in_transit';
      case 'livré':
      case 'delivered':
        return 'delivered';
      default:
        return 'created';
    }
  }

  Widget _buildTimelineStep(
    String title,
    String time, {
    required String currentStatus,
    required String stepStatus,
    bool isFirst = false,
    bool isLast = false,
  }) {
    // Determine step state based on current order status
    final statusOrder = ['created', 'collecting', 'in_transit', 'delivered'];
    final currentIndex = statusOrder.indexOf(currentStatus);
    final stepIndex = statusOrder.indexOf(stepStatus);

    // A step is completed if it comes BEFORE the current step
    final isCompleted = stepIndex < currentIndex;
    // A step is active if it IS the current step
    final isActive = stepIndex == currentIndex;

    return Row(
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 3,
                height: 20,
                color: isCompleted ? AppColors.success : AppColors.divider,
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                // Completed = GREEN, Active = BLUE, Pending = GRAY
                color: isCompleted
                    ? AppColors.success
                    : (isActive ? AppColors.primaryBlue : AppColors.inputBackground),
                shape: BoxShape.circle,
                border: isActive
                    ? Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 4)
                    : null,
              ),
              child: Icon(
                isCompleted || isActive ? Icons.check : Icons.circle,
                size: 16,
                color: isCompleted || isActive ? AppColors.textLight : AppColors.textGrey,
              ),
            ),
            if (!isLast)
              Container(
                width: 3,
                height: 20,
                color: isCompleted ? AppColors.success : AppColors.divider,
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  // Completed = GREEN, Active = BLUE, Pending = DARK
                  color: isCompleted 
                      ? AppColors.success 
                      : (isActive ? AppColors.primaryBlue : AppColors.textDark),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  // Completed = GREEN, Active = BLUE, Pending = GREY
                  color: isCompleted
                      ? AppColors.success
                      : (isActive ? AppColors.primaryBlue : AppColors.textGrey),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: BlocConsumer<TrackingCubit, TrackingState>(
        listener: (context, state) {
          // Show error snackbar if tracking fails
          if (state is TrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.textLight),
                    const SizedBox(width: 10),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
          
          if (state is TrackingNotFound) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.search_off, color: AppColors.textLight),
                    SizedBox(width: 10),
                    Text('Numéro de suivi introuvable'),
                  ],
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // HEADER
              _buildHeader(state),

              // CONTENT
              Expanded(
                child: _buildContent(state),
              ),

              // CONTACT BUTTON
              if (state is TrackingLoaded && state.tracking.livreurPhone != null)
                _buildContactButton(state.tracking.livreurPhone!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(TrackingState state) {
    String estimatedTime = 'Chargement...';
    
    if (state is TrackingLoaded) {
      // You can calculate estimated time based on current status
      // For now, showing a default or getting from backend if available
      estimatedTime = 'En cours de livraison';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(26, 25, 20, 10),
      color: AppColors.primaryBlue,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: AppColors.textLight),
          ),
          const SizedBox(height: 25),
          Text(
            "Numéro de suivi",
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          Text(
            "Colis #${widget.trackingId}",
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            estimatedTime,
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(TrackingState state) {
    if (state is TrackingLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryBlue),
            SizedBox(height: 16),
            Text(
              'Chargement des informations...',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ],
        ),
      );
    }

    if (state is TrackingError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: AppColors.textDark),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<TrackingCubit>().trackCommande(widget.trackingId);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TrackingNotFound) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Numéro de suivi introuvable',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Vérifiez le numéro de suivi et réessayez',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TrackingLoaded) {
      return _buildLoadedContent(state.tracking);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadedContent(TrackingModel tracking) {
    // ✅ Use destination coordinates from backend, fallback to default
    final LatLng destinationLocation = tracking.hasDestinationLocation
        ? LatLng(tracking.destinationLat!, tracking.destinationLong!)
        : const LatLng(33.9716, -6.8498); // Fallback if no destination coords
    
    // ✅ Get driver location from tracking data or use default
    final LatLng driverLocation = tracking.hasDriverLocation
        ? LatLng(tracking.livreurLat!, tracking.livreurLong!)
        : const LatLng(34.020882, -6.841650); // Fallback if no driver coords

    final currentStatus = _getTimelineStatus(tracking.statut);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOOGLE MAP CARD
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenMapScreen(
                    driverLocation: driverLocation,
                    destinationLocation: destinationLocation,
                    driverName: tracking.livreurName ?? 'Livreur',
                    tracking: tracking, // ✅ Pass full tracking data
                  ),
                ),
              );
            },
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBackground, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  )
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
                    markers: _createMarkers(driverLocation, destinationLocation),
                    polylines: _createRoute(driverLocation, destinationLocation),
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
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.9),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fullscreen, color: AppColors.textLight, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Appuyez pour agrandir",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textLight,
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
            "PROGRESSION",
            style: TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),

          // Timeline card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimelineStep(
                    "Commande créée",
                    tracking.dateCreation != null
                        ? DateFormat('HH:mm').format(tracking.dateCreation!)
                        : "---",
                    currentStatus: currentStatus,
                    stepStatus: 'created',
                    isFirst: true,
                  ),
                  _buildTimelineStep(
                    "En cours de collecte",
                    tracking.dateCollecte != null
                        ? DateFormat('HH:mm').format(tracking.dateCollecte!)
                        : "---",
                    currentStatus: currentStatus,
                    stepStatus: 'collecting',
                  ),
                  _buildTimelineStep(
                    "En transit",
                    tracking.dateEnCours != null
                        ? DateFormat('HH:mm').format(tracking.dateEnCours!)
                        : "---",
                    currentStatus: currentStatus,
                    stepStatus: 'in_transit',
                  ),
                  _buildTimelineStep(
                    "Livré",
                    tracking.dateLivraison != null
                        ? DateFormat('HH:mm').format(tracking.dateLivraison!)
                        : "En attente",
                    currentStatus: currentStatus,
                    stepStatus: 'delivered',
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _callDriver(phoneNumber),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: AppColors.textLight),
              SizedBox(width: 8),
              Text(
                "Contacter le livreur",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}