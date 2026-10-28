import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class OnboardingOne extends StatefulWidget {
  const OnboardingOne({super.key});

  @override
  State<OnboardingOne> createState() => _OnboardingOneState();
}

class _OnboardingOneState extends State<OnboardingOne>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;
  late Animation<double> slideAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    scaleAnimation = Tween<double>(begin: 0, end: 1).animate(controller);
    slideAnimation = Tween<double>(begin: 30, end: 0).animate(controller);

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(color: colorScheme.surface),
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                "assets/images/onboarding_1_img.png",
                width: 300,
              ),
            ),

            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation.value),
                  child: child,
                );
              },
              child: AppText(
                text: "onboarding1Title",
                style: AppTextConstants.subheadingStyle.copyWith(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, slideAnimation.value),
                  child: child,
                );
              },
              child: AppText(
                text: "onboarding1Subtitle",
                style: AppTextConstants.bodyStyle.copyWith(fontSize: 16),
                color: AppColors.grey,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
