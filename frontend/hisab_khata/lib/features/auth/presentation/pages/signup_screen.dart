import 'package:flutter/material.dart';
import 'package:hisab_khata/features/auth/data/datasources/auth_service.dart';
import 'package:hisab_khata/core/data/api_service.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/features/auth/presentation/pages/otp_verification_screen.dart';
import 'package:hisab_khata/core/utils/controllers/auth_controller.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/auth_header.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/role_selection_buttons.dart';

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

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_controller.passwordController.text !=
          _controller.confirmPasswordController.text) {
        MySnackbar.showError(context, 'Passwords do not match');
        return;
      }

      setState(() {
        _controller.isLoading = true;
      });

      try {
        final response = await AuthService.register(
          email: _controller.emailController.text.trim(),
          password: _controller.passwordController.text,
          fullName: _controller.nameController.text.trim(),
          phoneNumber: _controller.mobileController.text.trim().isEmpty
              ? null
              : _controller.mobileController.text.trim(),
          role: _controller.selectedRole,
        );

        if (!mounted) return;

        if (response['status'] == 200) {
          MySnackbar.showSuccess(
            context,
            response['message'] ?? 'Registration successful',
          );

          // Navigate to OTP verification screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                email: _controller.emailController.text.trim(),
              ),
            ),
          );
        } else {
          MySnackbar.showError(
            context,
            response['message'] ?? 'Registration failed',
          );
        }
      } on ApiException catch (e) {
        if (!mounted) return;

        MySnackbar.showError(context, e.message);
      } catch (e) {
        if (!mounted) return;

        MySnackbar.showError(context, 'An unexpected error occurred');
      } finally {
        if (mounted) {
          setState(() {
            _controller.isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section with Create Account Text
            const AuthHeader(title: 'Create Account'),

            // Bottom Card Section
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFE8F5F1),
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

                        // Full Name Field
                        MyTextField(
                          controller: _controller.nameController,
                          label: 'Full Name Or Business Name',
                          hintText: 'RamKumar',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

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

                        // Email Field
                        MyTextField(
                          controller: _controller.emailController,
                          label: 'Email',
                          hintText: 'example@example.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Mobile Number Field
                        MyTextField(
                          controller: _controller.mobileController,
                          label: 'Mobile Number',
                          hintText: '+977 9800000000',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        MyTextField(
                          controller: _controller.passwordController,
                          label: 'Password',
                          hintText: '••••••••',
                          obscureText: true,
                          showPasswordToggle: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        MyTextField(
                          controller: _controller.confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: '••••••••',
                          obscureText: true,
                          showPasswordToggle: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
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
                                TextSpan(text: 'By continuing, you agree to\n'),
                                TextSpan(
                                  text: 'Terms of Use',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy.',
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
                        MyButton(
                          text: 'Sign Up',
                          onPressed: _handleSignup,
                          isLoading: _controller.isLoading,
                          height: 54,
                          borderRadius: 27,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),

                        // Login Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
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
                                  'Log In',
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
    );
  }
}
