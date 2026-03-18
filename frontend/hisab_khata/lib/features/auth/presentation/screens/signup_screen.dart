import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/core/theme/app_theme.dart';
import 'package:hisab_khata/core/utils/responsive.dart';
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
    final horizontalPadding = Responsive.w(context, 28).clamp(18.0, 36.0);
    final cardRadius = Responsive.radius(context, 32);

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
              AuthHeader(title: AppLocalizations.of(context)!.createAccount),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cardRadius),
                      topRight: Radius.circular(cardRadius),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(horizontalPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: Responsive.h(context, 10)),
                          RoleSelectionButtons(
                            selectedRole: _controller.selectedRole,
                            onRoleChanged: (role) {
                              setState(() {
                                _controller.selectedRole = role;
                              });
                            },
                          ),
                          SizedBox(height: Responsive.h(context, 20)),
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
                          SizedBox(height: Responsive.h(context, 20)),
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
                            SizedBox(height: Responsive.h(context, 20)),
                          ],
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
                          SizedBox(height: Responsive.h(context, 20)),
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
                          SizedBox(height: Responsive.h(context, 20)),
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
                          SizedBox(height: Responsive.h(context, 20)),
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
                          SizedBox(height: Responsive.h(context, 24)),
                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: Responsive.sp(context, 12),
                                  color: AppTheme.textSecondary,
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: AppLocalizations.of(
                                      context,
                                    )!.privacyPolicy,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 24)),
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
                          SizedBox(height: Responsive.h(context, 16)),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.alreadyHaveAccount,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: Responsive.sp(context, 14),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.login,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Responsive.sp(context, 14),
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
