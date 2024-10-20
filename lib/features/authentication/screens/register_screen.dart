import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/common/widgets/app_primary_button.dart';
import 'package:e_training_mate/common/widgets/custom_search_view.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/core/utils/helpers/validation_helper.dart';
import 'package:e_training_mate/features/authentication/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/header/app_header.dart';
import '../../../common/widgets/custom_image_view.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  RegisterController get controller => Get.find();

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
            "Let's create your account".tr,
            style: TextStyle(
              // fontSize: 36,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey1,
            ),
          ),
          const SizedBox(height: 50),

          Form(
            key: controller.registerFormKey,
            child: Column(
              children: [
                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Email",
                  controller: controller.emailCon,
                  margin: const EdgeInsets.only(bottom: 9),
                  validator: ValidationHelper.emailValidator,
                ),

                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Name",
                  controller: controller.nameCon,
                  margin: const EdgeInsets.only(bottom: 9),
                  validator: ValidationHelper.emptyValidator,
                ),
                
                Obx(() => CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Password",
                  controller: controller.passwordCon,
                  margin: const EdgeInsets.only(bottom: 9),
                  validator: ValidationHelper.passwordValidator,
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
                
                Obx(() => CustomSearchView(
                  isSearchForm: false,
                  hintText: "Please Confirm Your Password",
                  controller: controller.confirmPasswordCon,
                  margin: const EdgeInsets.only(bottom: 20),
                  validator: (value) => ValidationHelper.passwordValidator(
                    value,
                    confirmPass: controller.passwordCon.text,
                  ),
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

          // -- create provider account check widget
          if (PrefHelper.getUserType() != UserTypeEnum.learner)
            Obx(
              () => ListTile(
                contentPadding: EdgeInsets.zero,
                visualDensity: const VisualDensity(horizontal: -4),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      visualDensity: const VisualDensity(horizontal: -4),
                      value: controller.checkProviderAccount.value,
                      onChanged: (value) {
                        controller.checkProviderAccount.value = value ?? false;
                      },
                    ),
                  ],
                ),
                
                title: Text(
                  'I would like to offer training programs on the platform'.tr,
                  style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textGrey1),
                ),
                subtitle: Text('please creating a service provider account'.tr),
              ),
            ),

          const SizedBox(height: 20),

          Obx(() => AppPrimaryButton(
            text: "Create Account",
            isDisabled: !controller.isRegisterFieldsFill.value,
            isLoading: controller.isLoading.value,
            onTap: controller.submitRegisterSignUpButton,
          )),

          Container(
            margin: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account?".tr,
                  textAlign: TextAlign.center,
                ),

                TextButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: Text("Log in".tr),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}