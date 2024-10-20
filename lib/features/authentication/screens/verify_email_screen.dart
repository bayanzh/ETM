import 'package:e_training_mate/common/widgets/app_primary_button.dart';
import 'package:e_training_mate/core/constant/image_constant.dart';
import 'package:e_training_mate/features/authentication/controllers/verify_email_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constant/app_dark_colors.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : Colors.white,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    var height = MediaQuery.of(context).size.height;
    final controller = Get.find<VerifyEmailController>();

    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: kToolbarHeight),
          children: [
            Lottie.asset(ImageConstant.emailAnimated),

            if (FirebaseAuth.instance.currentUser?.email != null) ...[
              Text(
                FirebaseAuth.instance.currentUser!.email!,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],

            Text(
              'Please open your email to confirm your account so you can access your account and enjoy the benefits offered by the application.'.tr,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: height * 0.05),
        
            AppPrimaryButton(text: 'Check account status', onTap: controller.checkEmailVerification),
            const SizedBox(height: 15),

            TextButton(
              onPressed: controller.sendEmailVerification,
              child: Text('Resend'.tr, style: const TextStyle(fontSize: 15)),
            ),

            TextButton(
              onPressed: () {
                controller.backToLogin();
                Get.delete<VerifyEmailController>();
              },
              child: Text('Back to login'.tr, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}