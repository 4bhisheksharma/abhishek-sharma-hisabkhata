import 'package:flutter/material.dart';
import 'package:hisab_khata/core/constants/error_messages.dart';
import 'package:hisab_khata/core/constants/string_constants.dart';

typedef ValidatorFunctionType = String? Function(String?)?;
typedef ValidatorFunctionTypeObj = String? Function(Object?)?;
typedef TwoDotOnChanged = dynamic Function(String)?;

class Validators {
  static final RegExp _emailRegex = RegExp(
    r'^[\w+\-\.]+@([\w-]+\.)+[\w-]{2,}$',
  );

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  static ValidatorFunctionType getPasswordValidator() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return ErrorMessage.passwordEmptyErrorText;
      }
      if (value.trim().length < 8) {
        return StringConstant.passwordMinLength;
      }
      return null;
    };
  }

  static ValidatorFunctionType getConfirmPasswordValidator(
    TextEditingController? controller,
  ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return ErrorMessage.passwordEmptyErrorText;
      }
      if (value != controller?.text.trim()) {
        return ErrorMessage.confirmPasswordNotMatchErrorText;
      }
      return null;
    };
  }

  static ValidatorFunctionType getTextFieldValidator(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }

  static ValidatorFunctionType getMobileNumberValidator() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return StringConstant.enterMobileNumber;
      }
      if (value.length != 10) {
        return StringConstant.enterValidMobileNumber;
      }
      return null;
    };
  }

  static ValidatorFunctionType getEmailValidator() {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return 'Field cannot be empty';
      }
      if (!isValidEmail(value.trim())) {
        return 'Enter a valid email';
      }
      return null;
    };
  }
}
