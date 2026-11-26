import 'package:dawak/views/patient/patient_requests_history_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('shows dummy requests with their response summaries', (
    tester,
  ) async {
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
            home: const Scaffold(body: PatientRequestsHistoryPage()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Requests History'), findsOneWidget);
    expect(find.text('Augmentin 1 g'), findsOneWidget);
    expect(find.text('Active - awaiting replies'), findsOneWidget);
    expect(find.text('Concor 5 mg'), findsOneWidget);
    expect(find.text('Panadol Extra'), findsOneWidget);
  });
}
