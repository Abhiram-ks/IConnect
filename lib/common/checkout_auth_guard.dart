import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/core/storage/local_storage_service.dart';
import 'package:iconnect/routes.dart';

/// Returns `true` if the user is signed in and checkout may proceed.
///
/// When the user is **not** signed in, shows a modal dialog explaining that
/// sign-in is required and offers a "Sign In" button that pushes the login
/// screen on the root navigator. Returns `false` in that case so the caller
/// can bail out early.
///
/// Usage:
/// ```dart
/// if (!checkAuthForCheckout(context)) return;
/// // … proceed with checkout …
/// ```
bool checkAuthForCheckout(BuildContext context) {
  if (LocalStorageService.uid != null) return true; // ✅ signed in

  showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogCtx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: AppPalette.blackColor),
            SizedBox(width: 8),
            Text(
              'Sign In Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPalette.blackColor,
              ),
            ),
          ],
        ),
        content: const Text(
          'You need to sign in to proceed with checkout.',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPalette.blackColor,
              side: const BorderSide(color: AppPalette.blackColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop(); // close dialog
              // Push login on the root navigator so it appears full-screen
              // above the tab shell.
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPalette.blackColor,
              foregroundColor: AppPalette.whiteColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      );
    },
  );

  return false; // 🚫 not signed in
}
