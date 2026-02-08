import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/commande_model.dart';
import 'status_badge.dart';

class CommandeCard extends StatelessWidget {
  final CommandeModel commande;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const CommandeCard({
    Key? key,
    required this.commande,
    this.onTap,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with tracking ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      commande.trackingId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  StatusBadge(commande: commande),
                ],
              ),
              const SizedBox(height: 12),
              
              // Client info
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commande.clientName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Phone
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Text(
                    commande.clientPhone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Address
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      commande.adresseText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              // Parcel details if fragile
              if (commande.estFragile) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.warning, size: 14, color: AppColors.warning),
                      SizedBox(width: 4),
                      Text(
                        'Fragile',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Footer with amount and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Montant',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        '${commande.montant.toStringAsFixed(2)} DH',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  if (actionButton != null) actionButton!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}