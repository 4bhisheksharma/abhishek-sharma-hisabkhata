import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import '../bloc/khalti_account_bloc.dart';
import '../bloc/khalti_account_event.dart';
import '../bloc/khalti_account_state.dart';

class BusinessKhaltiAccountScreen extends StatefulWidget {
  const BusinessKhaltiAccountScreen({super.key});

  @override
  State<BusinessKhaltiAccountScreen> createState() =>
      _BusinessKhaltiAccountScreenState();
}

class _BusinessKhaltiAccountScreenState
    extends State<BusinessKhaltiAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _khaltiIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    context.read<KhaltiAccountBloc>().add(const LoadKhaltiAccount());
  }

  @override
  void dispose() {
    _khaltiIdController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Khalti Account'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<KhaltiAccountBloc, KhaltiAccountState>(
        listener: (context, state) {
          if (state is KhaltiAccountActionSuccess) {
            MySnackbar.showSuccess(context, state.message);
            setState(() => _isEditing = false);
          } else if (state is KhaltiAccountError) {
            MySnackbar.showError(context, state.message);
          } else if (state is KhaltiAccountLoaded && state.account != null) {
            _khaltiIdController.text = state.account!.khaltiId;
            _accountNameController.text = state.account!.accountName;
          }
        },
        builder: (context, state) {
          if (state is KhaltiAccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final account = _getAccount(state);
          final isLinked = account != null;
          final isActionLoading = state is KhaltiAccountActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKhaltiBrandCard(context, isLinked),
                const SizedBox(height: 24),
                if (!isLinked || _isEditing)
                  _buildForm(context, isLinked, isActionLoading)
                else
                  _buildAccountDetails(context, account!, isActionLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  dynamic _getAccount(KhaltiAccountState state) {
    if (state is KhaltiAccountLoaded) return state.account;
    if (state is KhaltiAccountActionLoading) return state.currentAccount;
    if (state is KhaltiAccountError) return state.currentAccount;
    if (state is KhaltiAccountActionSuccess) return state.account;
    return null;
  }

  Widget _buildKhaltiBrandCard(BuildContext context, bool isLinked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7D1E8A), Color(0xFF5A1464)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7D1E8A).withValues(alpha: 0.25),
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
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.asset('assets/images/khalti-icon.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khalti Payment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLinked ? 'Account linked' : 'Link Khalti account',
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
                ? 'Customers can pay online via Khalti.'
                : 'Link your Khalti account to receive customer payments online.',
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
                isUpdate ? 'Update Khalti Account' : 'Link Khalti Account',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your Khalti account details',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _khaltiIdController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  labelText: 'Khalti ID',
                  hintText: '98XXXXXXXX',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter Khalti ID';
                  if (value.length != 10) return 'Khalti ID must be 10 digits';
                  if (!value.startsWith('9'))
                    return 'Khalti ID must start with 9';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _accountNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  hintText: 'Enter account holder name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter account holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
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
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submit(isUpdate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7D1E8A),
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
            _buildDetailRow(Icons.phone_android, 'Khalti ID', account.khaltiId),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.person_outline,
              'Account Holder Name',
              account.accountName,
            ),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.verified,
              'Status',
              account.isActive ? 'Active' : 'Inactive',
              valueColor: account.isActive ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
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

    final khaltiId = _khaltiIdController.text.trim();
    final accountName = _accountNameController.text.trim();

    if (isUpdate) {
      context.read<KhaltiAccountBloc>().add(
        UpdateKhaltiAccount(khaltiId: khaltiId, accountName: accountName),
      );
    } else {
      context.read<KhaltiAccountBloc>().add(
        LinkKhaltiAccount(khaltiId: khaltiId, accountName: accountName),
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
            Text('Unlink Khalti'),
          ],
        ),
        content: const Text(
          'Are you sure you want to unlink your Khalti account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<KhaltiAccountBloc>().add(
                const UnlinkKhaltiAccount(),
              );
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
