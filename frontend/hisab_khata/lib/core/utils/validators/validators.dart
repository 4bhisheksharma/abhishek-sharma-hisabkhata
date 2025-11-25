import 'package:flutter/material.dart';
import 'package:hisab_khata/core/constants/error_messages.dart';

typedef ValidatorFunctionType = String? Function(String?)?;
typedef ValidatorFunctionTypeObj = String? Function(Object?)?;
typedef TwoDotOnChanged = dynamic Function(String)?;

class Validators {
  static ValidatorFunctionType getPasswordValidator() {
    return (value) {
      if (value!.trim().isEmpty) {
        return ErrorMessage.passwordEmptyErrorText;
      }

      return null;
    };
  }

  static ValidatorFunctionType getConfirmPasswordValidator(
      TextEditingController? controller) {
    return (value) {
      if (value!.trim().isEmpty) {
        return ErrorMessage.passwordEmptyErrorText;
      } else if (value != controller?.text) {
        return ErrorMessage.confirmPasswordNotMatchErrorText;
      }
      return null;
    };
  }

  static ValidatorFunctionType validateEmailOrPhoneNumber() {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Field cannot be empty';
      }

      final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');

      final ntcPrepaidRegex = RegExp(r'^984[0-9]{7}$|^986[0-9]{7}$');
      final ntcPostpaidRegex = RegExp(r'^985[0-9]{7}$');
      final ncellRegex = RegExp(r'^980[0-9]{7}$|^981[0-9]{7}$|^982[0-9]{7}$');

      if (emailRegex.hasMatch(value)) {
        return null;
      }

      if (ntcPrepaidRegex.hasMatch(value) ||
          ntcPostpaidRegex.hasMatch(value) ||
          ncellRegex.hasMatch(value)) {
        return null;
      }

      return 'Enter a valid email or phone number';
    };
  }
}