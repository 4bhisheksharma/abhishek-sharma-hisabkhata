import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/services/esewa_payment_service.dart';
import 'package:hisab_khata/services/khalti_payment_service.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

import '../bloc/connected_user_details_bloc.dart';
import '../bloc/connected_user_details_event.dart';
import '../bloc/esewa_payment_bloc.dart';
import '../bloc/esewa_payment_event.dart';
import '../bloc/esewa_payment_state.dart';
import '../bloc/khalti_payment_bloc.dart';
import '../bloc/khalti_payment_event.dart';
import '../bloc/khalti_payment_state.dart';

enum _GatewayOption { esewa, khalti }

/// Dialog for paying dues online via eSewa or Khalti
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

  bool _businessHasEsewa = false;
  bool _businessHasKhalti = false;
  bool _esewaStatusLoaded = false;
  bool _khaltiStatusLoaded = false;

  _GatewayOption _selectedGateway = _GatewayOption.esewa;
  final Set<String> _processedKhaltiVerifyKeys = <String>{};

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

    return MultiBlocListener(
      listeners: [
        BlocListener<EsewaPaymentBloc, EsewaPaymentState>(
          listener: (context, state) {
            if (state is EsewaStatusLoaded) {
              setState(() {
                _businessHasEsewa =
                    state.esewaStatus.hasEsewa && state.esewaStatus.isActive;
                _esewaStatusLoaded = true;
                if (_businessHasEsewa && !_businessHasKhalti) {
                  _selectedGateway = _GatewayOption.esewa;
                }
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
        ),
        BlocListener<KhaltiPaymentBloc, KhaltiPaymentState>(
          listener: (context, state) {
            if (state is KhaltiStatusLoaded) {
              setState(() {
                _businessHasKhalti =
                    state.khaltiStatus.hasKhalti && state.khaltiStatus.isActive;
                _khaltiStatusLoaded = true;
                if (_businessHasKhalti && !_businessHasEsewa) {
                  _selectedGateway = _GatewayOption.khalti;
                }
              });
            } else if (state is KhaltiPaymentInitiated) {
              _launchKhaltiSdk(context, state);
            } else if (state is KhaltiPaymentVerified) {
              Navigator.pop(context);
              MySnackbar.showSuccess(context, state.message);
              context.read<ConnectedUserDetailsBloc>().add(
                RefreshConnectedUserDetails(widget.relationshipId),
              );
            } else if (state is KhaltiPaymentFailed) {
              MySnackbar.showError(context, state.message);
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final esewaState = context.watch<EsewaPaymentBloc>().state;
          final khaltiState = context.watch<KhaltiPaymentBloc>().state;

          final isProcessing =
              esewaState is EsewaPaymentInitiating ||
              esewaState is EsewaPaymentVerifying ||
              khaltiState is KhaltiPaymentInitiating ||
              khaltiState is KhaltiPaymentVerifying;

          final isCheckingStatus =
              esewaState is EsewaStatusChecking ||
              khaltiState is KhaltiStatusChecking ||
              !_esewaStatusLoaded ||
              !_khaltiStatusLoaded;

          final hasAnyGateway = _businessHasEsewa || _businessHasKhalti;

          return Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16 : 24,
              vertical: isSmallScreen ? 16 : 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.88,
                maxWidth: 430,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 18 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: isSmallScreen ? 16 : 22),
                        _buildAmountField(context),
                        const SizedBox(height: 14),
                        _buildNoteField(context),
                        const SizedBox(height: 14),
                        _buildGatewaySelector(context, isCheckingStatus),
                        const SizedBox(height: 16),
                        if (!hasAnyGateway && !isCheckingStatus) ...[
                          _buildWarningBanner(),
                          const SizedBox(height: 16),
                        ],
                        _buildActions(
                          context,
                          isProcessing: isProcessing,
                          isCheckingStatus: isCheckingStatus,
                          hasAnyGateway: hasAnyGateway,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
            color: AppTheme.primaryBlue.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.payments_outlined,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pay Due Online',
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

  Widget _buildGatewaySelector(BuildContext context, bool isCheckingStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildGatewayTile(
                label: 'eSewa',
                logoPath: 'assets/images/esewa-icon.png',
                isAvailable: _businessHasEsewa,
                isSelected: _selectedGateway == _GatewayOption.esewa,
                isCheckingStatus: isCheckingStatus,
                onTap: () =>
                    setState(() => _selectedGateway = _GatewayOption.esewa),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildGatewayTile(
                label: 'Khalti',
                logoPath: 'assets/images/khalti-icon.png',
                isAvailable: _businessHasKhalti,
                isSelected: _selectedGateway == _GatewayOption.khalti,
                isCheckingStatus: isCheckingStatus,
                onTap: () =>
                    setState(() => _selectedGateway = _GatewayOption.khalti),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGatewayTile({
    required String label,
    required String logoPath,
    required bool isAvailable,
    required bool isSelected,
    required bool isCheckingStatus,
    required VoidCallback onTap,
  }) {
    final canTap = !isCheckingStatus && isAvailable;

    return InkWell(
      onTap: canTap ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.lightBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : (isAvailable ? Colors.grey[300]! : Colors.grey[200]!),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(logoPath, fit: BoxFit.contain),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (isCheckingStatus)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                isAvailable ? 'Linked' : 'Not linked',
                style: TextStyle(
                  fontSize: 11,
                  color: isAvailable ? Colors.green[700] : Colors.red[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
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
              'This business has not linked eSewa or Khalti yet. Ask them to link at least one account.',
              style: TextStyle(fontSize: 12, color: Colors.orange[900]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(
    BuildContext context, {
    required bool isProcessing,
    required bool isCheckingStatus,
    required bool hasAnyGateway,
  }) {
    final isGatewayAvailable = _selectedGateway == _GatewayOption.esewa
        ? _businessHasEsewa
        : _businessHasKhalti;

    final canPay =
        hasAnyGateway &&
        isGatewayAvailable &&
        !isProcessing &&
        !isCheckingStatus;

    final buttonLabel = _selectedGateway == _GatewayOption.esewa
        ? 'Pay with eSewa'
        : 'Pay with Khalti';

    final buttonColor = _selectedGateway == _GatewayOption.esewa
        ? const Color(0xFF60BB46)
        : const Color(0xFF7D1E8A);

    final logoPath = _selectedGateway == _GatewayOption.esewa
        ? 'assets/images/esewa-icon.png'
        : 'assets/images/khalti-icon.png';

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
                    child: Image.asset(logoPath, fit: BoxFit.contain),
                  ),
            label: Text(
              isProcessing
                  ? AppLocalizations.of(context)!.processing
                  : buttonLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
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

    if (_selectedGateway == _GatewayOption.esewa) {
      context.read<EsewaPaymentBloc>().add(
        InitiateEsewaPayment(
          relationshipId: widget.relationshipId,
          amount: amount,
          description: note.isEmpty ? null : note,
        ),
      );
      return;
    }

    context.read<KhaltiPaymentBloc>().add(
      InitiateKhaltiPayment(
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

  Future<void> _launchKhaltiSdk(
    BuildContext context,
    KhaltiPaymentInitiated state,
  ) async {
    final paymentData = state.paymentData;
    final khaltiService = KhaltiPaymentService();

    try {
      await khaltiService.initiatePayment(
        context: context,
        publicKey: paymentData.publicKey,
        pidx: paymentData.pidx,
        isTestEnvironment: paymentData.isTest,
        onPaymentResult: (paymentResult) {
          final dynamic payload = paymentResult?.payload;
          final transactionId =
              (payload?.transactionId ?? paymentResult?.transactionId ?? '')
                  .toString();
          final totalAmount =
              (payload?.totalAmount ??
                      paymentResult?.totalAmount ??
                      paymentData.amount)
                  .toString();
          final statusText =
              (payload?.status ?? paymentResult?.status ?? 'Completed')
                  .toString();

          final verifyKey =
              '${paymentData.paymentRecordId}-${paymentData.pidx}-${transactionId.isEmpty ? 'na' : transactionId}';
          if (_processedKhaltiVerifyKeys.contains(verifyKey)) {
            return;
          }
          _processedKhaltiVerifyKeys.add(verifyKey);

          context.read<KhaltiPaymentBloc>().add(
            VerifyKhaltiPayment(
              paymentRecordId: paymentData.paymentRecordId,
              pidx: paymentData.pidx,
              transactionId: transactionId,
              totalAmount: totalAmount,
              status: statusText,
              khaltiResponse: {
                'payment_result': paymentResult.toString(),
                'transaction_id': transactionId,
                'total_amount': totalAmount,
                'status': statusText,
              },
            ),
          );
        },
        onMessage: (message, {needsPaymentConfirmation = false, khalti}) async {
          if (needsPaymentConfirmation && khalti != null) {
            try {
              await khalti.verify();
            } catch (_) {}
          }
          if (message.toLowerCase().contains('failure') ||
              message.toLowerCase().contains('error')) {
            MySnackbar.showError(context, message);
            context.read<KhaltiPaymentBloc>().add(const ResetKhaltiPayment());
          }
        },
        onReturn: () {},
      );
    } catch (e) {
      MySnackbar.showError(context, e.toString());
      context.read<KhaltiPaymentBloc>().add(const ResetKhaltiPayment());
    }
  }
}
