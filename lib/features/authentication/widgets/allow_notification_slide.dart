import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class AllowNotificationSlide extends StatefulWidget {
  const AllowNotificationSlide({
    super.key,
    this.submitButtonText = 'Next',
    this.showButtonArrow = true,
    this.isEnabled = true,
    this.onSubmit,
  });

  final String submitButtonText;
  final bool showButtonArrow;
  final bool isEnabled;
  final void Function(bool value)? onSubmit;

  @override
  State<AllowNotificationSlide> createState() => _AllowNotificationSlideState();
}

class _AllowNotificationSlideState extends State<AllowNotificationSlide> {
  late RxBool isEnabled = widget.isEnabled.obs;

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
            imagePath: ImageConstant.notificationImage,
            fit: BoxFit.fill,
          ),
        ),

        // -- Allow Notification message and next button widget
        Text(
          "Allow us to send notifications to you".tr,
          style: TextStyle(
              color: isDarkMode? null : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        Container(
          width: 250,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Obx(() => Switch(
            value: isEnabled.value,
            onChanged: (value) => isEnabled.value = value,
          )),
        ),

        CustomOutlinedButton(
          text: 'Next'.tr,
          onPressed: () => widget.onSubmit?.call(isEnabled.value),
          buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary,),
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
