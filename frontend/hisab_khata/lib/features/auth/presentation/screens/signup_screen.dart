import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:hisab_khata/core/utils/controllers/auth_controller.dart';
import 'package:hisab_khata/core/utils/validators/validators.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/auth_header.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/role_selection_buttons.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_event.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = SignupController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      if (_controller.passwordController.text !=
          _controller.confirmPasswordController.text) {
        MySnackbar.showError(
          context,
          AppLocalizations.of(context)!.passwordsDoNotMatch,
        );
        return;
      }

      context.read<AuthBloc>().add(
        RegisterEvent(
          email: _controller.emailController.text.trim(),
          password: _controller.passwordController.text,
          fullName: _controller.nameController.text.trim(),
          phoneNumber: _controller.mobileController.text.trim().isEmpty
              ? null
              : _controller.mobileController.text.trim(),
          role: _controller.selectedRole,
          businessName: _controller.selectedRole == 'business'
              ? _controller.businessNameController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          MySnackbar.showSuccess(context, state.message);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(email: state.email),
            ),
          );
        } else if (state is AuthError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section with Create Account Text
              AuthHeader(title: AppLocalizations.of(context)!.createAccount),

              // Bottom Card Section
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),

                          // Role Selection Buttons
                          RoleSelectionButtons(
                            selectedRole: _controller.selectedRole,
                            onRoleChanged: (role) {
                              setState(() {
                                _controller.selectedRole = role;
                              });
                            },
                          ),
                          const SizedBox(height: 20),

                          // Full Name Field
                          MyTextField(
                            controller: _controller.nameController,
                            label: AppLocalizations.of(context)!.fullName,
                            hintText: AppLocalizations.of(
                              context,
                            )!.fullNameHintText,
                            validator: Validators.getTextFieldValidator(
                              AppLocalizations.of(context)!.enterName,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Business Name Field (only for business role)
                          if (_controller.selectedRole == 'business') ...[
                            MyTextField(
                              controller: _controller.businessNameController,
                              label: AppLocalizations.of(context)!.businessName,
                              hintText: AppLocalizations.of(
                                context,
                              )!.businessNameHintText,
                              validator: Validators.getTextFieldValidator(
                                AppLocalizations.of(context)!.enterBusinessName,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Email Field
                          MyTextField(
                            controller: _controller.emailController,
                            label: AppLocalizations.of(context)!.email,
                            hintText: AppLocalizations.of(
                              context,
                            )!.emailHintText,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.getEmailValidator(
                              AppLocalizations.of(context)!.enterEmail,
                              AppLocalizations.of(context)!.enterValidEmail,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Mobile Number Field
                          MyTextField(
                            controller: _controller.mobileController,
                            label: AppLocalizations.of(context)!.mobileNumber,
                            maxLength: 10,
                            hintText: AppLocalizations.of(
                              context,
                            )!.mobileNumberHintText,
                            keyboardType: TextInputType.phone,
                            validator: Validators.getMobileNumberValidator(
                              AppLocalizations.of(context)!.enterMobileNumber,
                              AppLocalizations.of(
                                context,
                              )!.enterValidMobileNumber,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          MyTextField(
                            controller: _controller.passwordController,
                            label: AppLocalizations.of(context)!.password,
                            hintText: AppLocalizations.of(
                              context,
                            )!.passwordHintText,
                            obscureText: true,
                            showPasswordToggle: true,
                            validator: Validators.getPasswordValidator(
                              AppLocalizations.of(context)!.passwordMinLength,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Confirm Password Field
                          MyTextField(
                            controller: _controller.confirmPasswordController,
                            label: AppLocalizations.of(
                              context,
                            )!.confirmPassword,
                            hintText: AppLocalizations.of(
                              context,
                            )!.passwordHintText,
                            obscureText: true,
                            showPasswordToggle: true,
                            validator: Validators.getConfirmPasswordValidator(
                              _controller.passwordController,
                              AppLocalizations.of(
                                context,
                              )!.passwordEmptyErrorText,
                              AppLocalizations.of(
                                context,
                              )!.confirmPasswordNotMatchErrorText,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Terms Text
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                children: [
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.agreeToTerms,
                                  ),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.termsOfUse,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(text: " and "),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.privacyPolicy,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Sign Up Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return MyButton(
                                text: AppLocalizations.of(context)!.signUp,
                                onPressed: _handleSignup,
                                isLoading: state is AuthLoading,
                                height: 54,
                                borderRadius: 27,
                                width: double.infinity,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Login Link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.alreadyHaveAccount,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
