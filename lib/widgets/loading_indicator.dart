import 'package:flutter/material.dart';
import 'package:guide_genie/utils/constants.dart';
import 'package:guide_genie/utils/ui_helper.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.size = 60,
    this.color = AppConstants.primaryNeon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        UIHelper.gamingProgressIndicator(
          color: color,
          size: size,
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}