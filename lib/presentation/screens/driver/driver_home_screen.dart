import 'package:deliverli/data/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/auth/auth_cubit.dart';
import '../../../logic/cubit/auth/auth_state.dart';
import '../../../logic/cubit/commande/commande_cubit.dart';
import '../../../logic/cubit/commande/commande_state.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/services/location_service.dart';
import 'delivery_details_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  // ✅ Location service for 5-second updates
  LocationService? _locationService;
  
  @override
  void initState() {
    super.initState();
    
    // Wait a split second for the provider tree to stabilize
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final authState = context.read<AuthCubit>().state;
        
        if (authState is AuthAuthenticated) {
          // Double check synchronization
          context.read<ApiService>().setTokens(authState.accessToken, authState.refreshToken);
          
          print('📦 MainScreen: Loading commandes for ${authState.user.username}');
          context.read<CommandeCubit>().loadTodayCommandes();
        }
      }
    });
  }

  // ✅ Start location tracking when driver becomes available
  void _startLocationTracking() async {
    try {
      if (_locationService == null) {
        // Create ApiService instance
        final apiService = ApiService();
        final locationRepository = LocationRepository(apiService);
        _locationService = LocationService(locationRepository);
      }
      
      await _locationService!.startLocationUpdates();
      print('📍 Location tracking started');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }

  // ✅ Stop location tracking when driver becomes unavailable
  void _stopLocationTracking() {
    if (_locationService != null) {
      _locationService!.stopLocationUpdates();
      print('🛑 Location tracking stopped');
    }
  }

  @override
  void dispose() {
    // ✅ Always stop location tracking when screen is disposed
    _stopLocationTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: RefreshIndicator(
        onRefresh: () => context.read<CommandeCubit>().loadTodayCommandes(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),

            // Stats Cards
            SliverToBoxAdapter(
              child: _buildStatsCards(),
            ),

            // Section Title
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  "Mes livraisons aujourd'hui",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),

            // Deliveries List
            BlocBuilder<CommandeCubit, CommandeState>(
              builder: (context, state) {
                if (state is CommandeLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  );
                }

                if (state is CommandeError) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CommandeCubit>().loadTodayCommandes();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is CommandeLoaded) {
                  if (state.commandes.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Aucune livraison pour aujourd'hui",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final commande = state.commandes[index];
                          return _buildDeliveryCard(commande);
                        },
                        childCount: state.commandes.length,
                      ),
                    ),
                  );
                }

                return const SliverFillRemaining(
                  child: SizedBox(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox();

        final user = state.user;
        
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 20,
            20,
            20,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bonjour,',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Availability Toggle with location tracking
                  _buildAvailabilityToggle(user),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Availability toggle with location tracking
  Widget _buildAvailabilityToggle(user) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox();
        
        final currentUser = state.user;
        final isAvailable = currentUser.isAvailable;

        return InkWell(
          onTap: () async {
            print('🔄 Toggling availability from $isAvailable to ${!isAvailable}');
            
            // ✅ Handle location tracking based on availability
            if (!isAvailable) {
              // Driver becoming available - start location tracking
              _startLocationTracking();
            } else {
              // Driver becoming unavailable - stop location tracking
              _stopLocationTracking();
            }
            
            // Toggle availability
            await context.read<AuthCubit>().toggleAvailability(!isAvailable);
            
            // Show feedback
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    !isAvailable
                        ? 'Vous êtes maintenant disponible - Localisation activée'
                        : 'Vous êtes maintenant indisponible - Localisation désactivée',
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: !isAvailable
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFF10B981)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAvailable ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  isAvailable ? 'Disponible' : 'Indisponible',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<CommandeCubit, CommandeState>(
      builder: (context, state) {
        int enAttente = 0;
        int enCours = 0;
        int livre = 0;

        if (state is CommandeLoaded) {
          enAttente = state.totalEnAttente;
          enCours = state.totalEnCours;
          livre = state.totalLivre;
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'En attente',
                  '$enAttente',
                  const Color(0xFFF59E0B),
                  Icons.schedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En cours',
                  '$enCours',
                  const Color(0xFF3B82F6),
                  Icons.local_shipping,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Livrées',
                  '$livre',
                  const Color(0xFF10B981),
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(commande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeliveryDetailScreen(
                  commande: commande,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 60,
                      decoration: BoxDecoration(
                        color: commande.statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                commande.trackingId,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              if (commande.estFragile) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '⚠️',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Fragile',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFFF59E0B),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  commande.clientName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1F2937),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  commande.adresseText,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: commande.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                commande.statusIcon,
                                size: 14,
                                color: commande.statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                commande.statut,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: commande.statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${commande.montant.toStringAsFixed(2)} DH',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Action buttons
                if (commande.statut != 'Livré' && commande.statut != 'Annulé') ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (commande.statut == 'En attente')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<CommandeCubit>().updateStatus(
                                commande.id,
                                'En cours',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Commencer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (commande.statut == 'En cours')
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _showDeliveryConfirmation(commande);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Marquer comme livré',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeliveryConfirmation(commande) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirmer la livraison'),
        content: Text(
          'Confirmer que le colis ${commande.trackingId} a été livré à ${commande.clientName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommandeCubit>().updateStatus(
                commande.id,
                'Livré',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Livraison confirmée'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}