import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisab_khata/features/auth/services/auth_service.dart';
import 'package:hisab_khata/core/services/api_service.dart';
import 'package:hisab_khata/shared/widgets/my_button.dart';
import 'package:hisab_khata/shared/widgets/my_snackbar.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 59;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _resendTimer = 59;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
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

  Future<void> _handleVerifyOtp() async {
    // Get OTP from all controllers
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      MySnackbar.showError(context, 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await AuthService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (response['status'] == 'success') {
        if (mounted) {
          MySnackbar.showSuccess(
            context,
            response['message'] ?? 'OTP verified successfully',
          );

          // Navigate to login screen after successful verification
          //TODO: ya direct homepage ma route garne ho tara we dont have home yet ani tesko lagi feri user role ni verify garnu 
          //so aaile ko lagi mai redirect hunchha
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          MySnackbar.showError(context, response['message'] ?? 'Invalid OTP');
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        MySnackbar.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        MySnackbar.showError(context, 'An unexpected error occurred');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    if (_resendTimer > 0) {
      if (mounted) {
        MySnackbar.showInfo(
          context,
          'Please wait ${_formatTime(_resendTimer)} before resending',
        );
      }
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await AuthService.resendOtp(email: widget.email);
      if (mounted) {
        MySnackbar.showSuccess(context, 'OTP resent successfully');
        _startTimer();

        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        MySnackbar.showError(context, 'Failed to resend OTP');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
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
            // Top Section with Title
            Padding(
              padding: const EdgeInsets.only(top: 40, bottom: 30),
              child: Text(
                'OTP Verification',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Enter OTP Text
                      Column(
                        children: [
                          Text(
                            'Enter OTP',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Which Is Sent To Your Mail',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                            ),
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  // Move to next field
                                  if (index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  } else {
                                    // Last field, unfocus
                                    _focusNodes[index].unfocus();
                                  }
                                } else if (value.isEmpty && index > 0) {
                                  // Move to previous field on backspace
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),

                      // Continue Button
                      MyButton(
                        text: 'Continue',
                        onPressed: _handleVerifyOtp,
                        isLoading: _isLoading,
                        height: 54,
                        borderRadius: 27,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 24),

                      // Resend OTP Button
                      GestureDetector(
                        onTap: _isResending ? null : _handleResendOtp,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFD4EBE5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _resendTimer > 0
                                ? 'Resend OTP After: ${_formatTime(_resendTimer)}'
                                : 'Resend OTP',
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
    );
  }
}
