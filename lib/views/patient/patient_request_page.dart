import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/patient_request_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientRequestPage extends StatefulWidget {
  const PatientRequestPage({super.key, this.viewModel});

  final PatientViewModel? viewModel;

  @override
  State<PatientRequestPage> createState() => _PatientRequestPageState();
}

class _PatientRequestPageState extends State<PatientRequestPage> {
  late final PatientViewModel _patientViewModel;
  late final bool _ownsViewModel;
  late Future<PatientProfileResult> _profileFuture;

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _patientViewModel = widget.viewModel ?? PatientViewModel();
    _profileFuture = _patientViewModel.getProfile();
  }

  @override
  void dispose() {
    if (_ownsViewModel) {
      _patientViewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FutureBuilder<PatientProfileResult>(
            future: _profileFuture,
            builder: (context, snapshot) {
              final result = snapshot.data;
              final firstName = result?.profile?.name.trim();
              final greeting = snapshot.hasError ||
                      (result != null && !result.isSuccess)
                  ? context.tr('patientGreetingLoadError')
                  : firstName?.isNotEmpty == true
                  ? context.tr(
                      'patientGreetingWithName',
                      namedArgs: {'name': firstName!},
                    )
                  : context.tr('patientGreeting');

              return Text(
                greeting,
                textAlign: TextAlign.start,
                style: AppTextConstants.headingStyle(
                  context,
                ).copyWith(color: AppColors.primary, fontSize: 28),
              );
            },
          ),
          const SizedBox(height: 16),
          const _OrderMedicineBanner(),
          const SizedBox(height: 32),
          const Directionality(
            textDirection: .ltr,
            child: Row(
              children: [
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.near_me_outlined,
                    title: 'nearestPharmacy',
                    subtitle: 'browseMap',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.cached,
                    title: 'reorder',
                    subtitle: 'previousOrders',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ShortcutCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'newPrescription',
                    subtitle: 'uploadPrescription',
                    highlighted: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('recentOrders'),
                style: AppTextConstants.headingStyle(
                  context,
                ).copyWith(fontSize: 25, color: AppColors.primary),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward_ios_outlined),
                label: Text(context.tr('viewAllOrders')),
                iconAlignment: IconAlignment.end,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextConstants.bodyStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const PatientRequestWidget(
            name: 'augmentinName',
            date: 'todayOrderDate',
            acceptedCount: 3,
            rejectedCount: 1,
            isActive: true,
          ),
          const PatientRequestWidget(
            name: 'concorName',
            date: 'octoberOrderDate',
            acceptedCount: 5,
            rejectedCount: 1,
          ),
          const PatientRequestWidget(
            name: 'panadolName',
            date: 'mayOrderDate',
            acceptedCount: 3,
            rejectedCount: 2,
          ),
        ],
      ),
    );
  }
}

class _OrderMedicineBanner extends StatelessWidget {
  const _OrderMedicineBanner();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 200,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00475D), Color(0xFF003B49)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned.directional(
              textDirection: context.locale == Locale("ar") ? .rtl : .ltr,
              end: 0,
              start: 0,
              bottom: 0,
              top: 0,
              child: Image.asset(
                'assets/images/patient_home_top.png',
                fit: BoxFit.fill,
              ),
            ),
            Positioned.directional(
              textDirection: context.locale == Locale("ar") ? .rtl : .ltr,
              top: 20,
              start: 18,
              bottom: 16,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('findMedicineTitle'),
                        textAlign: TextAlign.end,
                        style: AppTextConstants.headingStyle(
                          context,
                        ).copyWith(color: Colors.white, fontSize: 27),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('findMedicineDescription'),
                        style: AppTextConstants.bodyStyle(
                          context,
                        ).copyWith(color: Colors.white, fontSize: 16),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          context.tr('orderNow'),
                          style: AppTextConstants.subheadingStyle(
                            context,
                          ).copyWith(color: Colors.white, fontSize: 19),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: highlighted ? Border.all(color: AppColors.decoration) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: highlighted
                ? const Color(0xFFBDF5E4)
                : const Color(0xFFE9EDFF),
            child: Icon(
              icon,
              color: highlighted ? const Color(0xFF007A61) : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(title),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextConstants.subheadingStyle(
              context,
            ).copyWith(fontSize: 15, color: const Color(0xFF182238)),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(subtitle),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextConstants.bodyStyle(
              context,
            ).copyWith(fontSize: 13, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}
