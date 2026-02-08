class Livreur {
  final int id;
  final String username;
  final String phone;
  final double? currentLat;
  final double? currentLng;
  final String vehicleInfo;

  Livreur({
    required this.id,
    required this.username,
    required this.phone,
    this.currentLat,
    this.currentLng,
    required this.vehicleInfo,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    // Handle cases where the API might return null for location
    return Livreur(
      id: json['id'] ?? 0,
      username: json['username'] ?? 'Livreur',
      phone: json['phone'] ?? '',
      currentLat: json['current_lat'] != null 
          ? double.tryParse(json['current_lat'].toString()) 
          : null,
      currentLng: json['current_long'] != null 
          ? double.tryParse(json['current_long'].toString()) 
          : null,
      vehicleInfo: json['vehicle_info'] ?? '',
    );
  }
}