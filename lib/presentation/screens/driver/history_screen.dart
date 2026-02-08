import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../logic/cubit/commande/commande_cubit.dart';
import '../../../logic/cubit/commande/commande_state.dart';
import '../../../data/models/commande_model.dart';
import 'delivery_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'tous';

  @override
  void initState() {
    super.initState();
    // Load all commandes (including history)
    context.read<CommandeCubit>().loadCommandes();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommandeCubit, CommandeState>(
      builder: (context, state) {
        if (state is CommandeLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF3F4F6),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            ),
          );
        }

        if (state is CommandeError) {
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
                      onPressed: () {
                        context.read<CommandeCubit>().loadCommandes();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is CommandeLoaded) {
          // Get delivered and cancelled commandes
          final deliveredCommandes = state.livre;
          final cancelledCommandes = state.annule;
          final allHistory = [...deliveredCommandes, ...cancelledCommandes];

          // Filter based on selection
          List<CommandeModel> filteredDeliveries;
          if (_selectedFilter == 'livre') {
            filteredDeliveries = deliveredCommandes;
          } else if (_selectedFilter == 'annule') {
            filteredDeliveries = cancelledCommandes;
          } else {
            filteredDeliveries = allHistory;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF3F4F6),
            body: Column(
              children: [
                // Header
                _buildHeader(
                  totalDelivered: deliveredCommandes.length,
                  totalCancelled: cancelledCommandes.length,
                  totalAll: allHistory.length,
                ),

                // List header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getFilterTitle(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${filteredDeliveries.length} colis',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Deliveries list
                Expanded(
                  child: filteredDeliveries.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Aucune livraison trouvée',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: filteredDeliveries.length,
                          itemBuilder: (context, index) {
                            return _buildDeliveryCard(
                              filteredDeliveries[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return const Scaffold(
          backgroundColor: Color(0xFFF3F4F6),
          body: Center(child: Text('Chargement...')),
        );
      },
    );
  }

  Widget _buildHeader({
    required int totalDelivered,
    required int totalCancelled,
    required int totalAll,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Historique',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vos livraisons passées',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),

          // Clickable summary cards
          Row(
            children: [
              _buildFilterCard(
                filterValue: 'livre',
                icon: Icons.check_circle_outline,
                count: totalDelivered,
                label: 'Livrées',
              ),
              const SizedBox(width: 12),
              _buildFilterCard(
                filterValue: 'annule',
                icon: Icons.cancel_outlined,
                count: totalCancelled,
                label: 'Annulées',
              ),
              const SizedBox(width: 12),
              _buildFilterCard(
                filterValue: 'tous',
                icon: Icons.inventory_2_outlined,
                count: totalAll,
                label: 'Total',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard({
    required String filterValue,
    required IconData icon,
    required int count,
    required String label,
  }) {
    final isSelected = _selectedFilter == filterValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = filterValue;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : Colors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF2563EB).withOpacity(0.8)
                      : Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryCard(CommandeModel commande) {
    final statusColor = _getStatusColor(commande.statut);

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
                builder: (_) => DeliveryDetailScreen(
                  commande: commande,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row - ID, date and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            commande.formattedDate,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            commande.statusIcon,
                            size: 14,
                            color: statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            commande.statut,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Client info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF2563EB).withOpacity(0.1),
                      child: const Icon(
                        Icons.person,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commande.clientName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            commande.adresseText,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Color(0xFFE5E7EB), height: 1),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (commande.statut == 'Livré')
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Livré ${commande.formattedDeliveryDate ?? ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Annulé',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    Text(
                      '${commande.montant.toStringAsFixed(2)} DH',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Livré':
        return const Color(0xFF10B981);
      case 'Annulé':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getFilterTitle() {
    switch (_selectedFilter) {
      case 'livre':
        return 'Livrées';
      case 'annule':
        return 'Annulées';
      default:
        return 'Toutes les livraisons';
    }
  }
}