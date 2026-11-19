class LoginResponse {
  const LoginResponse({
    required this.success,
    this.message,
    this.userId,
    this.userType,
    this.firstName,
    this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Login response must be a JSON object.');
    }

    final user = json['user'];
    final session = json['session'];
    final userMetadata = user is Map<String, dynamic>
        ? user['user_metadata']
        : null;

    return LoginResponse(
      success: json['success'] == true,
      message: _stringValue(json['message']),
      userId: user is Map<String, dynamic> ? _stringValue(user['id']) : null,
      userType: userMetadata is Map<String, dynamic>
          ? _stringValue(userMetadata['account_type'])
          : null,
      firstName: _firstNameFromMetadata(userMetadata),
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
  final String? userType;
  final String? firstName;
  final String? accessToken;
  final String? refreshToken;
}

String? _stringValue(Object? value) => value is String ? value : null;

String? _firstNameFromMetadata(Object? metadata) {
  if (metadata is! Map<String, dynamic>) {
    return null;
  }

  final firstName = _stringValue(metadata['first_name'])?.trim();
  if (firstName?.isNotEmpty == true) {
    return firstName;
  }

  final fullName = _stringValue(metadata['full_name'])?.trim();
  if (fullName == null || fullName.isEmpty) {
    return null;
  }

  return fullName.split(RegExp(r'\s+')).first;
}
