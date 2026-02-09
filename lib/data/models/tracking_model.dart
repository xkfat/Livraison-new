class TrackingModel {
  final String trackingId;
  final String statut;
  final String? clientName;
  final String? adresseText;
  final DateTime? dateCreation;
  final DateTime? dateCollecte;  // ✅ Add collection time
  final DateTime? dateEnCours;   // ✅ Add in-transit time
  final DateTime? dateLivraison; // ✅ Add delivery time
  final double? montant;
  final String? livreurName;
  final String? livreurPhone;
  final double? livreurLat;
  final double? livreurLong;
  final double? destinationLat;  // ✅ Add destination coordinates
  final double? destinationLong; // ✅ Add destination coordinates

  TrackingModel({
    required this.trackingId,
    required this.statut,
    this.clientName,
    this.adresseText,
    this.dateCreation,
    this.dateCollecte,
    this.dateEnCours,
    this.dateLivraison,
    this.montant,
    this.livreurName,
    this.livreurPhone,
    this.livreurLat,
    this.livreurLong,
    this.destinationLat,
    this.destinationLong,
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
      dateCollecte: json['date_collecte'] != null
          ? DateTime.parse(json['date_collecte'] as String)
          : null,
      dateEnCours: json['date_en_cours'] != null
          ? DateTime.parse(json['date_en_cours'] as String)
          : null,
      dateLivraison: json['date_livraison'] != null
          ? DateTime.parse(json['date_livraison'] as String)
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
      destinationLat: json['destination_lat'] != null 
          ? double.parse(json['destination_lat'].toString()) 
          : null,
      destinationLong: json['destination_long'] != null 
          ? double.parse(json['destination_long'].toString()) 
          : null,
    );
  }

  // Check if driver location is available
  bool get hasDriverLocation => livreurLat != null && livreurLong != null;

  // Check if destination location is available
  bool get hasDestinationLocation => destinationLat != null && destinationLong != null;

  // Check if delivery is in progress
  bool get isInProgress => statut == 'En cours';

  // Check if delivered
  bool get isDelivered => statut == 'Livré';
}