import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HybridRequestScreen extends StatefulWidget {
  final bool isBusinessAccount;
  final bool isBusinessVerified;

  const HybridRequestScreen({
    super.key,
    required this.isBusinessAccount,
    this.isBusinessVerified = false,
  });

  @override
  State<HybridRequestScreen> createState() => _HybridRequestScreenState();
}

class _HybridRequestScreenState extends State<HybridRequestScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isUploading = false;
  bool _isRequestSubmitting = false;
  bool _isCitizenshipUploaded = false;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;

    setState(() {
      _selectedImage = image;
      _isCitizenshipUploaded = false;
    });
  }

  Future<void> _uploadCitizenship() async {
    if (_selectedImage == null || _isUploading) return;

    setState(() => _isUploading = true);

    // Frontend-only placeholder for upload integration.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isUploading = false;
      _isCitizenshipUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Citizenship uploaded successfully.')),
    );
  }

  Future<void> _submitHybridRequest() async {
    if (_isRequestSubmitting) return;

    final canRequest = widget.isBusinessAccount
        ? widget.isBusinessVerified && _isCitizenshipUploaded
        : _isCitizenshipUploaded;

    if (!canRequest) return;

    setState(() => _isRequestSubmitting = true);

    // Frontend-only placeholder for request submission integration.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() => _isRequestSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Switch to Hybrid request submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canRequest = widget.isBusinessAccount
        ? widget.isBusinessVerified && _isCitizenshipUploaded
        : _isCitizenshipUploaded;

    return Scaffold(
      appBar: AppBar(title: const Text('Hybrid Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isBusinessAccount) ...[
              _buildBusinessStatusCard(),
              const SizedBox(height: 16),
            ] else ...[
              _buildCustomerAccessCard(),
              const SizedBox(height: 16),
            ],
            _buildCitizenshipUploadSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: canRequest && !_isRequestSubmitting
                  ? _submitHybridRequest
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isRequestSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Request Switch to Hybrid'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessStatusCard() {
    final statusText = widget.isBusinessVerified ? 'Verified' : 'Not Verified';
    final statusColor = widget.isBusinessVerified
        ? Colors.green.shade700
        : Colors.red.shade700;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Verification Status',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  widget.isBusinessVerified
                      ? Icons.verified
                      : Icons.report_gmailerrorred,
                  color: statusColor,
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (!widget.isBusinessVerified) ...[
              const SizedBox(height: 8),
              Text(
                'Your business account must be verified before requesting Hybrid mode.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerAccessCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Customer account can directly request switch to Hybrid.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitizenshipUploadSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Citizenship Upload',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Camera'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  color: Colors.grey.shade50,
                ),
                child: const Center(
                  child: Text('No citizenship image selected.'),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_selectedImage != null && !_isUploading)
                  ? _uploadCitizenship
                  : null,
              icon: _isUploading
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload_outlined),
              label: Text(
                _isCitizenshipUploaded ? 'Uploaded' : 'Upload Citizenship',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
