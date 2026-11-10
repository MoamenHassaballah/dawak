import 'package:dawak/extensions/context_ext.dart';
import 'package:dawak/views/authentication/login_screen.dart';
import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:flutter/material.dart';

class GuestAccountPage extends StatelessWidget {
  const GuestAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Image.asset("assets/icon/logo_shadow.png", width: 150),
            const SizedBox(height: 16),
            AppText(
              text: "loginSignupHeading",
              style: AppTextConstants.headingStyle(
                context,
              ).copyWith(fontSize: 25),
            ),
            AppText(
              text: "loginSignupSubheading",
              textAlign: .center,
              color: AppColors.grey,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.pushReplacement(LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
              child: AppText(
                text: "login",
                color: Colors.white,
                style: AppTextConstants.subheadingStyle(
                  context,
                ).copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
