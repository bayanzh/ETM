import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/common/widgets/app_primary_button.dart';
import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:e_training_mate/core/constant/image_constant.dart';
import 'package:e_training_mate/features/authentication/screens/register_screen.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'common/header/app_header.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:  Colors.grey[300],
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 40),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome".tr,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.1
                  ),
                ),

                Text(
                  "We are happy to you join us".tr,
                  style: TextStyle(
                    // fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),

          Text(
            "Would you like to join as a".tr,
            style: const TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          AppPrimaryButton(
            text: "Trainer",
            margin: const EdgeInsets.symmetric(horizontal: 25),
            height: 52,
            onTap: () {
              PrefHelper.setUserType(UserTypeEnum.trainer);
              Get.to(() => const RegisterScreen());
            },
          ),
          const SizedBox(height: 20),

          AppPrimaryButton(
            text: "Learner",
            margin: const EdgeInsets.symmetric(horizontal: 25),
            height: 52,
            onTap: () {
              PrefHelper.setUserType(UserTypeEnum.learner);
              Get.to(() => const RegisterScreen());
            },
          ),
          
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.centerRight,
            child: CustomImageView(
              imagePath: ImageConstant.welcomeImage,
              width: 200,
            ),
          )
        ],
      ),
    );
  }
}
