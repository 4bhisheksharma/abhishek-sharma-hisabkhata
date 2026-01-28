import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_event.dart';
import 'package:hisab_khata/features/analytics/presentation/bloc/analytics_state.dart';

class SetMonthlyLimitDialog extends StatefulWidget {
  final double? currentLimit;

  const SetMonthlyLimitDialog({super.key, this.currentLimit});

  @override
  State<SetMonthlyLimitDialog> createState() => _SetMonthlyLimitDialogState();
}

class _SetMonthlyLimitDialogState extends State<SetMonthlyLimitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentLimit != null && widget.currentLimit! > 0) {
      _limitController.text = widget.currentLimit!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  void _setLimit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final limit = double.parse(_limitController.text.trim());

      context.read<AnalyticsBloc>().add(
        SetMonthlyLimitEvent(monthlyLimit: limit),
      );
    }
  }

  void _removeLimit() {
    setState(() {
      _isLoading = true;
    });

    context.read<AnalyticsBloc>().add(
      const SetMonthlyLimitEvent(monthlyLimit: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCurrentLimit =
        widget.currentLimit != null && widget.currentLimit! > 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final dialogPadding = isSmallScreen ? 16.0 : 24.0;

    return BlocListener<AnalyticsBloc, AnalyticsState>(
      listener: (context, state) {
        if (state is AnalyticsDataLoaded && _isLoading) {
          Navigator.of(context).pop(true);
        } else if (state is AnalyticsError && _isLoading) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? screenWidth * 0.9 : 450,
          ),
          child: Padding(
            padding: EdgeInsets.all(dialogPadding),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.savings_outlined,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Set Monthly Limit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    'Set a monthly spending limit to track your budget',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  /// Input
                  TextFormField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Monthly Limit',
                      prefixText: 'Rs. ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryBlue,
                          width: 2,
                        ),
                      ),
                      hintText: 'Enter amount',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  /// Buttons (unchanged)
                  isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _setLimit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.setLimit,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            if (hasCurrentLimit)
                              TextButton(
                                onPressed: _isLoading ? null : _removeLimit,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Remove Limit'),
                              ),
                          ],
                        )
                      : Row(
                          children: [
                            if (hasCurrentLimit)
                              TextButton(
                                onPressed: _isLoading ? null : _removeLimit,
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.removeLimit,
                                ),
                              ),
                            const Spacer(),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _setLimit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.setLimit,
                                    ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
