import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:e_training_mate/core/services/fire_notification_service.dart';
import 'package:e_training_mate/features/authentication/screens/verify_email_screen.dart';
import 'package:e_training_mate/features/home/screens/main_screen.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/services/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../trainer_admin_features/ta_home/screens/ta_main_screen.dart';

class LoginController extends GetxController{
  final RxBool isLoading = false.obs;

  final loginFormKey = GlobalKey<FormState>();
  RxBool isLoginFieledsFill = false.obs;

  final emailCon = TextEditingController();
  final passwordCon = TextEditingController();

  RxBool securePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailCon.addListener(_checkFieldsFill);
    passwordCon.addListener(_checkFieldsFill);
  }

  @override
  void onClose() {
    emailCon.dispose();
    passwordCon.dispose();
    super.onClose();
  }

  // Update the validation of fill fields status
  void _checkFieldsFill() {
    isLoginFieledsFill.value = emailCon.text.isNotEmpty &&
        passwordCon.text.isNotEmpty;
  }

  void changPasswordVisible() {
    securePassword.value = !securePassword.value;
  }

  Future<void> submitLoginButton () async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    final uid = await loginStudent(
      emailCon.text.trim(),
      passwordCon.text,
    );

    if (uid != null) {
      final userData = await UserModel.getUserInfoById(uid);
      Logger.log("::::: Success get userData: $userData");


      if (userData != null) {
        final openAppAs = PrefHelper.getUserType();
        final signAs = userData.type;

        if ((openAppAs == UserTypeEnum.learner &&
                signAs != UserTypeEnum.learner) ||
            (openAppAs == UserTypeEnum.trainer &&
                signAs == UserTypeEnum.learner)) {
          AppHelper.showToastSnackBar(message: 'No user found for that email.', isError: true);
          await FirebaseAuth.instance.signOut();
          isLoading.value = false;
          return;
        }

        // -- send the user device token to firebase
        userData.updateUserToken();

        // -- store the user type in cache
        PrefHelper.setUserType(userData.type);

        if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
          if (userData.type == UserTypeEnum.learner) {
            Get.offAll(() => const MainScreen());
          } else {
            // -- subscribe the admin in adminTopic to receive admin notifications
            if (userData.type == UserTypeEnum.admin) {
              FireNotificationService.instance.subscribeToTopicNotification('adminTopic');
            }
            Get.offAll(() => const TaMainScreen());
          }
        } else {
          Get.to(() => const VerifyEmailScreen());
        }
      } else {
        // AppHelper.showToastSnackBar(message: "Unexpected error!, try again.");
        AppHelper.showToastSnackBar(message: 'User data not found. Please contact support.');
      }
    }
    isLoading.value = false;
  }

    //firebase functions

  Future<String?> loginStudent(String email, String password) async {
    try {
      if (await NetworkInfo().isConnected) {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        Logger.log("::::: Success Login Student Credential");
        return credential.user!.uid;
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    return null;
  }
}