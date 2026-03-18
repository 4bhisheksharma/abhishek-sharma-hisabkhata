import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
import 'package:hisab_khata/features/users/business/domain/entities/verification_request.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/shared/utils/helper_functions.dart';
import 'package:hisab_khata/shared/widgets/shimmer/shimmer_widgets.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';

class BusinessVerificationScreen extends StatefulWidget {
  const BusinessVerificationScreen({super.key});

  @override
  State<BusinessVerificationScreen> createState() =>
      _BusinessVerificationScreenState();
}

class _BusinessVerificationScreenState
    extends State<BusinessVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  String _selectedDocumentType = 'business_registration';
  File? _selectedDocument;
  bool _isSubmitting = false;

  List<Map<String, String>> _getDocumentTypes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'value': 'business_registration', 'label': l10n.businessRegistration},
      {'value': 'pan_card', 'label': l10n.panCard},
      {'value': 'vat_certificate', 'label': l10n.vatCertificate},
      {'value': 'trade_license', 'label': l10n.tradeLicense},
      {'value': 'other', 'label': l10n.other},
    ];
  }

  @override
  void initState() {
    super.initState();
    context.read<BusinessBloc>().add(const LoadVerificationStatus());
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final file = await HelperFunctions.showImageSourcePicker(context);
    if (file != null) {
      setState(() {
        _selectedDocument = file;
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDocument == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pleaseSelectDocumentImage,
            ),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      context.read<BusinessBloc>().add(
        SubmitVerificationRequestEvent(
          documentPath: _selectedDocument!.path,
          documentType: _selectedDocumentType,
          note: _noteController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.businessVerification,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<BusinessBloc, BusinessState>(
        listener: (context, state) {
          if (state is BusinessVerificationRequestSubmitted) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            // Reload status after submission
            context.read<BusinessBloc>().add(const LoadVerificationStatus());
          } else if (state is BusinessError) {
            setState(() => _isSubmitting = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BusinessLoading && !_isSubmitting) {
            return const VerificationShimmer();
          }

          if (state is BusinessVerificationStatusLoaded) {
            return _buildContent(state.verificationStatus);
          }

          // Default: show submission form
          return _buildSubmissionForm(null);
        },
      ),
    );
  }

  Widget _buildContent(VerificationStatus status) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          _buildStatusCard(status),
          SizedBox(height: Responsive.h(context, 20)),

          // Show form if not verified and no pending request
          if (!status.isVerified && !status.hasPendingRequest) ...[
            Text(
              AppLocalizations.of(context)!.submitVerificationRequest,
              style: TextStyle(
                fontSize: Responsive.sp(context, 18),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.h(context, 12)),
            _buildSubmissionForm(status),
          ],

          // Show latest request details
          if (status.latestRequest != null) ...[
            SizedBox(height: Responsive.h(context, 20)),
            _buildLatestRequestCard(status.latestRequest!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(VerificationStatus status) {
    IconData icon;
    Color color;
    String title;
    String subtitle;

    if (status.isVerified) {
      icon = Icons.verified;
      color = AppTheme.successGreen;
      title = AppLocalizations.of(context)!.verified;
      subtitle = AppLocalizations.of(context)!.businessVerifiedSuccessfully;
    } else if (status.hasPendingRequest) {
      icon = Icons.hourglass_top_rounded;
      color = AppTheme.warningOrange;
      title = AppLocalizations.of(context)!.pendingReview;
      subtitle = AppLocalizations.of(context)!.verificationBeingReviewed;
    } else {
      icon = Icons.info_outline;
      color = AppTheme.infoBlue;
      title = AppLocalizations.of(context)!.notVerifiedTitle;
      subtitle = AppLocalizations.of(context)!.submitBusinessDocuments;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: Responsive.radius(context, 12),
            offset: Offset(0, Responsive.h(context, 4)),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: Responsive.sp(context, 40)),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          Text(
            title,
            style: TextStyle(
              fontSize: Responsive.sp(context, 20),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: Responsive.h(context, 8)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Responsive.sp(context, 14),
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionForm(VerificationStatus? status) {
    return Form(
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: Responsive.radius(context, 10),
              offset: Offset(0, Responsive.h(context, 2)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Type Dropdown
            Text(
              AppLocalizations.of(context)!.documentType,
              style: TextStyle(
                fontSize: Responsive.sp(context, 14),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.h(context, 8)),
            DropdownButtonFormField<String>(
              value: _selectedDocumentType,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.description_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 12),
                  ),
                  borderSide: const BorderSide(color: AppTheme.lightBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 12),
                  ),
                  borderSide: const BorderSide(color: AppTheme.lightBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.radius(context, 12),
                  ),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
              items: _getDocumentTypes(context).map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedDocumentType = value);
                }
              },
            ),
            SizedBox(height: Responsive.h(context, 20)),

            // Document Upload
            Text(
              AppLocalizations.of(context)!.uploadDocument,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDocument,
              child: Container(
                width: double.infinity,
                height: _selectedDocument != null ? null : 150,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedDocument != null
                        ? AppTheme.primaryBlue
                        : AppTheme.lightBlue,
                    width: _selectedDocument != null ? 2 : 1,
                    style: _selectedDocument != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                ),
                child: _selectedDocument != null
                    ? Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _selectedDocument!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.successGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.documentSelected,
                                style: const TextStyle(
                                  color: AppTheme.successGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _pickDocument,
                                child: Text(
                                  AppLocalizations.of(context)!.change,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: AppTheme.primaryBlue.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.tapToUploadDocument,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(
                              context,
                            )!.takePhotoOrChooseFromGallery,
                            style: TextStyle(
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Note Field
            Text(
              AppLocalizations.of(context)!.additionalNoteOptional,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Add any additional information about your business...',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: Icon(Icons.note_alt_outlined),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.lightBlue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.submitVerificationRequest,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestRequestCard(VerificationRequest request) {
    Color statusColor;
    IconData statusIcon;

    switch (request.status) {
      case 'approved':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.warningOrange;
        statusIcon = Icons.hourglass_top;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.latestRequest,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            AppLocalizations.of(context)!.status,
            request.status.toUpperCase(),
            icon: statusIcon,
            valueColor: statusColor,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            AppLocalizations.of(context)!.documentType,
            _getDocumentTypeLabel(request.documentType),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            AppLocalizations.of(context)!.submitted,
            request.createdAt,
          ),
          if (request.note != null && request.note!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(AppLocalizations.of(context)!.note, request.note!),
          ],
          if (request.adminRemarks != null &&
              request.adminRemarks!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(
              AppLocalizations.of(context)!.adminRemarks,
              request.adminRemarks!,
              valueColor: statusColor,
            ),
          ],
          if (request.isRejected) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Reset form to allow resubmission
                  setState(() {
                    _selectedDocument = null;
                    _noteController.clear();
                  });
                  // Scroll to form would be nice but just reload
                  context.read<BusinessBloc>().add(
                    const LoadVerificationStatus(),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: Text(AppLocalizations.of(context)!.submitNewRequest),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (icon != null) ...[
          Icon(icon, size: 16, color: valueColor),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  String _getDocumentTypeLabel(String? type) {
    final match = _getDocumentTypes(
      context,
    ).where((t) => t['value'] == type).toList();
    return match.isNotEmpty ? match.first['label']! : type ?? 'N/A';
  }
}
