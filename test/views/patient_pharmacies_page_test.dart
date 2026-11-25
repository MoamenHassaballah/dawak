import 'package:dawak/views/patient/patient_pharmacies_page.dart';
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

  testWidgets('filters pharmacy cards by name, address, and phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('ar'),
        child: Builder(
          builder: (context) => MaterialApp(
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: Scaffold(body: PatientPharmaciesPage(onBack: () {})),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('صيدلية الشفاء'), findsOneWidget);
    expect(find.text('صيدلية الرحمة'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '01012345678');
    await tester.pumpAndSettle();

    expect(find.text('صيدلية الشفاء'), findsOneWidget);
    expect(find.text('صيدلية الرحمة'), findsNothing);

    await tester.enterText(find.byType(TextField), 'الرحمة');
    await tester.pumpAndSettle();

    expect(find.text('صيدلية الشفاء'), findsNothing);
    expect(find.text('صيدلية الرحمة'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'مدينة نصر');
    await tester.pumpAndSettle();

    expect(find.text('صيدلية الشفاء'), findsOneWidget);
    expect(find.text('صيدلية الرحمة'), findsNothing);
  });
}
