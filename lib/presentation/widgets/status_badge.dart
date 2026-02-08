import 'package:flutter/material.dart';
import '../../data/models/commande_model.dart';

class StatusBadge extends StatelessWidget {
  final CommandeModel commande;
  final bool showIcon;

  const StatusBadge({
    Key? key,
    required this.commande,
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: commande.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: commande.statusColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              commande.statusIcon,
              size: 16,
              color: commande.statusColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            commande.statut,
            style: TextStyle(
              fontSize: 12,
              color: commande.statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}