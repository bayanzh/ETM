import 'package:get/get.dart';

class ValidationHelper {
  static String? emptyValidator(Object? value, {String? message}) {
    String? strValue = value?.toString();
    if (strValue == null || strValue.trim().isEmpty) {
      return message ?? "Required field.".tr;
    }
    return null;
  }

  static bool isEmptyValidator(String? value) {
    return value == null || value.trim().isEmpty;
  }

  static String? emailValidator(String? value, {String? message}) {
    value ??= value?.trim();
    if (isEmptyValidator(value)) {
      return "Email cannot empty.".tr;
    }
    if (!GetUtils.isEmail(value!)) {
      return message ?? "Invalid email format.".tr;
    }
    return null;
  }

  static String? passwordValidator(String? value,
      {int min = 6, max = 30, String? confirmPass}) {
    
    if (confirmPass != null){
      return value != confirmPass? "Password does not match.".tr : null;
    }

    if (isEmptyValidator(value)) {
      return "Password cannot empty.".tr;
    }
    if (GetUtils.isLengthLessThan(value!, min)) {
      return "${'The password must be greater than or equal'.tr} $min ${'characters.'.tr}";
    }
    if (GetUtils.isLengthGreaterThan(value, max)) {
      return "Too long password.".tr;
    }
    
    return null;
  }

  static String? phoneValidator(String? value, {bool isRequired = true}) {
    if (isEmptyValidator(value)) {
      return isRequired ? "Required field.".tr : null;
    }
    if (!GetUtils.hasMatch(value!, r'^\+?[0-9]*$')){
      return "The phone number must be numbers only.".tr;
    }
    if (GetUtils.isLengthLessThan(value, 9)) {
      return "The phone number is too short.".tr;
    }
    if (GetUtils.isLengthGreaterThan(value, 15)) {
      return "The phone number is too long.".tr;
    }
    return null;
  }

  static String? numberValidator(String? value, 
      {int min = 1, int max = 100, String? shortMsg, String? longMsg, bool isRequired = true}) {
    if (isEmptyValidator(value)) {
      return isRequired ? "Required field.".tr : null;
    }
    if (!GetUtils.hasMatch(value!, r'^[0-9]*$')){
      return "It must be numbers only.".tr;
    }
    return lengthValidator(value, min: min, max: max, longMsg: longMsg, shortMsg: shortMsg, isRequired: isRequired);
  }

  static String? lengthValidator(String? value,
      {int min = 4, int max = 250, String? shortMsg, String? longMsg, bool isRequired = true}) {
    if (isRequired && isEmptyValidator(value)) {
      return "Required field.".tr;
    }
    if (GetUtils.isLengthLessThan(value!, min)) {
      return shortMsg?.tr ?? "Too short.".tr;
    }
    if (GetUtils.isLengthGreaterThan(value, max)) {
      return longMsg?.tr ?? "Too long.".tr;
    }
    return null;
  }

  static String getNumricOnly(String value, {bool isDouble = false}){
    var numericOnlyStr = '';
    for (var i = 0; i < value.length; i++) {
      if (GetUtils.isNumericOnly(value[i]) || (isDouble && value[i] == '.')) {
        numericOnlyStr += value[i];
      }
    }
    return numericOnlyStr;
  }
}