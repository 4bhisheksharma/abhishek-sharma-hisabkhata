import 'package:flutter/material.dart';
import 'package:hisab_khata/core/utils/responsive.dart';

//otp input fields ko lagi widget
class OtpInputFields extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  const OtpInputFields({
    super.key,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width;
    final fieldSize = ((availableWidth - Responsive.w(context, 96)) / 6).clamp(
      40.0,
      52.0,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: fieldSize,
          height: fieldSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
          ),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextStyle(
              fontSize: Responsive.sp(context, 20).clamp(16.0, 22.0),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                // Move to next field
                if (index < 5) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  // Last field, unfocus
                  focusNodes[index].unfocus();
                }
              } else if (value.isEmpty && index > 0) {
                // Move to previous field on backspace
                focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
