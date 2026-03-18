import 'package:flutter/material.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _buildRoleButton(context, 'business', l10n.asBusiness)),
        SizedBox(width: Responsive.w(context, 12)),
        Expanded(child: _buildRoleButton(context, 'customer', l10n.asCustomer)),
      ],
    );
  }

  Widget _buildRoleButton(BuildContext context, String role, String label) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => onRoleChanged(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 12)),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.surfaceGrey,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 14)),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Responsive.sp(context, 14).clamp(12.0, 16.0),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
