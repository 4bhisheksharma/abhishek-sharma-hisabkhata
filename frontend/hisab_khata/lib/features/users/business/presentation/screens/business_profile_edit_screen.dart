import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/core/utils/validators/validators.dart';
import 'package:hisab_khata/shared/utils/image_utils.dart';

class BusinessProfileEditScreen extends StatefulWidget {
  const BusinessProfileEditScreen({super.key});
  @override
  State<BusinessProfileEditScreen> createState() =>
      _BusinessProfileEditScreenState();
}

class _BusinessProfileEditScreenState extends State<BusinessProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  File? _selectedImage;
  String? _currentProfilePicture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load profile data
    context.read<BusinessBloc>().add(const LoadBusinessProfile());
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<BusinessBloc>().add(
        UpdateBusinessProfileEvent(
          businessName: _businessNameController.text.trim(),
          fullName: _fullNameController.text.trim(),
          phoneNumber: _phoneNumberController.text.trim(),
          profilePicturePath: _selectedImage?.path,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Business Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocConsumer<BusinessBloc, BusinessState>(
        listener: (context, state) {
          if (state is BusinessProfileLoaded) {
            // Populate form fields
            _businessNameController.text = state.profile.businessName;
            _fullNameController.text = state.profile.fullName;
            _phoneNumberController.text = state.profile.phoneNumber;
            _emailController.text = state.profile.email;
            _currentProfilePicture = state.profile.profilePicture;
            setState(() {
              _isLoading = false;
            });
          } else if (state is BusinessProfileUpdated) {
            MySnackbar.showSuccess(context, state.message);
            // Reload profile to get updated data
            context.read<BusinessBloc>().add(const LoadBusinessProfile());
          } else if (state is BusinessError) {
            MySnackbar.showError(context, state.message);
            setState(() {
              _isLoading = false;
            });
          } else if (state is BusinessLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },

        builder: (context, state) {
          if (state is BusinessLoading &&
              _businessNameController.text.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture Section
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (ImageUtils.getFullImageUrl(
                                            _currentProfilePicture,
                                          ) !=
                                          null
                                      ? NetworkImage(
                                          ImageUtils.getFullImageUrl(
                                            _currentProfilePicture,
                                          )!,
                                        )
                                      : null)
                                  as ImageProvider?,
                        child:
                            _selectedImage == null &&
                                _currentProfilePicture == null
                            ? Icon(
                                Icons.business,
                                size: 70,
                                color: Theme.of(context).primaryColor,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _pickImage,
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  // Business Name Field
                  MyTextField(
                    controller: _businessNameController,
                    label: 'Business Name',
                    hintText: 'Enter your business name',
                    validator: Validators.getTextFieldValidator(
                      'Please enter your business name',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Full Name Field
                  MyTextField(
                    controller: _fullNameController,
                    label: 'Owner Full Name',
                    hintText: 'Enter owner full name',
                    validator: Validators.getTextFieldValidator(
                      'Please enter owner name',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email Field (Read-only)
                  MyTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Email',
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Phone Number Field
                  MyTextField(
                    controller: _phoneNumberController,
                    label: 'Phone Number',
                    hintText: 'Enter phone number',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }

                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  // Update Button
                  MyButton(
                    text: 'Update Profile',
                    onPressed: _handleUpdateProfile,
                    isLoading: _isLoading,
                    height: 54,
                    borderRadius: 27,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
