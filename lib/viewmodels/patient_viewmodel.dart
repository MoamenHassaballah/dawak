import 'dart:convert';

import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/network/api_endpoints.dart';
import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

enum PatientProfileFailure {
  missingSession,
  storage,
  connection,
  unauthorized,
  forbidden,
  invalidResponse,
  server,
}

class PatientProfileResult {
  const PatientProfileResult.success(this.profile, {this.message})
    : isSuccess = true,
      failure = null;

  const PatientProfileResult.failure(this.failure, {this.message})
    : isSuccess = false,
      profile = null;

  final bool isSuccess;
  final PatientProfile? profile;
  final PatientProfileFailure? failure;
  final String? message;
}

class PatientViewModel extends ChangeNotifier {
  PatientViewModel({BaseApi? api, AuthSessionStorage? sessionStorage})
    : _api = api ?? BaseApi(),
      _sessionStorage = sessionStorage ?? SecureAuthSessionStorage();

  final BaseApi _api;
  final AuthSessionStorage _sessionStorage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<PatientProfileResult> getProfile() async {
    if (_isLoading) {
      return const PatientProfileResult.failure(PatientProfileFailure.server);
    }

    _setLoading(true);
    try {
      final credentials = await _readCredentials();
      if (credentials == null) {
        return const PatientProfileResult.failure(
          PatientProfileFailure.missingSession,
        );
      }

      final response = await _api.get(
        ApiEndpoints.patientProfile,
        body: {'id': credentials.userId},
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
      );

      if (!_isSuccessfulStatus(response.statusCode)) {
        return _failureForResponse(response);
      }

      return PatientProfileResult.success(
        PatientProfile.fromResponse(jsonDecode(response.body)),
        message: _messageFromBody(response.body),
      );
    } on PlatformException {
      return const PatientProfileResult.failure(PatientProfileFailure.storage);
    } on http.ClientException {
      return const PatientProfileResult.failure(
        PatientProfileFailure.connection,
      );
    } on FormatException {
      return const PatientProfileResult.failure(
        PatientProfileFailure.invalidResponse,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<PatientProfileResult> updateProfile({
    required PatientProfile currentProfile,
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_isLoading) {
      return const PatientProfileResult.failure(PatientProfileFailure.server);
    }

    _setLoading(true);
    try {
      final credentials = await _readCredentials();
      if (credentials == null) {
        return const PatientProfileResult.failure(
          PatientProfileFailure.missingSession,
        );
      }

      final updatedProfile = currentProfile.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
      );
      final response = await _api.patch(
        ApiEndpoints.patientProfile,
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
        body: {
          'name': updatedProfile.name,
          'phone': updatedProfile.phone,
          'address': updatedProfile.address,
        },
      );
      if (!_isSuccessfulStatus(response.statusCode)) {
        return _failureForResponse(response);
      }

      if (response.body.trim().isEmpty) {
        return PatientProfileResult.success(updatedProfile);
      }

      final body = jsonDecode(response.body);

      if (body is! Map<String, dynamic> || body['success'] != true) {
        return PatientProfileResult.failure(
          PatientProfileFailure.invalidResponse,
          message: _messageFromBody(response.body),
        );
      }

      final data = body['data'];
      if (data == null) {
        return PatientProfileResult.success(
          updatedProfile,
          message: _messageFromBody(response.body),
        );
      }

      return PatientProfileResult.success(
        PatientProfile.fromResponse(body),
        message: _messageFromBody(response.body),
      );
    } on PlatformException {
      return const PatientProfileResult.failure(PatientProfileFailure.storage);
    } on http.ClientException {
      return const PatientProfileResult.failure(
        PatientProfileFailure.connection,
      );
    } on FormatException {
      return const PatientProfileResult.failure(
        PatientProfileFailure.invalidResponse,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<_PatientCredentials?> _readCredentials() async {
    final accessToken = await _sessionStorage.readAccessToken();
    final userId = await _sessionStorage.readUserId();
    if (accessToken?.trim().isEmpty != false ||
        userId?.trim().isEmpty != false) {
      return null;
    }
    return _PatientCredentials(accessToken!, userId!);
  }

  PatientProfileResult _failureForResponse(http.Response response) {
    final failure = switch (response.statusCode) {
      401 => PatientProfileFailure.unauthorized,
      403 => PatientProfileFailure.forbidden,
      _ => PatientProfileFailure.server,
    };
    return PatientProfileResult.failure(
      failure,
      message: _messageFromBody(response.body),
    );
  }

  String? _messageFromBody(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic> && decoded['message'] is String) {
        final message = (decoded['message'] as String).trim();
        return message.isEmpty ? null : message;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  bool _isSuccessfulStatus(int statusCode) =>
      statusCode >= 200 && statusCode < 300;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}

class _PatientCredentials {
  const _PatientCredentials(this.accessToken, this.userId);

  final String accessToken;
  final String userId;
}
