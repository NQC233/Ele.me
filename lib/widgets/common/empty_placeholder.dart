import 'package:flutter/material.dart';

import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';

///
/// 通用空状态占位符
///
class EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText = '去逛逛',
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textColor),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 14, color: AppTheme.secondaryTextColor),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: onButtonPressed ?? () => AppRoutes.router.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(buttonText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
} 