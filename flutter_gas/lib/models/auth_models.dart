class LoginResponse {
  final String accessToken;
  final String tokenType;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final List<String> devices;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.devices = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['created_at']),
      devices: List<String>.from(json['devices'] ?? []),
    );
  }
} 