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

/// Dialog for paying dues via eSewa — responsive, tracks status internally
class PayDueWithEsewaDialog extends StatefulWidget {
  final double currentDue;
  final int relationshipId;

  const PayDueWithEsewaDialog({
    super.key,
    required this.currentDue,
    required this.relationshipId,
  });

  @override
  State<PayDueWithEsewaDialog> createState() => _PayDueWithEsewaDialogState();
}

class _PayDueWithEsewaDialogState extends State<PayDueWithEsewaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  // Track eSewa status internally so it survives subsequent bloc states
  bool _businessHasEsewa = false;
  bool _statusLoaded = false;

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
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 640;

    return BlocListener<EsewaPaymentBloc, EsewaPaymentState>(
      listener: (context, state) {
        // Persist eSewa status once loaded
        if (state is EsewaStatusLoaded) {
          setState(() {
            _businessHasEsewa =
                state.esewaStatus.hasEsewa && state.esewaStatus.isActive;
            _statusLoaded = true;
          });
        } else if (state is EsewaPaymentInitiated) {
          _launchEsewaSdk(context, state);
        } else if (state is EsewaPaymentVerified) {
          Navigator.pop(context);
          MySnackbar.showSuccess(context, state.message);
          context.read<ConnectedUserDetailsBloc>().add(
            RefreshConnectedUserDetails(widget.relationshipId),
          );
        } else if (state is EsewaPaymentFailed) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 16 : 24,
          vertical: isSmallScreen ? 16 : 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: BlocBuilder<EsewaPaymentBloc, EsewaPaymentState>(
          builder: (context, esewaState) {
            final isProcessing =
                esewaState is EsewaPaymentInitiating ||
                esewaState is EsewaPaymentVerifying;
            final isCheckingStatus = esewaState is EsewaStatusChecking;

            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.85,
                maxWidth: 400,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: isSmallScreen ? 16 : 24),
                        _buildAmountField(context),
                        const SizedBox(height: 14),
                        _buildNoteField(context),
                        const SizedBox(height: 18),

                        // Status / warning section
                        if (isCheckingStatus)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        else if (_statusLoaded && !_businessHasEsewa) ...[
                          _buildWarningBanner(),
                          const SizedBox(height: 18),
                        ],

                        _buildActions(context, isProcessing, isCheckingStatus),
                      ],
                    ),
                  ),
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
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF60BB46).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/esewa-icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.payDueViaEsewa,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocalizations.of(
                  context,
                )!.dueRs(widget.currentDue.toStringAsFixed(2)),
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
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
        labelText: AppLocalizations.of(context)!.amount,
        prefixText: AppLocalizations.of(context)!.rsPrefix,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
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
        labelText: AppLocalizations.of(context)!.noteOptional,
        hintText: AppLocalizations.of(context)!.transactionNoteHint,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.businessNotLinkedEsewa,
              style: TextStyle(fontSize: 12, color: Colors.orange[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    bool isProcessing,
    bool isCheckingStatus,
  ) {
    final canPay = _statusLoaded && _businessHasEsewa && !isProcessing;

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
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: canPay ? _submit : null,
            icon: isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : SizedBox(
                    width: 22,
                    height: 22,
                    child: Image.asset(
                      'assets/images/esewa-icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
            label: Text(
              isProcessing
                  ? AppLocalizations.of(context)!.processing
                  : AppLocalizations.of(context)!.payWithEsewa,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF60BB46),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final note = _noteController.text.trim();

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
        MySnackbar.showError(
          context,
          AppLocalizations.of(context)!.esewaPaymentFailed('$data'),
        );
        context.read<EsewaPaymentBloc>().add(const ResetEsewaPayment());
      },
      onCancellation: (data) {
        MySnackbar.showInfo(
          context,
          AppLocalizations.of(context)!.paymentCancelled,
        );
        context.read<EsewaPaymentBloc>().add(const ResetEsewaPayment());
      },
    );
  }
}
