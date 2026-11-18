import 'package:dawak/storage/onboarding_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('onboarding completion is persisted locally', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await OnboardingStorage.hasSeenOnboarding(), isFalse);
    expect(await OnboardingStorage.markOnboardingSeen(), isTrue);
    expect(await OnboardingStorage.hasSeenOnboarding(), isTrue);
  });
}
