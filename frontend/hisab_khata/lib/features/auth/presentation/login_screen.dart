import 'package:flutter/material.dart';
import 'package:hisab_khata/features/auth/services/auth_service.dart';
import 'package:hisab_khata/core/services/api_service.dart';
import 'package:hisab_khata/core/storage/storage_service.dart';
import 'package:hisab_khata/features/auth/models/login_response.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await AuthService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        final loginResponse = LoginResponse.fromJson(response);

        if (!mounted) return;

        if (loginResponse.isSuccess && loginResponse.data != null) {
          final userData = loginResponse.data!.user;
          final tokens = loginResponse.data!.tokens;

          // Save user session to local storage
          await StorageService.saveUserSession(tokens: tokens, user: userData);

          if (!mounted) return;

          MySnackbar.showSuccess(
            context,
            'Welcome back, ${userData.fullName}!',
          );

          // Navigate based on role
          if (userData.role == 'customer') {
            Navigator.pushReplacementNamed(context, '/customer_home');
          } else if (userData.role == 'business') {
            Navigator.pushReplacementNamed(context, '/business_home');
          }
        } else {
          MySnackbar.showError(context, loginResponse.message);
        }
      } on ApiException catch (e) {
        if (!mounted) return;

        String errorMessage = e.message;
        if (e.statusCode == 401) {
          errorMessage = 'Invalid email or password';
        } else if (e.statusCode == 403) {
          errorMessage = 'Please verify your email before logging in';
        } else if (e.statusCode == 0) {
          errorMessage = 'Network error. Please check your connection';
        }

        MySnackbar.showError(context, errorMessage);
      } catch (e) {
        if (!mounted) return;

        MySnackbar.showError(context, 'An unexpected error occurred');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
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
            // Top Section with Welcome Text
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

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
                        const SizedBox(height: 20),

                        // Email Field
                        MyTextField(
                          controller: _emailController,
                          label: 'Email',
                          hintText: 'ramdai@gmail.com',
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

                        // Password Field
                        MyTextField(
                          controller: _passwordController,
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
                        const SizedBox(height: 40),

                        // Login Button
                        MyButton(
                          text: 'Log In',
                          onPressed: _handleLogin,
                          isLoading: _isLoading,
                          height: 54,
                          borderRadius: 27,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 16),

                        // Forgot Password
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // TODO: Navigate to forgot password
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 180),

                        // Sign Up Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Sign Up',
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
