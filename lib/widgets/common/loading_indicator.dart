import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../config/app_theme.dart';

///
/// 通用加载指示器
///
class LoadingIndicator extends StatelessWidget {
  final String? text;
  final double size;

  const LoadingIndicator({super.key, this.text, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(
            color: AppTheme.primaryColor,
            size: size,
          ),
          if (text != null) ...[
            const SizedBox(height: 20),
            Text(
              text!,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ]
        ],
      ),
    );
  }
} 