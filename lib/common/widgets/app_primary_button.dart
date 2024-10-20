import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/app_helper.dart';
import 'custom_outlined_button.dart';



class AppPrimaryButton extends StatelessWidget {
  final String text;
  final bool isDisabled;
  final bool isLoading;
  final double? width;
  final double? height;
  final TextStyle? textStyle;
  final EdgeInsets? margin;
  final void Function()? onTap;

  const AppPrimaryButton({
    super.key,
    required this.text,
    this.isDisabled = false,
    this.isLoading = false,
    this.width,
    this.height,
    this.textStyle,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomOutlinedButton(
      margin: margin,
      text: isLoading? "Loading...".tr : text,
      onPressed: onTap,
      isDisabled: isLoading || isDisabled,
      leftIcon: isLoading? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: AppHelper.custumProgressIndecator(size: 25, color: Colors.white),
      ): null,
      height: height?? 45,
      width: width,
      buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
      buttonTextStyle: textStyle ?? Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontSize: 16, color: Colors.white),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDisabled? AppColors.disabledButton : AppColors.primary2,
      ),
    );
  }
}
