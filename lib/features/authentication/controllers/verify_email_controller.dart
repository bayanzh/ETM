import 'dart:async';

import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../common/enums/user_type_enum.dart';
import '../../../common/screens/success_screen.dart';
import '../../../core/services/network_info.dart';
import '../../../core/utils/helpers/pref_helper.dart';
import '../../../core/utils/logger.dart';
import '../../home/screens/main_screen.dart';
import '../../trainer_admin_features/ta_home/screens/ta_main_screen.dart';
import '../screens/initial_settings_screen.dart';

class VerifyEmailController extends GetxController {
  Timer? _authTimer;

  @override
  void onInit() {
    super.onInit();
    sendEmailVerification();
  }

  Future<void> sendEmailVerification() async {
    try {
      if (await NetworkInfo().isConnected) {
        DialogUtil.loadinDialog();
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
        setTimerForAuthRedirect();
        Get.back();

        AppHelper.showToastSnackBar(
          message: 'A link to verify your account has been sent to your email.',
          isSuccess: true,
        );
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } on FirebaseException catch (e) {
      if (Get.isDialogOpen ?? false)  Get.back();
      Logger.logError('Error Code: ${e.code}, message: ${e.message}');
      AppHelper.showToastSnackBar(message: e.message?? "Unexpected error!, try again.", isError: true);
    } catch (e) {
      if (Get.isDialogOpen ?? false)  Get.back();
      Logger.logError('Error: $e');
      AppHelper.showToastSnackBar(message: e.toString(), isError: true);
    }
  }

  // timer
  void setTimerForAuthRedirect() {
    _authTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      Logger.log('Timer Tick For auth');
      try {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (user?.emailVerified ?? false) {
          timer.cancel();
          whenSuccessVerified();
        }
      } catch (e) {
        Logger.logError('Error in verify email timer: $e');
      }
    });
  }

  Future<void> checkEmailVerification() async {
    if (await NetworkInfo().isConnected) {
      DialogUtil.loadinDialog();
      await FirebaseAuth.instance.currentUser?.reload();
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.emailVerified) {
        Get.back();
        whenSuccessVerified();
        return;
      }

      Get.back();
      AppHelper.showToastSnackBar(message: 'Your account is not verified yet');
    } else {
      AppHelper.showToastSnackBar(message: "You have not internet");
    }
  }

  void whenSuccessVerified() {
    PrefHelper.setDisplayIntialSettings(true);
    
    Get.offAll(() =>
      PrefHelper.isDisplayIntialSettings()
          ? const InitialSettingsScreen()
          : PrefHelper.getUserType() == UserTypeEnum.learner
              ? const MainScreen()
              : const TaMainScreen(),
    );

    DialogUtil.displayScreenDialog(SuccessScreen(
      title: "Your account has been successfully verified.".tr,
      onTapOk: () => Get.back(),
    ));
  }

  void backToLogin() {
    if (_authTimer != null && _authTimer!.isActive) {
      _authTimer!.cancel();
      Logger.log('Auth timer stopped.');
    }
    Get.offAll(() => const WelcomeScreen());
  }
}
