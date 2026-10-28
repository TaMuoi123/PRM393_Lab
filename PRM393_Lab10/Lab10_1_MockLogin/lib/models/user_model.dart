class UserModel {
  final String email;
  final String displayName;
  final String role;
  final String token;
  final DateTime loginTime;

  UserModel({
    required this.email,
    required this.displayName,
    required this.role,
    required this.token,
    required this.loginTime,
  });
}
