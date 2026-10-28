import 'package:dawak/views/constants/app_colors.dart';
import 'package:dawak/views/constants/app_text_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;

  final TextStyle? style;
  final TextAlign? textAlign;

  final Color? color;

  final bool? translate;

  const AppText({
    super.key,
    required this.text,
    this.style = AppTextConstants.bodyStyle,
    this.color,
    this.textAlign = TextAlign.start,
    this.translate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      translate! ? context.tr(text) : text,
      style: style?.copyWith(
        fontFamily: context.locale == const Locale('ar')
            ? 'Tajawal'
            : 'Poppins',

        color: color ?? AppColors.primary,
      ),
      textAlign: textAlign,
    );
  }
}
