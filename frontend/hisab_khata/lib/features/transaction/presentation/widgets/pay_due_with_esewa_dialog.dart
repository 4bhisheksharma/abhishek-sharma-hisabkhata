import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/services/esewa_payment_service.dart';
import '../bloc/esewa_payment_bloc.dart';
import '../bloc/esewa_payment_event.dart';
import '../bloc/esewa_payment_state.dart';
import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';

/// Dialog for paying dues via eSewa
class PayDueWithEsewaDialog extends StatefulWidget {
  final double currentDue;
  final int relationshipId;
  final bool businessHasEsewa;

  const PayDueWithEsewaDialog({
    super.key,
    required this.currentDue,
    required this.relationshipId,
    required this.businessHasEsewa,
  });

  @override
  State<PayDueWithEsewaDialog> createState() => _PayDueWithEsewaDialogState();
}

class _PayDueWithEsewaDialogState extends State<PayDueWithEsewaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _payFullAmount() {
    _amountController.text = widget.currentDue.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EsewaPaymentBloc, EsewaPaymentState>(
      listener: (context, state) {
        if (state is EsewaPaymentInitiated) {
          // SDK params ready — launch eSewa SDK
          _launchEsewaSdk(context, state);
        } else if (state is EsewaPaymentVerified) {
          Navigator.pop(context);
          MySnackbar.showSuccess(context, state.message);
          // Refresh the connected user details
          context.read<ConnectedUserDetailsBloc>().add(
            RefreshConnectedUserDetails(widget.relationshipId),
          );
        } else if (state is EsewaPaymentFailed) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: BlocBuilder<EsewaPaymentBloc, EsewaPaymentState>(
          builder: (context, esewaState) {
            final isProcessing =
                esewaState is EsewaPaymentInitiating ||
                esewaState is EsewaPaymentVerifying;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(context),
                    const SizedBox(height: 24),

                    // Amount field
                    _buildAmountField(context),
                    const SizedBox(height: 16),

                    // Note field
                    _buildNoteField(context),
                    const SizedBox(height: 20),

                    // Show warning if business has no eSewa
                    if (!widget.businessHasEsewa) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange[700],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'This business has not linked their eSewa account yet. Please ask them to set it up.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Action buttons
                    _buildActions(context, isProcessing),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.payment,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pay Due',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                'Current due: Rs. ${widget.currentDue.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: 'Rs. ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: TextButton(
          onPressed: _payFullAmount,
          child: Text(AppLocalizations.of(context)!.payFull),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.pleaseEnterAmount;
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return AppLocalizations.of(context)!.pleaseEnterValidAmount;
        }
        if (amount > widget.currentDue) {
          return AppLocalizations.of(context)!.amountCannotExceedDueAmount;
        }
        return null;
      },
    );
  }

  Widget _buildNoteField(BuildContext context) {
    return TextFormField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: 'Note (optional)',
        hintText: AppLocalizations.of(context)!.transactionNoteHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      maxLines: 2,
    );
  }

  Widget _buildActions(BuildContext context, bool isProcessing) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (isProcessing || !widget.businessHasEsewa)
                ? null
                : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF60BB46),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Pay with eSewa'),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();

    // Initiate eSewa payment via BLoC
    context.read<EsewaPaymentBloc>().add(
      InitiateEsewaPayment(
        relationshipId: widget.relationshipId,
        amount: amount,
        description: note.isEmpty ? null : note,
      ),
    );
  }

  void _launchEsewaSdk(BuildContext context, EsewaPaymentInitiated state) {
    final paymentData = state.paymentData;
    final esewaService = EsewaPaymentService();

    esewaService.initiatePayment(
      productId: paymentData.productId,
      productName: paymentData.productName,
      amount: paymentData.amount,
      onSuccess: (EsewaPaymentSuccessResult result) {
        // Verify with backend
        context.read<EsewaPaymentBloc>().add(
          VerifyEsewaPayment(
            paymentRecordId: paymentData.paymentRecordId,
            esewaRefId: result.refId,
            esewaProductId: result.productId,
            totalAmount: result.totalAmount,
            status: result.status,
            esewaResponse: {
              'productId': result.productId,
              'productName': result.productName,
              'totalAmount': result.totalAmount,
              'environment': result.environment,
              'code': result.code,
              'merchantName': result.merchantName,
              'message': result.message,
              'date': result.date,
              'status': result.status,
              'refId': result.refId,
            },
          ),
        );
      },
      onFailure: (data) {
        MySnackbar.showError(context, 'eSewa payment failed: $data');
        context.read<EsewaPaymentBloc>().add(const ResetEsewaPayment());
      },
      onCancellation: (data) {
        MySnackbar.showInfo(context, 'Payment was cancelled');
        context.read<EsewaPaymentBloc>().add(const ResetEsewaPayment());
      },
    );
  }
}
