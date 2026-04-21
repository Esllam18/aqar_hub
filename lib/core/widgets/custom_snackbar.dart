import 'package:aqar_hub/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  /// Shows a themed SnackBar anywhere in the app.
  /// You can use [context] or [scaffoldMessengerKey] for global access.
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? customIcon,
    Color? customColor,
    SnackBarAction? action,
    int maxLines = 3,
    TextStyle? textStyle,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey,
  }) {
    final icon = customIcon ?? _getIcon(type);
    final color = customColor ?? _getColor(type);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      // ignore: deprecated_member_use
      backgroundColor: color.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      content: Row(
        children: [
          Icon(icon, color: AppColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style:
                  textStyle ??
                  const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      action: action,
    );

    // Use global key if provided, else default to context
    if (scaffoldMessengerKey != null) {
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle;
      case SnackBarType.error:
        return Icons.error;
      case SnackBarType.warning:
        return Icons.warning;
      case SnackBarType.info:
        return Icons.info;
    }
  }

  static Color _getColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return AppColors.success;
      case SnackBarType.error:
        return AppColors.error;
      case SnackBarType.warning:
        return AppColors.warning;
      case SnackBarType.info:
        return AppColors.info;
    }
  }
}





// usage example:
// CustomSnackBar.show(
//   context: context,
//   message: 'Operation completed successfully!',
//   type: SnackBarType.success,
// );

// CustomSnackBar.show(
//   context: context,
//   message: 'Something went wrong!',
//   type: SnackBarType.error,
// );
// CustomSnackBar.show(
//   context: context,
//   message: 'Here is some information for you.',
//   type: SnackBarType.info,
// );


// MaterialApp(
//   scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(), // اختياري لو حابب تستخدمه من أي مكان بدون context
// )