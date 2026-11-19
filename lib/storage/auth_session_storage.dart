import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class AuthSessionStorage {
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String userType,
    required String? firstName,
  });

  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<String?> readUserId();
  Future<String?> readUserType();
  Future<String?> readFirstName();
  Future<void> clearSession();
}

class SecureAuthSessionStorage implements AuthSessionStorage {
  SecureAuthSessionStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? FlutterSecureStorage();

  static const _sessionKey = 'auth_session';

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String userType,
    required String? firstName,
  }) async {
    await _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'userId': userId,
        'userType': userType,
        'firstName': firstName,
      }),
    );
  }

  @override
  Future<String?> readAccessToken() async =>
      _stringValue((await _readSession())?['accessToken']);

  @override
  Future<String?> readRefreshToken() async =>
      _stringValue((await _readSession())?['refreshToken']);

  @override
  Future<String?> readUserId() async =>
      _stringValue((await _readSession())?['userId']);

  @override
  Future<String?> readUserType() async =>
      _stringValue((await _readSession())?['userType']);

  @override
  Future<String?> readFirstName() async =>
      _stringValue((await _readSession())?['firstName']);

  @override
  Future<void> clearSession() => _storage.delete(key: _sessionKey);

  Future<Map<String, dynamic>?> _readSession() async {
    final value = await _storage.read(key: _sessionKey);
    if (value == null) {
      return null;
    }

    final session = jsonDecode(value);
    if (session is! Map<String, dynamic>) {
      throw const FormatException('Stored auth session is invalid.');
    }
    return session;
  }
}

String? _stringValue(Object? value) => value is String ? value : null;
