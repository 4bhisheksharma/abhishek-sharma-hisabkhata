import 'package:flutter/material.dart';
import 'package:hisab_khata/core/constants/error_messages.dart';
import 'package:hisab_khata/core/constants/string_constants.dart';

typedef ValidatorFunctionType = String? Function(String?)?;
typedef ValidatorFunctionTypeObj = String? Function(Object?)?;
typedef TwoDotOnChanged = dynamic Function(String)?;

class Validators {
  static final RegExp _emailRegex = RegExp(StringConstant.emailRegx);

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email);

  static ValidatorFunctionType getPasswordValidator(String minLengthMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return ErrorMessage.passwordEmptyErrorText;
      }
      if (value.trim().length < 8) {
        return minLengthMessage;
      }
      return null;
    };
  }

  static ValidatorFunctionType getConfirmPasswordValidator(
    TextEditingController? controller,
    String emptyMessage,
    String notMatchMessage,
  ) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return emptyMessage;
      }
      if (value != controller?.text.trim()) {
        return notMatchMessage;
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

  static ValidatorFunctionType getMobileNumberValidator(String emptyMessage, String invalidMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return emptyMessage;
      }
      if (value.length != 10) {
        return invalidMessage;
      }
      return null;
    };
  }

  static ValidatorFunctionType getEmailValidator(String emptyMessage, String invalidMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return emptyMessage;
      }
      if (!isValidEmail(value.trim())) {
        return invalidMessage;
      }
      return null;
    };
  }
}
