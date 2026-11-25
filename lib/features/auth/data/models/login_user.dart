class LoginUser {
  const LoginUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
  });

  final String id;
  final String email;
  final String displayName;

  /// Admin | Partner | FeeEarner | RelationshipManager | PersonAssisting
  final String role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role,
      };

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'].toString(),
      email: json['email']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? 'FeeEarner',
    );
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.tenantId,
    required this.user,
  });

  final String token;
  final String tenantId;
  final LoginUser user;
}

class UserRole {
  const UserRole._();

  static const admin = 'Admin';
  static const partner = 'Partner';
  static const feeEarner = 'FeeEarner';
  static const relationshipManager = 'RelationshipManager';
  static const personAssisting = 'PersonAssisting';
}
