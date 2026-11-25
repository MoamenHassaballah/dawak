import 'dart:convert';

import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'profile GET uses saved bearer token and UID and parses profile data',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/patient/profile');
        expect(request.url.queryParameters, isEmpty);
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer access-token');
        expect(jsonDecode(request.body), {'id': 'patient-id'});
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Patient profile retrieved successfully.',
            'data': [
              {
                'name': 'Test Patient',
                'email': 'test@gmail.com',
                'phone': '1234567890',
                'img': null,
                'address': null,
              },
            ],
          }),
          200,
        );
      });
      final viewModel = PatientViewModel(
        api: BaseApi(client: client),
        sessionStorage: _MemoryAuthSessionStorage(),
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.getProfile();

      expect(result.isSuccess, isTrue);
      expect(result.profile?.name, 'Test Patient');
      expect(result.profile?.email, 'test@gmail.com');
      expect(result.profile?.phone, '1234567890');
      expect(result.profile?.img, isNull);
      expect(result.profile?.address, isNull);
    },
  );

  test(
    'profile PATCH sends edited fields and accepts an empty success body',
    () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/patient/profile');
        expect(request.method, 'PATCH');
        expect(request.headers['Authorization'], 'Bearer access-token');
        expect(jsonDecode(request.body), {
          'name': 'Updated Patient',
          'phone': '0987654321',
          'address': 'New address',
        });
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Patient profile updated successfully.',
            'data': {
              'name': 'Updated Patient',
              'email': 'test@gmail.com',
              'phone': '0987654321',
              'img': null,
              'address': 'New address',
            },
          }),
          200,
        );
      });
      final viewModel = PatientViewModel(
        api: BaseApi(client: client),
        sessionStorage: _MemoryAuthSessionStorage(),
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.updateProfile(
        currentProfile: const PatientProfile(
          name: 'Test Patient',
          email: 'test@gmail.com',
          phone: '1234567890',
        ),
        name: ' Updated Patient ',
        phone: ' 0987654321 ',
        address: ' New address ',
      );

      expect(result.isSuccess, isTrue);
      expect(result.profile?.name, 'Updated Patient');
      expect(result.profile?.email, 'test@gmail.com');
      expect(result.profile?.phone, '0987654321');
      expect(result.profile?.address, 'New address');
    },
  );

  test('profile GET exposes authorization errors from the server', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({'success': false, 'message': 'Session expired.'}),
        401,
      );
    });
    final viewModel = PatientViewModel(
      api: BaseApi(client: client),
      sessionStorage: _MemoryAuthSessionStorage(),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.getProfile();

    expect(result.isSuccess, isFalse);
    expect(result.failure, PatientProfileFailure.unauthorized);
    expect(result.message, 'Session expired.');
  });

  test(
    'profile PATCH prefers valid field errors over the general message',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Invalid profile data.',
            'errors': [
              {
                'origin': 'string',
                'code': 'invalid_format',
                'format': 'regex',
                'pattern': r'/^01[0125][0-9]{8}$/',
                'path': ['phone'],
                'message': 'Invalid Egyptian phone number',
              },
              {'message': '  Address is invalid.  '},
              {'message': ''},
              {'message': 42},
            ],
          }),
          422,
        );
      });
      final viewModel = PatientViewModel(
        api: BaseApi(client: client),
        sessionStorage: _MemoryAuthSessionStorage(),
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.updateProfile(
        currentProfile: const PatientProfile(
          name: 'Test Patient',
          email: 'test@gmail.com',
          phone: '1234567890',
        ),
        name: 'Test Patient',
        phone: '1234567890',
        address: '',
      );

      expect(result.failure, PatientProfileFailure.server);
      expect(
        result.message,
        'Invalid Egyptian phone number\nAddress is invalid.',
      );
    },
  );

  test(
    'profile errors fall back to the general message without valid details',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'success': false,
            'message': 'Invalid profile data.',
            'errors': [
              {'message': '  '},
              {'message': 42},
            ],
          }),
          422,
        );
      });
      final viewModel = PatientViewModel(
        api: BaseApi(client: client),
        sessionStorage: _MemoryAuthSessionStorage(),
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.updateProfile(
        currentProfile: const PatientProfile(
          name: 'Test Patient',
          email: 'test@gmail.com',
          phone: '1234567890',
        ),
        name: 'Test Patient',
        phone: '1234567890',
        address: '',
      );

      expect(result.message, 'Invalid profile data.');
    },
  );

  test(
    'profile GET distinguishes forbidden access from an expired session',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({'success': false, 'message': 'Access denied.'}),
          403,
        );
      });
      final viewModel = PatientViewModel(
        api: BaseApi(client: client),
        sessionStorage: _MemoryAuthSessionStorage(),
      );
      addTearDown(viewModel.dispose);

      final result = await viewModel.getProfile();

      expect(result.failure, PatientProfileFailure.forbidden);
      expect(result.failure, isNot(PatientProfileFailure.unauthorized));
    },
  );
}

class _MemoryAuthSessionStorage implements AuthSessionStorage {
  @override
  Future<String?> readAccessToken() async => 'access-token';

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<String?> readUserId() async => 'patient-id';

  @override
  Future<String?> readUserType() async => 'patient';

  @override
  Future<String?> readFirstName() async => 'Test';

  @override
  Future<void> clearSession() async {}

  @override
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String userType,
    required String? firstName,
  }) async {}
}
