import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_bloc.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_event.dart';
import 'package:hisab_khata/features/users/customer/presentation/bloc/customer_state.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/core/utils/validators/validators.dart';
import 'package:hisab_khata/shared/utils/helper_functions.dart';
import 'package:hisab_khata/shared/widgets/profile/editable_profile_picture.dart';

class CustomerProfileEditScreen extends StatefulWidget {
  const CustomerProfileEditScreen({super.key});
  @override
  State<CustomerProfileEditScreen> createState() =>
      _CustomerProfileEditScreenState();
}

class _CustomerProfileEditScreenState extends State<CustomerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
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
    context.read<CustomerBloc>().add(const LoadCustomerProfile());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await HelperFunctions.showImageSourcePicker(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<CustomerBloc>().add(
        UpdateCustomerProfileEvent(
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
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerProfileLoaded) {
            // Populate form fields
            _fullNameController.text = state.profile.fullName;
            _phoneNumberController.text = state.profile.phoneNumber ?? '';
            _emailController.text = state.profile.email;
            _currentProfilePicture = state.profile.profilePicture;
            setState(() {
              _isLoading = false;
            });
          } else if (state is CustomerProfileUpdated) {
            MySnackbar.showSuccess(context, state.message);
            // Reload profile to get updated data
            context.read<CustomerBloc>().add(const LoadCustomerProfile());
          } else if (state is CustomerError) {
            MySnackbar.showError(context, state.message);
            setState(() {
              _isLoading = false;
            });
          } else if (state is CustomerLoading) {
            setState(() {
              _isLoading = true;
            });
          }
        },

        builder: (context, state) {
          if (state is CustomerLoading && _fullNameController.text.isEmpty) {
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
                  EditableProfilePicture(
                    selectedImage: _selectedImage,
                    currentProfilePicture: _currentProfilePicture,
                    onTap: _pickImage,
                    placeholderIcon: Icons.person,
                  ),

                  const SizedBox(height: 30),
                  // Full Name Field
                  MyTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    validator: Validators.getTextFieldValidator(
                      'Please enter your name',
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
                    hintText: 'Enter your phone number',
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
