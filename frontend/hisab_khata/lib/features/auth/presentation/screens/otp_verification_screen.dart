import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisab_khata/config/theme/app_theme.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';
import 'package:hisab_khata/core/utils/controllers/auth_controller.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/auth_header.dart';
import 'package:hisab_khata/features/auth/presentation/widgets/otp_input_fields.dart';
import 'package:hisab_khata/l10n/app_localizations.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_event.dart';
import 'package:hisab_khata/features/auth/presentation/bloc/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _controller = OtpController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _controller.resendTimer = 59;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_controller.resendTimer > 0) {
        setState(() {
          _controller.resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _handleVerifyOtp() {
    String otp = _controller.getOtp();

    if (otp.length != 6) {
      MySnackbar.showError(
        context,
        AppLocalizations.of(context)!.enterAllSixDigits,
      );
      return;
    }

    context.read<AuthBloc>().add(VerifyOtpEvent(email: widget.email, otp: otp));
  }

  void _handleResendOtp() {
    if (_controller.resendTimer > 0) {
      MySnackbar.showInfo(
        context,
        'Please wait ${_formatTime(_controller.resendTimer)} before resending',
      );
      return;
    }

    context.read<AuthBloc>().add(ResendOtpEvent(email: widget.email));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          MySnackbar.showSuccess(context, state.message);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else if (state is OtpResendSuccess) {
          MySnackbar.showSuccess(context, state.message);
          _startTimer();
          _controller.clearOtp();
          _controller.focusNodes[0].requestFocus();
        } else if (state is AuthError) {
          MySnackbar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body: SafeArea(
          child: Column(
            children: [
              // Top Section with Title
              AuthHeader(title: AppLocalizations.of(context)!.otpVerification),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Enter OTP Text
                        Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.enterOtp,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.otpSent,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // OTP Input Fields
                        OtpInputFields(
                          controllers: _controller.otpControllers,
                          focusNodes: _controller.focusNodes,
                        ),
                        const SizedBox(height: 40),

                        // Continue Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return MyButton(
                              text: AppLocalizations.of(
                                context,
                              )!.continueProcess,
                              onPressed: _handleVerifyOtp,
                              isLoading: state is AuthLoading,
                              height: 54,
                              borderRadius: 27,
                              width: double.infinity,
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // Resend OTP Button
                        GestureDetector(
                          onTap: _handleResendOtp,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _controller.resendTimer > 0
                                  ? '${AppLocalizations.of(context)!.resendOtpAfter}: ${_formatTime(_controller.resendTimer)}'
                                  : AppLocalizations.of(context)!.resendOtp,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
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
