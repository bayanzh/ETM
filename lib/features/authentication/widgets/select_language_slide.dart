import 'package:e_training_mate/common/widgets/custom_dropdownbutton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';

class SelectLanguageSlide extends StatelessWidget {
  const SelectLanguageSlide({
    super.key,
    this.submitButtonText = 'Next',
    this.showButtonArrow = true,
    this.initialValue = 1,
    this.onSubmit,
    this.onChange,
  });

  final String submitButtonText;
  final bool showButtonArrow;
  final int initialValue;
  final void Function(String selectedLangCode)? onSubmit;
  final void Function(String selectedLangCode)? onChange;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    late Object selectedLangValue = initialValue;
    final langsList = [
      DropDownItemModel(value: 1, text: "English".tr),
      DropDownItemModel(value: 2, text: "Arabic".tr),
    ];

    
    return Column(
      children: [
        
        // -- Created Image Widget
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.only(bottom: 50),
          child: CustomImageView(
            imagePath: ImageConstant.langaugeImage,
            fit: BoxFit.fill,
          ),
        ),

        // -- language message and next button widget
        Text(
          "Please select your favorite laungage".tr,
          style: TextStyle(
              color: isDarkMode? null : Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Container(
          width: 280,
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: CustomDropDownButton(
            items: langsList,
            initialValue: initialValue,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textGrey1, width: 1),
            ),
            onChange: (selectedValue) {
              selectedLangValue = selectedValue ?? selectedLangValue;
              onChange?.call(selectedLangValue == 2? 'ar' : 'en');
            },
          ),
        ),

        CustomOutlinedButton(
          text: 'Next'.tr,
          onPressed: () => onSubmit?.call(selectedLangValue == 2? 'ar' : 'en'),
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
