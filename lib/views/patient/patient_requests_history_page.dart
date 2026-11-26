import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/patient_request_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientRequestsHistoryPage extends StatelessWidget {
  const PatientRequestsHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.tr('requestsHistory'),
            style: AppTextConstants.headingStyle(
              context,
            ).copyWith(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: const [
                PatientRequestWidget(
                  name: 'concorName',
                  date: 'octoberOrderDate',
                  acceptedCount: 5,
                  rejectedCount: 1,
                ),
                PatientRequestWidget(
                  name: 'panadolName',
                  date: 'mayOrderDate',
                  acceptedCount: 3,
                  rejectedCount: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
