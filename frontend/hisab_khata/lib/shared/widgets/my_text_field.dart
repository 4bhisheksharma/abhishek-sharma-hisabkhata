import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool showPasswordToggle;
  final int maxLines;
  final bool enabled;
  final int? maxLength;
  final void Function(String)? onChanged;

  const MyTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.showPasswordToggle = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.onChanged,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final labelSize = Responsive.sp(context, 13).clamp(11.0, 15.0);
    final fieldSize = Responsive.sp(context, 15).clamp(13.0, 17.0);
    final hintSize = Responsive.sp(context, 14).clamp(12.0, 16.0);
    final cornerRadius = Responsive.radius(context, 12);
    final iconSize = Responsive.sp(context, 20).clamp(16.0, 24.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: Responsive.h(context, 8)),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          enabled: widget.enabled,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: fieldSize,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText ?? widget.label,
            hintStyle: TextStyle(color: AppTheme.textHint, fontSize: hintSize),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.showPasswordToggle
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppTheme.grey,
                      size: iconSize,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: AppTheme.surfaceGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 16),
              vertical: Responsive.h(context, 16),
            ),
          ),
        ),
      ],
    );
  }
}
