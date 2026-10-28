import '../models/user_model.dart';

class MockAuthService {
  // Pre-configured mock accounts
  static final Map<String, Map<String, String>> _mockAccounts = {
    'admin@fpt.edu.vn': {
      'password': r'Admin@123',
      'name': 'System Administrator',
      'role': 'Admin',
    },
    'muoitthe182380@fpt.edu.vn': {
      'password': 'password123',
      'name': 'Ta Muoi (HE182380)',
      'role': 'Student',
    },
    'student@fpt.edu.vn': {
      'password': 'password123',
      'name': 'FPT Student',
      'role': 'Student',
    },
    'user@test.com': {
      'password': '123456',
      'name': 'Test User',
      'role': 'Member',
    },
  };

  /// Simulates backend authentication with a network latency delay
  Future<UserModel> login({
    required String email,
    required String password,
    Duration delay = const Duration(seconds: 2),
  }) async {
    // Simulate network roundtrip latency
    await Future.delayed(delay);

    final normalizedEmail = email.trim().toLowerCase();
    final account = _mockAccounts[normalizedEmail];

    if (account == null || account['password'] != password) {
      throw Exception('Invalid email or password. Please try again.');
    }

    final mockToken =
        'mock-jwt-${DateTime.now().millisecondsSinceEpoch}-${normalizedEmail.hashCode.abs()}';

    return UserModel(
      email: normalizedEmail,
      displayName: account['name']!,
      role: account['role']!,
      token: mockToken,
      loginTime: DateTime.now(),
    );
  }
}
