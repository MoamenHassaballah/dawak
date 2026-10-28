import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/onboarding/onboarding_one.dart';
import 'package:dawak/views/onboarding/onboarding_three.dart';
import 'package:dawak/views/onboarding/onboarding_two.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingParent extends StatefulWidget {
  const OnboardingParent({super.key});

  @override
  State<OnboardingParent> createState() => _OnboardingParentState();
}

class _OnboardingParentState extends State<OnboardingParent> {
  final pageController = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: PageView(
            controller: pageController,
            onPageChanged: (value) {
              setState(() {
                _page = value;
              });
            },
            children: const [
              OnboardingOne(),
              OnboardingTwo(),
              OnboardingThree(),
            ],
          ),
        ),

        Positioned.directional(
          textDirection: context.locale == Locale("en") ? .ltr : .rtl,
          bottom: 30,
          end: 30,
          child: IconButton.filled(
            onPressed: () {
              if (_page == 2) {
                context.pushReplacement(LoginScreen());
                return;
              }
              pageController.nextPage(
                duration: Durations.long1,
                curve: Curves.easeIn,
              );
            },
            icon: Icon(Icons.arrow_forward_outlined),
            iconSize: 30,
          ),
        ),

        Positioned.directional(
          textDirection: context.locale == Locale("en") ? .ltr : .rtl,
          end: 30,
          top: 70,
          child: TextButton(
            onPressed: () {
              context.pushReplacement(LoginScreen());
            },
            child: AppText(text: "skip"),
          ),
        ),

        Positioned.directional(
          textDirection: context.locale == Locale("en") ? .ltr : .rtl,
          bottom: 100,
          start: 0,
          end: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              CircleAvatar(
                backgroundColor: _page == 0 ? colorScheme.primary : Colors.grey,
                radius: 8,
              ),
              CircleAvatar(
                backgroundColor: _page == 1 ? colorScheme.primary : Colors.grey,
                radius: 8,
              ),
              CircleAvatar(
                backgroundColor: _page == 2 ? colorScheme.primary : Colors.grey,
                radius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
