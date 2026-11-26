import 'dart:convert';

import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:dawak/views/patient/patient_edit_account_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('selecting a profile image displays it in the avatar', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final previousPlatform = ImagePickerPlatform.instance;
    final pickerPlatform = _FakeImagePickerPlatform(
      XFile.fromData(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j65sAAAAASUVORK5CYII=',
        ),
        mimeType: 'image/png',
      ),
    );
    ImagePickerPlatform.instance = pickerPlatform;
    addTearDown(() => ImagePickerPlatform.instance = previousPlatform);

    final viewModel = PatientViewModel();
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
            home: Scaffold(
              body: PatientEditAccountPage(
                initialProfile: const PatientProfile(
                  name: 'Test Patient',
                  email: 'test@example.com',
                  phone: '1234567890',
                ),
                viewModel: viewModel,
                onSessionExpired: () async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byTooltip('Select profile image'),
        matching: find.byType(InkWell),
      ),
    );
    await tester.pumpAndSettle();

    expect(pickerPlatform.lastSource, ImageSource.gallery);
    expect(find.byType(Image), findsOneWidget);
  });
}

class _FakeImagePickerPlatform extends ImagePickerPlatform {
  _FakeImagePickerPlatform(this.image);

  final XFile image;
  ImageSource? lastSource;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    lastSource = source;
    return image;
  }
}
