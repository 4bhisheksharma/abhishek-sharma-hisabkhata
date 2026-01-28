import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/utils/helper_functions.dart';
import '../../domain/services/ocr_service.dart';
import '../../domain/services/image_transaction_parser.dart';

/// Dialog for adding transaction via image OCR
class ImageTransactionDialog extends StatefulWidget {
  const ImageTransactionDialog({super.key});

  @override
  State<ImageTransactionDialog> createState() => _ImageTransactionDialogState();
}

class _ImageTransactionDialogState extends State<ImageTransactionDialog> {
  File? _selectedImage;
  bool _isProcessing = false;
  String _extractedText = '';
  ParsedImageTransaction? _parsedTransaction;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Auto-open image picker when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pickImage();
    });
  }

  Future<void> _pickImage() async {
    final image = await HelperFunctions.showImageSourcePicker(context);

    if (image != null) {
      setState(() {
        _selectedImage = image;
        _isProcessing = true;
        _errorMessage = '';
        _extractedText = '';
        _parsedTransaction = null;
      });

      await _processImage(image);
    } else {
      // User cancelled image picking, close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _processImage(File imageFile) async {
    try {
      // Extract text using OCR
      final extractedText = await OcrService.extractTextFromImage(imageFile);

      if (extractedText == null || extractedText.isEmpty) {
        setState(() {
          _isProcessing = false;
          _errorMessage = 'No text found in image. Please try another image.';
        });
        return;
      }

      setState(() {
        _extractedText = extractedText;
      });

      // Parse the extracted text
      final parsed = ImageTransactionParser.parse(extractedText);

      setState(() {
        _isProcessing = false;
        _parsedTransaction = parsed;
        if (parsed == null) {
          _errorMessage =
              'Could not extract transaction details. Please edit manually.';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Error processing image: $e';
      });
    }
  }

  void _confirm() {
    if (_parsedTransaction != null) {
      Navigator.of(context).pop(_parsedTransaction);
    }
  }

  void _retryWithNewImage() {
    setState(() {
      _selectedImage = null;
      _extractedText = '';
      _parsedTransaction = null;
      _errorMessage = '';
    });
    _pickImage();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenWidth * 0.95 : 550,
          maxHeight: screenHeight * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: AppTheme.lightBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Image Transaction',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          'Extract details from receipt',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.primaryBlue),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview
                    if (_selectedImage != null) ...[
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Processing indicator
                    if (_isProcessing) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.lightBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppTheme.primaryBlue,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Extracting text from image...',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Extracted text
                    if (_extractedText.isNotEmpty && !_isProcessing) ...[
                      Text(
                        'Extracted Text:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxHeight: 150),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            _extractedText,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Parsed transaction details
                    if (_parsedTransaction != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.lightBlue,
                              AppTheme.lightBlue.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Transaction Details',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getConfidenceColor(
                                      _parsedTransaction!.confidence,
                                    ).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getConfidenceIcon(
                                          _parsedTransaction!.confidence,
                                        ),
                                        size: 14,
                                        color: _getConfidenceColor(
                                          _parsedTransaction!.confidence,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${(_parsedTransaction!.confidence * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getConfidenceColor(
                                            _parsedTransaction!.confidence,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Rs. ${_parsedTransaction!.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 50,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _parsedTransaction!.description,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Error message
                    if (_errorMessage.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  if (!_isProcessing) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _retryWithNewImage,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(AppLocalizations.of(context)!.newImage),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_parsedTransaction != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _confirm,
                          icon: const Icon(Icons.check, size: 18),
                          label: Text(AppLocalizations.of(context)!.confirm),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double confidence) {
    if (confidence >= 0.7) return Icons.verified;
    if (confidence >= 0.5) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }
}
