import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import '../bloc/esewa_account_bloc.dart';
import '../bloc/esewa_account_event.dart';
import '../bloc/esewa_account_state.dart';

/// Screen for businesses to link/manage their eSewa account
class BusinessEsewaAccountScreen extends StatefulWidget {
  const BusinessEsewaAccountScreen({super.key});

  @override
  State<BusinessEsewaAccountScreen> createState() =>
      _BusinessEsewaAccountScreenState();
}

class _BusinessEsewaAccountScreenState
    extends State<BusinessEsewaAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _esewaIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<EsewaAccountBloc>().add(const LoadEsewaAccount());
  }

  @override
  void dispose() {
    _esewaIdController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('eSewa Account'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<EsewaAccountBloc, EsewaAccountState>(
        listener: (context, state) {
          if (state is EsewaAccountActionSuccess) {
            MySnackbar.showSuccess(context, state.message);
            setState(() => _isEditing = false);
          } else if (state is EsewaAccountError) {
            MySnackbar.showError(context, state.message);
          } else if (state is EsewaAccountLoaded && state.account != null) {
            _esewaIdController.text = state.account!.esewaId;
            _accountNameController.text = state.account!.accountName;
          }
        },
        builder: (context, state) {
          if (state is EsewaAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = _getAccount(state);
          final isLinked = account != null;
          final isActionLoading = state is EsewaAccountActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // eSewa branding card
                _buildEsewaBrandCard(context, isLinked),
                const SizedBox(height: 24),

                if (!isLinked || _isEditing) ...[
                  _buildForm(context, isLinked, isActionLoading),
                ] else ...[
                  _buildAccountDetails(context, account!, isActionLoading),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  dynamic _getAccount(EsewaAccountState state) {
    if (state is EsewaAccountLoaded) return state.account;
    if (state is EsewaAccountActionLoading) return state.currentAccount;
    if (state is EsewaAccountError) return state.currentAccount;
    if (state is EsewaAccountActionSuccess) return state.account;
    return null;
  }

  Widget _buildEsewaBrandCard(BuildContext context, bool isLinked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF60BB46), Color(0xFF4AA035)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF60BB46).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'eSewa Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLinked
                          ? 'Your account is linked'
                          : 'Link your eSewa account',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLinked ? Icons.check_circle : Icons.link_off,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isLinked
                ? 'Customers can now pay their dues via eSewa directly to your account.'
                : 'Link your eSewa account so customers can pay their dues digitally.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isUpdate, bool isLoading) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUpdate ? 'Update eSewa Account' : 'Link eSewa Account',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your eSewa account details',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),

              // eSewa ID field
              TextFormField(
                controller: _esewaIdController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'eSewa ID (Phone Number)',
                  hintText: '98XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your eSewa ID';
                  }
                  if (value.length != 10) {
                    return 'eSewa ID must be 10 digits';
                  }
                  if (!value.startsWith('9')) {
                    return 'eSewa ID must start with 9';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account Name field
              TextFormField(
                controller: _accountNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  hintText: 'Name on your eSewa account',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (isUpdate) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _isEditing = false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(isUpdate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF60BB46),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isUpdate ? 'Update' : 'Link Account'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDetails(
    BuildContext context,
    dynamic account,
    bool isLoading,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Linked Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // eSewa ID
            _buildDetailRow(Icons.phone_android, 'eSewa ID', account.esewaId),
            const Divider(height: 24),

            // Account Name
            _buildDetailRow(
              Icons.person_outline,
              'Account Name',
              account.accountName,
            ),
            const Divider(height: 24),

            // Status
            _buildDetailRow(
              Icons.verified,
              'Status',
              account.isActive ? 'Active' : 'Inactive',
              valueColor: account.isActive ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () => _showUnlinkConfirmation(context),
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Unlink'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit(bool isUpdate) {
    if (!_formKey.currentState!.validate()) return;

    final esewaId = _esewaIdController.text.trim();
    final accountName = _accountNameController.text.trim();

    if (isUpdate) {
      context.read<EsewaAccountBloc>().add(
        UpdateEsewaAccount(esewaId: esewaId, accountName: accountName),
      );
    } else {
      context.read<EsewaAccountBloc>().add(
        LinkEsewaAccount(esewaId: esewaId, accountName: accountName),
      );
    }
  }

  void _showUnlinkConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Unlink eSewa'),
          ],
        ),
        content: const Text(
          'Are you sure you want to unlink your eSewa account? '
          'Customers will no longer be able to pay via eSewa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<EsewaAccountBloc>().add(const UnlinkEsewaAccount());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }
}
