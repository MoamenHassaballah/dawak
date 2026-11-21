import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

Future<void> showSessionExpiredDialog(
  BuildContext context, {
  required Future<void> Function() onLogin,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.tr('sessionExpiredTitle')),
      content: Text(context.tr('profileUnauthorizedError')),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.of(dialogContext).pop();
            await onLogin();
          },
          child: Text(context.tr('login')),
        ),
      ],
    ),
  );
}
