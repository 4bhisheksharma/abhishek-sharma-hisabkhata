import 'package:flutter/material.dart';

//role selection buttons ko lagi widget
class RoleSelectionButtons extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelectionButtons({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onRoleChanged('business'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedRole == 'business'
                    ? const Color(0xFFB8E0D5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedRole == 'business'
                      ? Colors.transparent
                      : Colors.black26,
                ),
              ),
              child: const Text(
                'As Business',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onRoleChanged('customer'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selectedRole == 'customer'
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selectedRole == 'customer'
                      ? Colors.transparent
                      : Colors.black26,
                ),
              ),
              child: Text(
                'As Customer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: selectedRole == 'customer'
                      ? Colors.white
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
