class LoginResponse {
  const LoginResponse({
    required this.success,
    this.message,
    this.userId,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Login response must be a JSON object.');
    }

    final user = json['user'];
    final session = json['session'];

    return LoginResponse(
      success: json['success'] == true,
      message: _stringValue(json['message']),
      userId: user is Map<String, dynamic> ? _stringValue(user['id']) : null,
      accessToken: session is Map<String, dynamic>
          ? _stringValue(session['access_token'])
          : null,
      refreshToken: session is Map<String, dynamic>
          ? _stringValue(session['refresh_token'])
          : null,
    );
  }

  final bool success;
  final String? message;
  final String? userId;
  final String? accessToken;
  final String? refreshToken;
}

String? _stringValue(Object? value) => value is String ? value : null;
