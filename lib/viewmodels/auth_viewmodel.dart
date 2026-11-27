import 'dart:convert';

import 'package:dawak/models/login_response.dart';
import 'package:dawak/network/api_endpoints.dart';
import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

enum SignupFailure { connection, invalidResponse, unknown }

enum LoginFailure {
  connection,
  invalidResponse,
  invalidCredentials,
  rateLimited,
  storage,
  unknown,
}

class SignupResult {
  const SignupResult.success(this.message) : isSuccess = true, failure = null;

  const SignupResult.failure(this.failure, {this.message}) : isSuccess = false;

  final bool isSuccess;
  final String? message;
  final SignupFailure? failure;
}

class LoginResult {
  const LoginResult.success(this.response) : isSuccess = true, failure = null;

  const LoginResult.failure(this.failure) : isSuccess = false, response = null;

  final bool isSuccess;
  final LoginResponse? response;
  final LoginFailure? failure;
}

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({BaseApi? api, AuthSessionStorage? sessionStorage})
    : _api = api ?? BaseApi(),
      _sessionStorage = sessionStorage ?? SecureAuthSessionStorage();

  final BaseApi _api;
  final AuthSessionStorage _sessionStorage;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<SignupResult> signupPatient({
    required String email,
    required String phone,
    required String password,
    required String fullName,
  }) {
    return _signup(
      endpoint: ApiEndpoints.patientSignup,
      body: {
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'fullName': fullName.trim(),
      },
    );
  }

  Future<SignupResult> signupPharmacy({
    required String email,
    required String phone,
    required String password,
    required String pharmacyName,
    required double latitude,
    required double longitude,
    required String address,
  }) {
    return _signup(
      endpoint: ApiEndpoints.pharmacySignup,
      body: {
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
        'pharmacyName': pharmacyName.trim(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'address': address.trim(),
      },
    );
  }

  Future<SignupResult> _signup({
    required String endpoint,
    required Map<String, String> body,
  }) async {
    if (_isLoading) {
      return const SignupResult.failure(SignupFailure.unknown);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(endpoint, body: body);
      final decodedBody = jsonDecode(response.body);
      if (decodedBody is! Map<String, dynamic>) {
        return const SignupResult.failure(SignupFailure.invalidResponse);
      }

      final message = decodedBody['message'];
      final responseMessage = message is String && message.trim().isNotEmpty
          ? message
          : null;
      final isSuccess =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          decodedBody['success'] == true;

      if (isSuccess) {
        return SignupResult.success(responseMessage ?? 'Signup successful.');
      }

      return SignupResult.failure(
        SignupFailure.unknown,
        message: responseMessage,
      );
    } on FormatException {
      return const SignupResult.failure(SignupFailure.invalidResponse);
    } on http.ClientException {
      return const SignupResult.failure(SignupFailure.connection);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    if (_isLoading) {
      return const LoginResult.failure(LoginFailure.unknown);
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiEndpoints.login,
        body: {'email': email.trim(), 'password': password},
      );
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      final isSuccessfulResponse =
          response.statusCode >= 200 &&
          response.statusCode < 300 &&
          loginResponse.success;

      if (!isSuccessfulResponse) {
        return LoginResult.failure(
          response.statusCode == 429
              ? LoginFailure.rateLimited
              : LoginFailure.invalidCredentials,
        );
      }

      final userId = loginResponse.userId;
      final userType = loginResponse.userType;
      final accessToken = loginResponse.accessToken;
      if (userId == null ||
          userId.isEmpty ||
          userType == null ||
          userType.isEmpty ||
          accessToken == null ||
          accessToken.isEmpty) {
        return const LoginResult.failure(LoginFailure.invalidResponse);
      }

      try {
        await _sessionStorage.saveSession(
          accessToken: accessToken,
          refreshToken: loginResponse.refreshToken,
          userId: userId,
          userType: userType,
          firstName: loginResponse.firstName,
        );
      } on PlatformException {
        return const LoginResult.failure(LoginFailure.storage);
      }

      return LoginResult.success(loginResponse);
    } on FormatException {
      return const LoginResult.failure(LoginFailure.invalidResponse);
    } on http.ClientException {
      return const LoginResult.failure(LoginFailure.connection);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
