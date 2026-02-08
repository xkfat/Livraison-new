class TrackingModel {
  final String trackingId;
  final String statut;
  final String? clientName;
  final String? adresseText;
  final DateTime? dateCreation;
  final double? montant;
  final String? livreurName;
  final String? livreurPhone;
  final double? livreurLat;
  final double? livreurLong;

  TrackingModel({
    required this.trackingId,
    required this.statut,
    this.clientName,
    this.adresseText,
    this.dateCreation,
    this.montant,
    this.livreurName,
    this.livreurPhone,
    this.livreurLat,
    this.livreurLong,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      trackingId: json['tracking_id'] as String,
      statut: json['statut'] as String,
      clientName: json['client_name'] as String?,
      adresseText: json['adresse_text'] as String?,
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'] as String)
          : null,
      montant: json['montant'] != null 
          ? double.parse(json['montant'].toString())
          : null,
      livreurName: json['livreur_name'] as String?,
      livreurPhone: json['livreur_phone'] as String?,
      livreurLat: json['livreur_lat'] != null 
          ? double.parse(json['livreur_lat'].toString()) 
          : null,
      livreurLong: json['livreur_long'] != null 
          ? double.parse(json['livreur_long'].toString()) 
          : null,
    );
  }

  // Check if driver location is available
  bool get hasDriverLocation => livreurLat != null && livreurLong != null;

  // Check if delivery is in progress
  bool get isInProgress => statut == 'En cours';

  // Check if delivered
  bool get isDelivered => statut == 'Livré';
}