import 'package:dawak/models/patient_profile.dart';
import 'package:dawak/viewmodels/patient_viewmodel.dart';
import 'package:dawak/views/views_constants/app_colors.dart';
import 'package:dawak/views/views_constants/app_text_constants.dart';
import 'package:dawak/views/widgets/session_expired_dialog.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientEditAccountPage extends StatefulWidget {
  const PatientEditAccountPage({
    super.key,
    required this.initialProfile,
    required this.viewModel,
    required this.onSessionExpired,
  });

  final PatientProfile initialProfile;
  final PatientViewModel viewModel;
  final Future<void> Function() onSessionExpired;

  @override
  State<PatientEditAccountPage> createState() => _PatientEditAccountPageState();
}

class _PatientEditAccountPageState extends State<PatientEditAccountPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialProfile.name,
    );
    _emailController = TextEditingController(
      text: widget.initialProfile.email,
    );
    _phoneController = TextEditingController(
      text: widget.initialProfile.phone,
    );
    _addressController = TextEditingController(
      text: widget.initialProfile.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSaving = true);
    final result = await widget.viewModel.updateProfile(
      currentProfile: widget.initialProfile,
      name: _nameController.text,
      phone: _phoneController.text,
      address: _addressController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);

    if (result.isSuccess) {
      Navigator.of(context).pop(result.profile);
      return;
    }
    if (result.failure == PatientProfileFailure.unauthorized) {
      await showSessionExpiredDialog(
        context,
        onLogin: widget.onSessionExpired,
      );
      return;
    }

    final message = result.message?.trim();
    final fallback = switch (result.failure) {
      PatientProfileFailure.connection => context.tr('profileConnectionError'),
      PatientProfileFailure.unauthorized => context.tr(
        'profileUnauthorizedError',
      ),
      PatientProfileFailure.forbidden => context.tr('profileForbiddenError'),
      PatientProfileFailure.missingSession => context.tr(
        'profileSessionError',
      ),
      _ => context.tr('profileSaveFailed'),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message?.isNotEmpty == true ? message! : fallback),
      ),
    );
  }

  Widget _avatar() {
    return SizedBox(
      width: 124,
      height: 124,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              color: const Color(0x4085BFC8),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.white, size: 72),
          ),
          Positioned(
            right: 5,
            bottom: 8,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 19,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.end,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: AppTextConstants.bodyStyle(
        context,
      ).copyWith(color: AppColors.primary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextConstants.bodyStyle(
          context,
        ).copyWith(color: AppColors.grey, fontSize: 13),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: Icon(icon, color: AppColors.grey, size: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      validator: validator,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.edit_outlined, color: AppColors.primary),
                  ),
                  const Spacer(),
                  Text(
                    context.tr('editPatientProfile'),
                    style: AppTextConstants.subheadingStyle(
                      context,
                    ).copyWith(color: AppColors.primary, fontSize: 22),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: _avatar()),
                      const SizedBox(height: 38),
                      Form(
                        key: _formKey,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              _field(
                                controller: _emailController,
                                label: context.tr('email'),
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                readOnly: true,
                              ),
                              const SizedBox(height: 16),
                              _field(
                                controller: _nameController,
                                label: context.tr('name'),
                                icon: Icons.person_outline,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr('nameRequired');
                                  }
                                  if (value.trim().length < 3) {
                                    return context.tr('nameTooShort');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _field(
                                controller: _phoneController,
                                label: context.tr('phone'),
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return context.tr('phoneRequired');
                                  }
                                  if (!RegExp(
                                    r'^\+?[0-9]{7,15}$',
                                  ).hasMatch(value.trim())) {
                                    return context.tr('phoneInvalid');
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _field(
                                controller: _addressController,
                                label: context.tr('address'),
                                icon: Icons.location_on_outlined,
                                keyboardType: TextInputType.streetAddress,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).maybePop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                side: BorderSide(color: AppColors.stroke),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(context.tr('cancel')),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(context.tr('save')),
                            ),
                          ),
                        ],
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
