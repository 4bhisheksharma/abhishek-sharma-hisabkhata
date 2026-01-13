import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/shared/widgets/my_text_field.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/core/utils/controllers/auth_controller.dart';
import 'package:hisab_khata/core/utils/validators/validators.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/auth_header.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_event.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AuthController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _controller.emailController.text.trim(),
          password: _controller.passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          final user = state.loginResult.user;
          MySnackbar.showSuccess(
            context,
            '${AppLocalizations.of(context)!.welcomeBack}, ${user.fullName}!',
          );

          // Navigate based on role
          if (user.role == 'customer') {
            Navigator.pushReplacementNamed(context, '/customer_home');
          } else if (user.role == 'business') {
            Navigator.pushReplacementNamed(context, '/business_home');
          }
        } else if (state is AuthError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section with Welcome Text
              AuthHeader(title: AppLocalizations.of(context)!.welcome),

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
                          const SizedBox(height: 20),

                          // Email Field
                          MyTextField(
                            controller: _controller.emailController,
                            label: AppLocalizations.of(context)!.email,
                            hintText: AppLocalizations.of(
                              context,
                            )!.emailHintText,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.getEmailValidator(
                              AppLocalizations.of(
                                context,
                              )!.emailOrUserNameEmptyErrorText,
                              AppLocalizations.of(
                                context,
                              )!.invalidEmailErrorText,
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
                          const SizedBox(height: 40),

                          // Login Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return MyButton(
                                text: AppLocalizations.of(context)!.login,
                                onPressed: _handleLogin,
                                isLoading: state is AuthLoading,
                                height: 54,
                                borderRadius: 27,
                                width: double.infinity,
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // Forgot Password
                          Center(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Navigate to forgot password
                              },
                              child: Text(
                                AppLocalizations.of(context)!.forgotPassword,
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
                                  AppLocalizations.of(context)!.dontHaveAccount,
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
                                    AppLocalizations.of(context)!.signUp,
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
