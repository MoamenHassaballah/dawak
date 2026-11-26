import 'dart:convert';

import 'package:dawak/network/base_api.dart';
import 'package:dawak/storage/auth_session_storage.dart';
import 'package:dawak/viewmodels/auth_viewmodel.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:dawak/views/patient/patient_my_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('password success asks to log in and clears the session on OK', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sessionStorage = _MemoryAuthSessionStorage();
    final patientViewModel = PatientViewModel(
      api: BaseApi(
        client: MockClient((request) async {
          expect(request.headers['Authorization'], 'Bearer access-token');
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'success': true,
                'data': {
                  'name': 'Patient',
                  'email': 'patient@example.com',
                  'phone': '01234567890',
                },
              }),
              200,
            );
          }

          expect(request.method, 'PATCH');
          expect(request.url.path, '/patient/profile/password');
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
      sessionStorage: sessionStorage,
    );
    final authViewModel = AuthViewModel(sessionStorage: sessionStorage);
    addTearDown(patientViewModel.dispose);
    addTearDown(authViewModel.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        child: Builder(
          builder: (context) => ChangeNotifierProvider<AuthViewModel>.value(
            value: authViewModel,
            child: MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(
                body: PatientMyAccountPage(
                  sessionStorage: sessionStorage,
                  viewModel: patientViewModel,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Change password'));
    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(TextFormField);
    await tester.enterText(passwordFields.at(0), 'oldPassword123');
    await tester.enterText(passwordFields.at(1), 'newPassword123');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Password updated'), findsOneWidget);
    expect(
      find.text('Your password was updated. Please log in again to continue.'),
      findsOneWidget,
    );

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(sessionStorage.isCleared, isTrue);
    expect(find.text('Log in to your account to continue.'), findsOneWidget);
  });
}

class _MemoryAuthSessionStorage implements AuthSessionStorage {
  bool isCleared = false;

  @override
  Future<String?> readAccessToken() async => 'access-token';

  @override
  Future<String?> readRefreshToken() async => 'refresh-token';

  @override
  Future<String?> readUserId() async => 'patient-id';

  @override
  Future<String?> readUserType() async => 'patient';

  @override
  Future<String?> readFirstName() async => 'Patient';

  @override
  Future<void> clearSession() async {
    isCleared = true;
  }

  @override
  Future<void> saveSession({
    required String accessToken,
    required String? refreshToken,
    required String userId,
    required String userType,
    required String? firstName,
  }) async {}
}
