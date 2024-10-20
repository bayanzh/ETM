import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class CreateProfileSlide extends StatelessWidget {
  const CreateProfileSlide({
    super.key,
    this.submitButtonText = 'Next',
    this.showButtonArrow = true,
    this.onSubmit,
  });

  final String submitButtonText;
  final bool showButtonArrow;
  final void Function()? onSubmit;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [

        // -- Allow Notification Image Widget
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(bottom: 50),
          child: CustomImageView(
            imagePath: ImageConstant.createProfileImage,
            fit: BoxFit.fill,
          ),
        ),

        // -- Allow Notification message and next button widget
        Text(
          "Let's create your profile".tr,
          style: TextStyle(
              color: isDarkMode? null : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 30),

        CustomOutlinedButton(
          text: 'Next'.tr,
          onPressed: () => onSubmit?.call(),
          buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
          buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
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
    );
  }
}
