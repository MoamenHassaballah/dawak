import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:dawak/views/guest/guest_account_page.dart';
import 'package:dawak/views/guest/guest_home_page.dart';
import 'package:dawak/views/guest/guest_pharmacies_page.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class GuestMainPage extends StatefulWidget {
  const GuestMainPage({super.key});

  @override
  State<GuestMainPage> createState() => _GuestMainPageState();
}

class _GuestMainPageState extends State<GuestMainPage> {
  int _currentIndex = 0;
  final screens = [GuestHomePage(), GuestPharmaciesPage(), GuestAccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          text: "appName",
          style: AppTextConstants.headingStyle(context),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset("assets/icon/logo_shadow.png"),
        ),
        leadingWidth: 60,
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
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
            label: context.tr("myAccount"),
            icon: Icon(
              Icons.account_circle_outlined,
              size: _currentIndex == 2 ? 30 : 25,
            ),
          ),
        ],
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
