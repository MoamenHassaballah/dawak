import 'dart:convert';

import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/network/api_endpoints.dart';
import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

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

class PatientPasswordResult {
  const PatientPasswordResult.success({this.message})
    : isSuccess = true,
      failure = null;

  const PatientPasswordResult.failure(this.failure, {this.message})
    : isSuccess = false;

  final bool isSuccess;
  final PatientProfileFailure? failure;
  final String? message;
}

class PatientViewModel extends ChangeNotifier {
  PatientViewModel({
    BaseApi? api,
    AuthSessionStorage? sessionStorage,
    SupabaseClient? client,
  }) : _api = api ?? BaseApi(),
       _sessionStorage = sessionStorage ?? SecureAuthSessionStorage(),
       _supabaseClient = client;

  static const _profileImageBucket = 'patient_images';
  final BaseApi _api;
  final AuthSessionStorage _sessionStorage;
  final SupabaseClient? _supabaseClient;
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
    Uint8List? profileImageBytes,
    String? profileImageContentType,
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

      final imageUrl = profileImageBytes == null
          ? currentProfile.img
          : await _uploadProfileImage(
              userId: credentials.userId,
              accessToken: credentials.accessToken,
              imageBytes: profileImageBytes,
              contentType: profileImageContentType,
            );
      final updatedProfile = currentProfile.copyWith(
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
        img: imageUrl,
      );
      final response = await _api.patch(
        ApiEndpoints.patientProfile,
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
        body: {
          'name': updatedProfile.name,
          'phone': updatedProfile.phone,
          'address': updatedProfile.address,
          'img': updatedProfile.img,
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
    } on StorageException catch (error) {
      debugPrint(
        'Profile image upload failed (${error.statusCode}): ${error.message}',
      );
      return PatientProfileResult.failure(
        PatientProfileFailure.server,
        message: error.message,
      );
    } on PlatformException catch (error) {
      debugPrint('Could not read patient session: $error');
      return const PatientProfileResult.failure(PatientProfileFailure.storage);
    } on http.ClientException catch (error) {
      debugPrint('Patient profile request failed: $error');
      return const PatientProfileResult.failure(
        PatientProfileFailure.connection,
      );
    } on FormatException catch (error) {
      debugPrint('Patient profile update returned invalid data: $error');
      return const PatientProfileResult.failure(
        PatientProfileFailure.invalidResponse,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<PatientProfileResult> updateEmail({
    required String email,
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

      final response = await _api.patch(
        ApiEndpoints.patientProfileEmail,
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
        body: {'email': email.trim()},
      );
      if (!_isSuccessfulStatus(response.statusCode)) {
        return _failureForResponse(response);
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        return const PatientProfileResult.failure(
          PatientProfileFailure.invalidResponse,
        );
      }
      if (body['success'] != true) {
        return PatientProfileResult.failure(
          PatientProfileFailure.server,
          message: _messageFromBody(response.body),
        );
      }

      return PatientProfileResult.success(
        PatientProfile.fromResponse(body),
        message: _messageFromBody(response.body),
      );
    } on PlatformException catch (error) {
      debugPrint('Could not read patient session: $error');
      return const PatientProfileResult.failure(PatientProfileFailure.storage);
    } on http.ClientException catch (error) {
      debugPrint('Patient email update request failed: $error');
      return const PatientProfileResult.failure(
        PatientProfileFailure.connection,
      );
    } on FormatException catch (error) {
      debugPrint('Patient email update returned invalid data: $error');
      return const PatientProfileResult.failure(
        PatientProfileFailure.invalidResponse,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<PatientPasswordResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isLoading) {
      return const PatientPasswordResult.failure(
        PatientProfileFailure.server,
      );
    }

    _setLoading(true);
    try {
      final credentials = await _readCredentials();
      if (credentials == null) {
        return const PatientPasswordResult.failure(
          PatientProfileFailure.missingSession,
        );
      }

      final response = await _api.patch(
        ApiEndpoints.patientProfilePassword,
        headers: {'Authorization': 'Bearer ${credentials.accessToken}'},
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      final message = _messageFromBody(response.body);
      if (!_isSuccessfulStatus(response.statusCode)) {
        return PatientPasswordResult.failure(
          switch (response.statusCode) {
            401 => PatientProfileFailure.unauthorized,
            403 => PatientProfileFailure.forbidden,
            _ => PatientProfileFailure.server,
          },
          message: message,
        );
      }

      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        return const PatientPasswordResult.failure(
          PatientProfileFailure.invalidResponse,
        );
      }
      if (body['success'] != true) {
        return PatientPasswordResult.failure(
          PatientProfileFailure.server,
          message: message,
        );
      }

      return PatientPasswordResult.success(message: message);
    } on PlatformException catch (error) {
      debugPrint('Could not read patient session: $error');
      return const PatientPasswordResult.failure(
        PatientProfileFailure.storage,
      );
    } on http.ClientException catch (error) {
      debugPrint('Patient password update request failed: $error');
      return const PatientPasswordResult.failure(
        PatientProfileFailure.connection,
      );
    } on FormatException catch (error) {
      debugPrint('Patient password update returned invalid data: $error');
      return const PatientPasswordResult.failure(
        PatientProfileFailure.invalidResponse,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<String> _uploadProfileImage({
    required String userId,
    required String accessToken,
    required Uint8List imageBytes,
    required String? contentType,
  }) async {
    debugPrint('Uploading profile image to Supabase Storage.');
    final storage = (_supabaseClient ?? Supabase.instance.client).storage;
    storage.setAuth(accessToken);

    final imageStorage = storage.from(_profileImageBucket);
    await imageStorage.uploadBinary(
      userId,
      imageBytes,
      fileOptions: FileOptions(
        cacheControl: '0',
        contentType: contentType ?? 'image/jpeg',
        upsert: true,
      ),
    );

    final url = imageStorage.getPublicUrl(userId);
    debugPrint('Profile image uploaded to Supabase Storage: $url');
    return url;
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
      if (decoded is Map<String, dynamic>) {
        final errors = decoded['errors'];
        if (errors is List) {
          final messages = errors
              .whereType<Map<String, dynamic>>()
              .map((error) => error['message'])
              .whereType<String>()
              .map((message) => message.trim())
              .where((message) => message.isNotEmpty)
              .toList();
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }

        if (decoded['message'] is String) {
          final message = (decoded['message'] as String).trim();
          return message.isEmpty ? null : message;
        }
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
