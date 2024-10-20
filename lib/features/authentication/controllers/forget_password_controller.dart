import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPasswordController extends GetxController {
  RxBool isLoading = false.obs;
  
  final formKey = GlobalKey<FormState>();
  final emailCon = TextEditingController();
  
  
  Future<bool> sendResetPassLink() async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) return false;
      
      isLoading.value = true;

      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCon.text.trim());
      Get.back();

      DialogUtil.showResultDialog(
        title:  "Successful",
        message: 'Open your email for a link to reset your password.',
      );
      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    
    isLoading.value = false;
    return false;
  }
}