import 'package:flutter/material.dart';
import 'package:hisab_khata/core/utils/responsive.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const MyButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 25,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = Responsive.h(context, height).clamp(44.0, 64.0);
    final iconSize = Responsive.sp(context, 20).clamp(16.0, 24.0);
    final textSize = Responsive.sp(context, 16).clamp(13.0, 18.0);
    final loadingSize = Responsive.w(context, 20).clamp(16.0, 22.0);

    return SizedBox(
      width: width,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.radius(context, borderRadius),
            ),
          ),
          elevation: 0,
          disabledBackgroundColor: Colors.grey[300],
        ),
        child: isLoading
            ? SizedBox(
                height: loadingSize,
                width: loadingSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: iconSize),
                    SizedBox(width: Responsive.w(context, 8)),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
