import 'package:e_training_mate/common/header/app_header.dart';
import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/constant/image_constant.dart';
import 'package:e_training_mate/features/authentication/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/app_primary_button.dart';
import '../../../common/widgets/custom_search_view.dart';
import '../../../core/utils/helpers/validation_helper.dart';
import '../../../core/constant/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  LoginController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 40),
              
          Container(
            alignment: AlignmentDirectional.centerStart,
            child: CustomImageView(imagePath: isDarkMode? ImageConstant.etmLightIcon : ImageConstant.etmDarkIcon, height: 50),
          ),
      
          Text(
            "We are happy to you back".tr,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey1,
            ),
          ),
          const SizedBox(height: 50),

          Form(
            key: controller.loginFormKey,
            child: Column(
              children: [
                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Email",
                  controller: controller.emailCon,
                  margin: const EdgeInsets.only(bottom: 15),
                  validator: ValidationHelper.emailValidator,
                ),
          
                Obx(() => CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Password",
                  controller: controller.passwordCon,
                  validator: (value) => ValidationHelper.passwordValidator(value, min: 1, max: 250),
                  secureText: controller.securePassword.value,
                  suffix: Container(
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      onPressed: controller.changPasswordVisible,
                      style: IconButton.styleFrom(padding: EdgeInsets.zero),
                      icon: Icon(controller.securePassword.value
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomOutlinedButton(
                text: 'Forget Password?',
                onPressed: () => Get.to(() => const ForgetPasswordScreen()),
                // height: 40,
                buttonStyle: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
              ),
              
            ],
          ),

          const SizedBox(height: 30),

          Obx(() => AppPrimaryButton(
            text: "Log In",
            isDisabled: !controller.isLoginFieledsFill.value,
            isLoading: controller.isLoading.value,
            onTap: controller.submitLoginButton,
          )),

          Container(
            margin: const EdgeInsets.only(top: 40, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?".tr,
                  textAlign: TextAlign.center,
                ),

                TextButton(
                  onPressed: () => Get.back(closeOverlays: true),
                  child: Text("Sign up".tr),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}