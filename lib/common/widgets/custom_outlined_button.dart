import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/helpers/app_helper.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key, 
    required this.text,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    this.padding,
    this.onPressed,
    this.buttonStyle,
    this.buttonTextStyle,
    this.isDisabled,
    this.alignment,
    this.height,
    this.width,
    this.margin,
    this.isLoading = false,
    this.loadingIndicatorSize = 25,
    this.loadingIndicatorColor,
  });

  final String text;

  final VoidCallback? onPressed;

  final ButtonStyle? buttonStyle;

  final TextStyle? buttonTextStyle;

  final bool? isDisabled;

  final double? height;

  final double? width;

  final EdgeInsets? margin;

  final Alignment? alignment;

  final BoxDecoration? decoration;

  final Widget? leftIcon;

  final Widget? rightIcon;

  final EdgeInsets? padding;

  final bool isLoading;

  final double? loadingIndicatorSize;

  final Color? loadingIndicatorColor;


  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: buildOutlinedButtonWidget)
        : buildOutlinedButtonWidget;
  }

  Widget get buildOutlinedButtonWidget => Container(
        height: height ?? 26,
        width: width, 
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: OutlinedButton(
          style: buttonStyle?.copyWith(
            minimumSize: const WidgetStatePropertyAll(Size(48, 10)),
          ),
          onPressed: isDisabled ?? false ? null : onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading) ...[
                Padding(
                  padding: AppHelper.startEndPadding(start: 0, end: 10),
                  child: AppHelper.circularProgressIndicator(size: loadingIndicatorSize, color: loadingIndicatorColor),
                ),
                Flexible(child: Text('Loading...'.tr))
              ],

              if (!isLoading) ...[
                leftIcon ?? const SizedBox.shrink(),
                Text(
                  text.tr,
                  style: buttonTextStyle ??
                      Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                ),
                rightIcon ?? const SizedBox.shrink(),
              ],
            ],
          ),
        ),
      );
}