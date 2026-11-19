import 'dart:convert';

import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/viewmodels/auth_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'patient signup sends expected fields and returns success message',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/auth/patient/signup');
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'email': 'patient@example.com',
          'phone': '123456789',
          'password': 'password123',
          'fullName': 'Test Patient',
        });
        return http.Response(
          jsonEncode({'success': true, 'message': 'Signup successful.'}),
          201,
        );
      });
      final viewModel = AuthViewModel(api: BaseApi(client: client));
      addTearDown(viewModel.dispose);

      final result = await viewModel.signupPatient(
        email: ' patient@example.com ',
        phone: '123456789',
        password: 'password123',
        fullName: 'Test Patient',
      );

      expect(result.isSuccess, isTrue);
      expect(result.message, 'Signup successful.');
      expect(viewModel.isLoading, isFalse);
    },
  );

  test('patient signup exposes the server error message', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'success': false,
          'message': 'For security purposes, wait before trying again.',
        }),
        429,
      );
    });
    final viewModel = AuthViewModel(api: BaseApi(client: client));
    addTearDown(viewModel.dispose);

    final result = await viewModel.signupPatient(
      email: 'patient@example.com',
      phone: '123456789',
      password: 'password123',
      fullName: 'Test Patient',
    );

    expect(result.isSuccess, isFalse);
    expect(result.message, 'For security purposes, wait before trying again.');
  });

  test(
    'login saves the required session data and returns the minimal model',
    () async {
      final sessionStorage = _MemoryAuthSessionStorage();
      final client = MockClient((request) async {
        expect(request.url.path, '/auth/login');
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'email': 'patient@example.com',
          'password': 'password123',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Login successful.',
            'user': {
              'id': 'patient-id',
              'email': 'patient@example.com',
              'user_metadata': {
                'account_type': 'patient',
                'full_name': 'Test Patient',
              },
            },
            'session': {
              'access_token': 'access-token',
              'refresh_token': 'refresh-token',
              'user': {'id': 'duplicate-user-id'},
            },
          }),
          200,
        );
      });
      final viewModel = AuthViewModel(
        api: BaseApi(client: client),
        sessionStorage: sessionStorage,
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.login(
        email: ' patient@example.com ',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);
      expect(result.response?.userId, 'patient-id');
      expect(result.response?.accessToken, 'access-token');
      expect(sessionStorage.accessToken, 'access-token');
      expect(sessionStorage.refreshToken, 'refresh-token');
      expect(sessionStorage.userId, 'patient-id');
      expect(sessionStorage.userType, 'patient');
      expect(sessionStorage.firstName, 'Test');
    },
  );

  test('login treats an echoed request body as invalid credentials', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({'email': 'patient@example.com', 'password': 'password123'}),
        401,
      );
    });
    final viewModel = AuthViewModel(
      api: BaseApi(client: client),
      sessionStorage: _MemoryAuthSessionStorage(),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.login(
      email: 'patient@example.com',
      password: 'password123',
    );

    expect(result.isSuccess, isFalse);
    expect(result.failure, LoginFailure.invalidCredentials);
  });

  test('login requires account type before saving the session', () async {
    final sessionStorage = _MemoryAuthSessionStorage();
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'user': {'id': 'patient-id'},
          'session': {'access_token': 'access-token'},
        }),
        200,
      );
    });
    final viewModel = AuthViewModel(
      api: BaseApi(client: client),
      sessionStorage: sessionStorage,
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.login(
      email: 'patient@example.com',
      password: 'password123',
    );

    expect(result.isSuccess, isFalse);
    expect(result.failure, LoginFailure.invalidResponse);
    expect(sessionStorage.userId, isNull);
    expect(sessionStorage.userType, isNull);
  });
}

class _MemoryAuthSessionStorage implements AuthSessionStorage {
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? userType;
  String? firstName;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readUserType() async => userType;

  @override
  Future<String?> readFirstName() async => firstName;

  @override
  Future<void> clearSession() async {
    accessToken = null;
    refreshToken = null;
    userId = null;
    userType = null;
    firstName = null;
  }

  @override
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String userType,
    required String? firstName,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.userId = userId;
    this.userType = userType;
    this.firstName = firstName;
  }
}
