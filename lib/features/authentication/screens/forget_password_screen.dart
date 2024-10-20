import 'package:e_training_mate/features/authentication/controllers/forget_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/header/app_header.dart';
import '../../../common/widgets/app_primary_button.dart';
import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/custom_search_view.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/validation_helper.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  ForgetPasswordController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 40),
            Container(
            alignment: AlignmentDirectional.centerStart,
            child: CustomImageView(imagePath: ImageConstant.etmDarkIcon, height: 50),
          ),
              
          Text(
            "We are happy to you back".tr,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey1,
            ),
          ),
          const SizedBox(height: 50),

          Center(
            child: Text(
              'Enter your email to send a link to reset your account password',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 20),
      
          Form(
            key: controller.formKey,
            child: Column(
              children: [
                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter Your Email",
                  controller: controller.emailCon,
                  margin: const EdgeInsets.only(bottom: 20),
                  validator: ValidationHelper.emailValidator,
                ),
              ],
            ),
          ),
      
          const SizedBox(height: 20),
          Obx(() => AppPrimaryButton(
            text: "Reset password",
            isLoading: controller.isLoading.value,
            onTap: controller.sendResetPassLink,
          )),
          const SizedBox(height: 30),
        ]
      ),
    );
  }
}