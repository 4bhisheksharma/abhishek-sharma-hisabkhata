import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_bloc.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_event.dart';
import 'package:hisab_khata/features/users/business/presentation/bloc/business_state.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/core/utils/validators/validators.dart';
import 'package:hisab_khata/shared/utils/helper_functions.dart';
import 'package:hisab_khata/shared/widgets/profile/editable_profile_picture.dart';

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
    final image = await HelperFunctions.showImageSourcePicker(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
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
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.businessProfile),
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
                  EditableProfilePicture(
                    selectedImage: _selectedImage,
                    currentProfilePicture: _currentProfilePicture,
                    onTap: _pickImage,
                    placeholderIcon: Icons.business,
                  ),

                  const SizedBox(height: 30),
                  // Business Name Field
                  MyTextField(
                    controller: _businessNameController,
                    label: AppLocalizations.of(context)!.businessName,
                    hintText: AppLocalizations.of(context)!.businessNameHint,
                    validator: Validators.getTextFieldValidator(
                      AppLocalizations.of(context)!.enterBusinessName,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Full Name Field
                  MyTextField(
                    controller: _fullNameController,
                    label: AppLocalizations.of(context)!.ownerFullName,
                    hintText: AppLocalizations.of(context)!.ownerNameHint,
                    validator: Validators.getTextFieldValidator(
                      AppLocalizations.of(context)!.enterOwnerName,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email Field (Read-only)
                  MyTextField(
                    controller: _emailController,
                    label: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.emailHint,
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Phone Number Field
                  MyTextField(
                    controller: _phoneNumberController,
                    label: AppLocalizations.of(context)!.phoneNumber,
                    hintText: AppLocalizations.of(context)!.phoneNumberHint,
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
