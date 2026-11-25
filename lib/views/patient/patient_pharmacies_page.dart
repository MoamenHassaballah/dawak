import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/app_text.dart';
import 'package:dawak/views/widgets/pharmacy_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientPharmaciesPage extends StatefulWidget {
  const PatientPharmaciesPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<PatientPharmaciesPage> createState() => _PatientPharmaciesPageState();
}

class _PatientPharmaciesPageState extends State<PatientPharmaciesPage> {
  final _searchController = TextEditingController();

  static const _pharmacies = [
    _Pharmacy(
      name: 'صيدلية الشفاء',
      address: 'مدينة نصر، القاهرة',
      phone: '01012345678',
    ),
    _Pharmacy(
      name: 'صيدلية الرحمة',
      address: 'مصر الجديدة، القاهرة',
      phone: '01023456789',
    ),
    _Pharmacy(
      name: 'صيدلية النور',
      address: 'المعادي، القاهرة',
      phone: '01034567890',
    ),
    _Pharmacy(
      name: 'صيدلية الحياة',
      address: 'الدقي، الجيزة',
      phone: '01045678901',
    ),
    _Pharmacy(
      name: 'صيدلية العائلة',
      address: 'المهندسين، الجيزة',
      phone: '01056789012',
    ),
    _Pharmacy(
      name: 'صيدلية السلام',
      address: 'الزمالك، القاهرة',
      phone: '01067890123',
    ),
    _Pharmacy(
      name: 'صيدلية الدواء',
      address: 'شبرا، القاهرة',
      phone: '01078901234',
    ),
    _Pharmacy(
      name: 'صيدلية الندى',
      address: 'الهرم، الجيزة',
      phone: '01089012345',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Pharmacy> get _filteredPharmacies {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _pharmacies;
    }

    return _pharmacies.where((pharmacy) {
      return pharmacy.name.toLowerCase().contains(query) ||
          pharmacy.address.toLowerCase().contains(query) ||
          pharmacy.phone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final pharmacies = _filteredPharmacies;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              AppText(
                text: 'pharmacies',
                style: AppTextConstants.headingStyle(
                  context,
                ).copyWith(fontSize: 24),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onBack,
                icon: Icon(Icons.arrow_back, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            textAlign: TextAlign.start,
            decoration: InputDecoration(
              hintText: context.tr('searchPlaceholder'),
              hintStyle: AppTextConstants.bodyStyle(
                context,
              ).copyWith(color: AppColors.grey),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: Icon(Icons.search, color: AppColors.primary),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.stroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.tune, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: pharmacies.isEmpty
                ? Center(
                    child: AppText(
                      text: 'noPharmaciesFound',
                      color: AppColors.grey,
                    ),
                  )
                : ListView.separated(
                    itemCount: pharmacies.length,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pharmacy = pharmacies[index];
                      return PharmacyWidget(
                        name: pharmacy.name,
                        address: pharmacy.address,
                        phone: pharmacy.phone,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _Pharmacy {
  const _Pharmacy({
    required this.name,
    required this.address,
    required this.phone,
  });

  final String name;
  final String address;
  final String phone;
}
