class UserModel {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String role;
  final bool isAvailable;
  final String? vehicleInfo;
  final double? currentLat;
  final double? currentLong;
  final String? profilePhotoUrl;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.role,
    this.isAvailable = true,
    this.vehicleInfo,
    this.currentLat,
    this.currentLong,
    this.profilePhotoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      vehicleInfo: json['vehicle_info'] as String?,
      currentLat: json['current_lat'] != null 
          ? double.parse(json['current_lat'].toString()) 
          : null,
      currentLong: json['current_long'] != null 
          ? double.parse(json['current_long'].toString()) 
          : null,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'is_available': isAvailable,
      'vehicle_info': vehicleInfo,
      'current_lat': currentLat,
      'current_long': currentLong,
      'profile_photo_url': profilePhotoUrl,
    };
  }

  // --- Getters de Rôles (Insensibles à la casse) ---
  
  // Correction cruciale : on compare en majuscules pour correspondre à "Livreur", "LIVREUR" ou "livreur"
  bool get isDriver => role.toUpperCase() == 'LIVREUR';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';
  bool get isGestionnaire => role.toUpperCase() == 'GESTIONNAIRE';
  bool get isClient => role.toUpperCase() == 'CLIENT';

  // --- Getters d'Affichage ---

  String get displayName => username;

  // Récupère les initiales (ex: "John Doe" -> "JD", "Vatimetou" -> "V")
  String get initials {
    if (username.isEmpty) return "?";
    final parts = username.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username.substring(0, 1).toUpperCase();
  }

  // --- Méthode CopyWith ---

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    String? role,
    bool? isAvailable,
    String? vehicleInfo,
    double? currentLat,
    double? currentLong,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isAvailable: isAvailable ?? this.isAvailable,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      currentLat: currentLat ?? this.currentLat,
      currentLong: currentLong ?? this.currentLong,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}