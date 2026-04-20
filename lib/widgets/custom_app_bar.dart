import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomAppBar extends AppBar {
  CustomAppBar({
    required String title,
    bool centerTitle = false,
    List<Widget>? actions,
    bool showNotification = false,
    VoidCallback? onNotificationTap,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    super.key,
  }) : super(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: centerTitle,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: showBackButton
              ? BackButton(
                  color: Colors.white,
                  onPressed: onBackPressed,
                )
              : null,
          actions: [
            if (showNotification)
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: onNotificationTap,
              ),
            ...(actions ?? []),
          ],
        );
}
