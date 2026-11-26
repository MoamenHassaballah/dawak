import 'dart:convert';
import 'dart:typed_data';

import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('uploads under the user ID before updating the profile URL', () async {
    const userId = 'patient-id';
    const accessToken = 'patient-access-token';
    const imageUrl =
        'https://project.supabase.co/storage/v1/object/public/profile-images/patient-id';
    var uploadCompleted = false;

    final supabaseClient = SupabaseClient(
      'https://project.supabase.co',
      'test-publishable-key',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/storage/v1/object/profile-images/$userId');
        expect(request.headers['Authorization'], 'Bearer $accessToken');
        expect(request.headers['x-upsert'], 'true');
        expect(
          request.headers['content-type'],
          startsWith('multipart/form-data; boundary='),
        );
        expect(
          String.fromCharCodes(request.bodyBytes).toLowerCase(),
          contains('content-type: image/png'),
        );
        expect(request.bodyBytes, contains(137));
        uploadCompleted = true;
        return http.Response(
          jsonEncode({'Key': 'profile-images/$userId'}),
          200,
        );
      }),
    );
    addTearDown(supabaseClient.dispose);

    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(uploadCompleted, isTrue);
          expect(request.method, 'PATCH');
          expect(request.headers['Authorization'], 'Bearer $accessToken');
          expect(jsonDecode(request.body), {
            'name': 'Updated Patient',
            'phone': '01234567890',
            'address': 'New address',
            'img': imageUrl,
          });
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'name': 'Updated Patient',
                'email': 'patient@example.com',
                'phone': '01234567890',
                'address': 'New address',
                'img': imageUrl,
              },
            }),
            200,
          );
        }),
      ),
      sessionStorage: _MemoryAuthSessionStorage(userId, accessToken),
      client: supabaseClient,
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updateProfile(
      currentProfile: const PatientProfile(
        name: 'Patient',
        email: 'patient@example.com',
        phone: '01012345678',
      ),
      name: 'Updated Patient',
      phone: '01234567890',
      address: 'New address',
      profileImageBytes: Uint8List.fromList([137, 80, 78, 71]),
      profileImageContentType: 'image/png',
    );

    expect(result.isSuccess, isTrue);
    expect(result.profile?.img, imageUrl);
  });

  test('keeps the existing image URL when no image is selected', () async {
    const imageUrl = 'https://existing.example/patient-image';
    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(jsonDecode(request.body)['img'], imageUrl);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'name': 'Patient',
                'email': 'patient@example.com',
                'phone': '01012345678',
                'address': '',
                'img': imageUrl,
              },
            }),
            200,
          );
        }),
      ),
      sessionStorage: _MemoryAuthSessionStorage('patient-id', 'access-token'),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updateProfile(
      currentProfile: const PatientProfile(
        name: 'Patient',
        email: 'patient@example.com',
        phone: '01012345678',
        img: imageUrl,
      ),
      name: 'Patient',
      phone: '01012345678',
      address: '',
    );

    expect(result.isSuccess, isTrue);
    expect(result.profile?.img, imageUrl);
  });

  test('updates the email and parses the nested patient response', () async {
    const userId = 'patient-id';
    const accessToken = 'patient-access-token';
    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/patient/profile/email');
          expect(request.headers['Authorization'], 'Bearer $accessToken');
          expect(jsonDecode(request.body), {'email': 'new@example.com'});
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Email updated successfully.',
              'data': {
                'patient': {
                  'name': 'Patient',
                  'email': 'new@example.com',
                  'phone': '01234567890',
                  'address': 'Address',
                  'img': null,
                  'last_modified': '2026-11-26T22:03:12.457+00:00',
                },
                'auth_email': 'new@example.com',
              },
            }),
            200,
          );
        }),
      ),
      sessionStorage: _MemoryAuthSessionStorage(userId, accessToken),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updateEmail(email: ' new@example.com ');

    expect(result.isSuccess, isTrue);
    expect(result.profile?.email, 'new@example.com');
    expect(result.profile?.name, 'Patient');
  });

  test('returns the API message when an email update fails', () async {
    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'success': false, 'message': 'error'}),
            400,
          ),
        ),
      ),
      sessionStorage: _MemoryAuthSessionStorage('patient-id', 'access-token'),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updateEmail(email: 'new@example.com');

    expect(result.isSuccess, isFalse);
    expect(result.failure, PatientProfileFailure.server);
    expect(result.message, 'error');
  });

  test('updates the password with the authenticated request body', () async {
    const accessToken = 'patient-access-token';
    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(request.url.path, '/patient/profile/password');
          expect(request.headers['Authorization'], 'Bearer $accessToken');
          expect(jsonDecode(request.body), {
            'currentPassword': 'oldPassword123',
            'newPassword': 'newPassword123',
          });
          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Password updated successfully.',
            }),
            200,
          );
        }),
      ),
      sessionStorage: _MemoryAuthSessionStorage(
        'patient-id',
        accessToken,
      ),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updatePassword(
      currentPassword: 'oldPassword123',
      newPassword: 'newPassword123',
    );

    expect(result.isSuccess, isTrue);
    expect(result.message, 'Password updated successfully.');
  });

  test('returns the API message when a password update fails', () async {
    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'success': false,
              'message': 'Current password is incorrect.',
            }),
            400,
          ),
        ),
      ),
      sessionStorage: _MemoryAuthSessionStorage('patient-id', 'access-token'),
    );
    addTearDown(viewModel.dispose);

    final result = await viewModel.updatePassword(
      currentPassword: 'wrong-password',
      newPassword: 'newPassword123',
    );

    expect(result.isSuccess, isFalse);
    expect(result.failure, PatientProfileFailure.server);
    expect(result.message, 'Current password is incorrect.');
  });
}

class _MemoryAuthSessionStorage implements AuthSessionStorage {
  _MemoryAuthSessionStorage(this.userId, this.accessToken);

  final String userId;
  final String accessToken;

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<String?> readUserId() async => userId;

  @override
  Future<String?> readUserType() async => 'patient';

  @override
  Future<String?> readFirstName() async => 'Patient';

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
