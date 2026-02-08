import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/commande_model.dart';
import '../../../logic/cubit/commande/commande_cubit.dart';
import '../../widgets/status_badge.dart';

class DeliveryDetailScreen extends StatelessWidget {
  final CommandeModel commande;

  const DeliveryDetailScreen({
    Key? key,
    required this.commande,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Détails de la livraison'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card with Tracking ID
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Client Info Card
            _buildClientInfoCard(),
            const SizedBox(height: 16),

            // Delivery Address Card
            _buildAddressCard(),
            const SizedBox(height: 16),

            // Package Details Card
            _buildPackageDetailsCard(),
            const SizedBox(height: 16),

            // Actions
            if (!commande.isLivre && !commande.isAnnule)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Numéro de suivi',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const SizedBox(width: 6),
                    Text(
                      commande.statut,
                      style: TextStyle(
                        fontSize: 11,
                        color: commande.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            commande.trackingId,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Créé le ${commande.formattedDate}',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information client',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.person, 'Nom', commande.clientName),
          const SizedBox(height: 12),
          _buildInfoRowWithAction(
            Icons.phone,
            'Téléphone',
            commande.clientPhone,
            onTap: () => _callClient(commande.clientPhone),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Adresse de livraison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, size: 20, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  commande.adresseText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (commande.latitude != null && commande.longitude != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.map, size: 20, color: AppColors.textGrey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordonnées GPS',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        'Lat: ${commande.latitude!.toStringAsFixed(6)}\n'
                        'Lng: ${commande.longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _openMaps(commande.latitude!, commande.longitude!),
                  icon: const Icon(Icons.directions),
                  color: AppColors.primaryBlue,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails du colis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem('Poids', commande.poids),
              ),
              Expanded(
                child: _buildDetailItem('Dimensions', commande.dimensions),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Montant',
                  '${commande.montant.toStringAsFixed(2)} DH',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Fragile',
                  commande.estFragile ? 'Oui' : 'Non',
                  color: commande.estFragile ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
          if (commande.notes != null && commande.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              commande.notes!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithAction(
    IconData icon,
    String label,
    String value, {
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textGrey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.phone),
            color: AppColors.success,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.success.withOpacity(0.1),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (commande.isEnAttente) {
      return ElevatedButton(
        onPressed: () {
          context.read<CommandeCubit>().updateStatus(commande.id, 'En cours');
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusEnCours,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Commencer la livraison',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    } else if (commande.isEnCours) {
      return ElevatedButton(
        onPressed: () {
          _showDeliveryConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Marquer comme livré',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox();
  }

  void _showDeliveryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la livraison'),
        content: Text(
          'Confirmer que le colis a été livré à ${commande.clientName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommandeCubit>().updateStatus(commande.id, 'Livré');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Livraison confirmée'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  Future<void> _callClient(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    // Opens Google Maps with directions
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }
}