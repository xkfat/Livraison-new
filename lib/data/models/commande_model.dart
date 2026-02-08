import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CommandeModel {
  final int id;
  final String trackingId;
  final int? livreurId;
  final String? livreurName;
  final String clientName;
  final String clientPhone;
  final String adresseText;
  final double? latitude;
  final double? longitude;
  final String poids;
  final String dimensions;
  final bool estFragile;
  final String? notes;
  final double montant;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateLivraison;
  final int ordreTournee;

  CommandeModel({
    required this.id,
    required this.trackingId,
    this.livreurId,
    this.livreurName,
    required this.clientName,
    required this.clientPhone,
    required this.adresseText,
    this.latitude,
    this.longitude,
    this.poids = '0 kg',
    this.dimensions = 'Standard',
    this.estFragile = false,
    this.notes,
    required this.montant,
    required this.statut,
    required this.dateCreation,
    this.dateLivraison,
    this.ordreTournee = 0,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: json['id'] as int,
      trackingId: json['tracking_id'] as String,
      livreurId: json['livreur'] as int?,
      livreurName: json['livreur_name'] as String?,
      clientName: json['client_name'] as String,
      clientPhone: json['client_phone'] as String,
      adresseText: json['adresse_text'] as String,
      latitude: json['latitude'] != null 
          ? double.parse(json['latitude'].toString()) 
          : null,
      longitude: json['longitude'] != null 
          ? double.parse(json['longitude'].toString()) 
          : null,
      poids: json['poids'] as String? ?? '0 kg',
      dimensions: json['dimensions'] as String? ?? 'Standard',
      estFragile: json['est_fragile'] as bool? ?? false,
      notes: json['notes'] as String?,
      montant: double.parse(json['montant'].toString()),
      statut: json['statut'] as String,
      dateCreation: DateTime.parse(json['date_creation'] as String),
      dateLivraison: json['date_livraison'] != null 
          ? DateTime.parse(json['date_livraison'] as String) 
          : null,
      ordreTournee: json['ordre_tournee'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_id': trackingId,
      'livreur': livreurId,
      'client_name': clientName,
      'client_phone': clientPhone,
      'adresse_text': adresseText,
      'latitude': latitude,
      'longitude': longitude,
      'poids': poids,
      'dimensions': dimensions,
      'est_fragile': estFragile,
      'notes': notes,
      'montant': montant,
      'statut': statut,
      'date_creation': dateCreation.toIso8601String(),
      'date_livraison': dateLivraison?.toIso8601String(),
      'ordre_tournee': ordreTournee,
    };
  }

  // Status checkers
  bool get isEnAttente => statut == 'En attente';
  bool get isEnCours => statut == 'En cours';
  bool get isLivre => statut == 'Livré';
  bool get isAnnule => statut == 'Annulé';

  // Get status color
  Color get statusColor {
    switch (statut) {
      case 'En attente':
        return AppColors.statusEnAttente;
      case 'En cours':
        return AppColors.statusEnCours;
      case 'Livré':
        return AppColors.statusLivre;
      case 'Annulé':
        return AppColors.statusAnnule;
      default:
        return AppColors.textGrey;
    }
  }

  // Get status icon
  IconData get statusIcon {
    switch (statut) {
      case 'En attente':
        return Icons.schedule;
      case 'En cours':
        return Icons.local_shipping;
      case 'Livré':
        return Icons.check_circle;
      case 'Annulé':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  // Format date for display
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(dateCreation);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${dateCreation.hour}:${dateCreation.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${dateCreation.hour}:${dateCreation.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} jours';
    } else {
      return '${dateCreation.day}/${dateCreation.month}/${dateCreation.year}';
    }
  }

  // Format delivery date
  String? get formattedDeliveryDate {
    if (dateLivraison == null) return null;
    return '${dateLivraison!.day}/${dateLivraison!.month}/${dateLivraison!.year}';
  }

  // Check if delivery is today
  bool get isToday {
    if (dateLivraison == null) return false;
    final now = DateTime.now();
    return dateLivraison!.year == now.year &&
           dateLivraison!.month == now.month &&
           dateLivraison!.day == now.day;
  }

  // Copy with method
  CommandeModel copyWith({
    int? id,
    String? trackingId,
    int? livreurId,
    String? livreurName,
    String? clientName,
    String? clientPhone,
    String? adresseText,
    double? latitude,
    double? longitude,
    String? poids,
    String? dimensions,
    bool? estFragile,
    String? notes,
    double? montant,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateLivraison,
    int? ordreTournee,
  }) {
    return CommandeModel(
      id: id ?? this.id,
      trackingId: trackingId ?? this.trackingId,
      livreurId: livreurId ?? this.livreurId,
      livreurName: livreurName ?? this.livreurName,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      adresseText: adresseText ?? this.adresseText,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      poids: poids ?? this.poids,
      dimensions: dimensions ?? this.dimensions,
      estFragile: estFragile ?? this.estFragile,
      notes: notes ?? this.notes,
      montant: montant ?? this.montant,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateLivraison: dateLivraison ?? this.dateLivraison,
      ordreTournee: ordreTournee ?? this.ordreTournee,
    );
  }
}