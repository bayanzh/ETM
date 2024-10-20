import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/constant/image_constant.dart';
import 'package:e_training_mate/features/authentication/screens/initial_settings_screen.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_dark_colors.dart';

class CreatedAccountScreen extends StatelessWidget {
  const CreatedAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : Colors.white,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    
    final screenHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // -- created message and next button widget
            SizedBox(
              height: screenHeight * 0.4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "You're account created".tr,
                    style: TextStyle(
                        color: isDarkMode? null : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  CustomOutlinedButton(
                    text: 'Next'.tr,
                    onPressed: () => Get.off(() => const InitialSettingsScreen()),
                    buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
                    buttonStyle:  OutlinedButton.styleFrom(side: BorderSide.none),
                    rightIcon: Padding(
                      padding: AppHelper.startEndPadding(start: 7),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: isDarkMode? AppColors.primaryLight : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // -- Created Image Widget
            SizedBox(
              width: double.maxFinite,
              height: screenHeight * 0.6,
              // color: Colors.red,
              child: CustomImageView(
                imagePath: ImageConstant.createdAccountImage,
                fit: BoxFit.fill,
              ),
            )
          ],
        ),
      ),
    );
  }
}
