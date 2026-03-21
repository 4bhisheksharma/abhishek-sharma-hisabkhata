import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/datasources/hybrid_switch_remote_datasource.dart';
import '../../data/repositories/hybrid_switch_repository_impl.dart';
import '../../domain/usecases/get_hybrid_switch_status_usecase.dart';
import '../../domain/usecases/get_my_hybrid_switch_requests_usecase.dart';
import '../../domain/usecases/submit_hybrid_switch_request_usecase.dart';
import '../../domain/usecases/upload_hybrid_citizenship_usecase.dart';
import '../bloc/hybrid_switch_bloc.dart';
import '../bloc/hybrid_switch_event.dart';
import '../bloc/hybrid_switch_state.dart';
import '../widgets/hybrid_switch_card.dart';

class HybridSwitchPage extends StatefulWidget {
  const HybridSwitchPage({super.key});

  @override
  State<HybridSwitchPage> createState() => _HybridSwitchPageState();
}

class _HybridSwitchPageState extends State<HybridSwitchPage> {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (!mounted || image == null) return;
    setState(() => _selectedImage = image);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final datasource = HybridSwitchRemoteDatasourceImpl();
        final repository = HybridSwitchRepositoryImpl(
          remoteDatasource: datasource,
        );
        return HybridSwitchBloc(
          getHybridSwitchStatusUseCase: GetHybridSwitchStatusUseCase(
            repository,
          ),
          getMyHybridSwitchRequestsUseCase: GetMyHybridSwitchRequestsUseCase(
            repository,
          ),
          uploadHybridCitizenshipUseCase: UploadHybridCitizenshipUseCase(
            repository,
          ),
          submitHybridSwitchRequestUseCase: SubmitHybridSwitchRequestUseCase(
            repository,
          ),
        )..add(const HybridSwitchLoadRequested());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Hybrid Switch Request')),
        body: BlocConsumer<HybridSwitchBloc, HybridSwitchState>(
          listener: (context, state) {
            if (state is HybridSwitchError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state is HybridSwitchLoaded &&
                state.message != null &&
                state.message!.isNotEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message!)));
              context.read<HybridSwitchBloc>().add(
                const HybridSwitchClearMessageRequested(),
              );
            }
          },
          builder: (context, state) {
            if (state is HybridSwitchLoading || state is HybridSwitchInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HybridSwitchError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HybridSwitchBloc>().add(
                          const HybridSwitchLoadRequested(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final loaded = state as HybridSwitchLoaded;
            final latestRequest = loaded.latestRequest;
            final isAlreadyApproved = latestRequest?.isApproved == true;
            final hasPendingRequest = latestRequest?.isPending == true;
            final allowRequestAction =
                loaded.status.canRequest &&
                !isAlreadyApproved &&
                !hasPendingRequest;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isAlreadyApproved) ...[
                    _buildApprovedCard(),
                    const SizedBox(height: 14),
                  ],

                  HybridSwitchCard(
                    status: loaded.status,
                    latestRequest: loaded.latestRequest,
                  ),
                  const SizedBox(height: 16),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Citizenship Upload',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: loaded.isUploading
                                    ? null
                                    : () => _pickImage(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Camera'),
                              ),
                              OutlinedButton.icon(
                                onPressed: loaded.isUploading
                                    ? null
                                    : () => _pickImage(ImageSource.gallery),
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
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 180,
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  color: Colors.grey.shade100,
                                  child: const Text('Unable to preview image'),
                                ),
                              ),
                            )
                          else
                            Container(
                              height: 110,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'No citizenship image selected.',
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedImage == null
                                ? 'Please select a citizenship image.'
                                : 'Selected: ${_selectedImage!.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed:
                                (_selectedImage == null ||
                                    loaded.isUploading ||
                                    isAlreadyApproved)
                                ? null
                                : () {
                                    context.read<HybridSwitchBloc>().add(
                                      HybridSwitchCitizenshipUploadRequested(
                                        citizenshipFile: File(
                                          _selectedImage!.path,
                                        ),
                                      ),
                                    );
                                  },
                            icon: loaded.isUploading
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload_outlined),
                            label: Text(
                              loaded.isUploading
                                  ? 'Uploading...'
                                  : 'Upload Citizenship',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: (!allowRequestAction || loaded.isSubmitting)
                        ? null
                        : () {
                            context.read<HybridSwitchBloc>().add(
                              HybridSwitchSubmitRequested(
                                hybridRequestId: loaded.latestRequest?.id,
                              ),
                            );
                          },
                    child: loaded.isSubmitting
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isAlreadyApproved
                                ? 'Already Approved'
                                : hasPendingRequest
                                ? 'Request Pending Review'
                                : 'Request Switch to Hybrid',
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildApprovedCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF81C784)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.verified, color: Color(0xFF2E7D32), size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hybrid Switch Approved',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your request has already been approved. You cannot submit another request.',
                  style: TextStyle(color: Color(0xFF33691E), fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
