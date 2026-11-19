import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/patient/patient_my_account_page.dart';
import 'package:dawak/views/patient/patient_request_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (_currentIndex) {
          0 => const PatientRequestPage(),
          3 => const PatientMyAccountPage(),
          _ => const SizedBox.shrink(),
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: .fixed,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            label: context.tr("home"),
            icon: Icon(Icons.home_outlined, size: _currentIndex == 0 ? 30 : 25),
          ),
          BottomNavigationBarItem(
            label: context.tr("pharmacies"),
            icon: Icon(
              Icons.local_pharmacy_outlined,
              size: _currentIndex == 1 ? 30 : 25,
            ),
          ),
          BottomNavigationBarItem(
            label: context.tr("requestsHistory"),
            icon: Icon(
              Icons.receipt_long_outlined,
              size: _currentIndex == 2 ? 30 : 25,
            ),
          ),
          BottomNavigationBarItem(
            label: context.tr("myAccount"),
            icon: Icon(
              Icons.person_2_outlined,
              size: _currentIndex == 3 ? 30 : 25,
            ),
          ),
        ],
        currentIndex: _currentIndex,
        backgroundColor: Colors.white,

        selectedLabelStyle: AppTextConstants.subheadingStyle(
          context,
        ).copyWith(fontSize: 15),
        unselectedLabelStyle: AppTextConstants.bodyStyle(
          context,
        ).copyWith(fontSize: 12),
      ),
    );
  }
}
