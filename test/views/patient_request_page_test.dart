import 'dart:convert';

import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:dawak/views/patient/patient_request_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('loads the latest patient name for the home greeting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final viewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/patient/profile');
          expect(request.headers['Authorization'], 'Bearer access-token');
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'name': 'Updated Patient',
                'email': 'patient@example.com',
                'phone': '01234567890',
              },
            }),
            200,
          );
        }),
      ),
      sessionStorage: _MemoryAuthSessionStorage(),
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(body: PatientRequestPage(viewModel: viewModel)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hello, Updated Patient 👋'), findsOneWidget);
  });
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
  Future<String?> readFirstName() async => 'Stale Name';

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
