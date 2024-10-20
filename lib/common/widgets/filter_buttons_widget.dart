import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/app_colors.dart';
import 'custom_image_view.dart';



class FilterButtonsWidget extends StatelessWidget {
  FilterButtonsWidget({
    super.key,
    required this.buttonModels,
    this.onChanged,
    this.initialSelected,
    this.isAllActive = false,
    this.height = 26,
    this.alignment,
    this.margin,
    this.buttonHorPadding,
  });

  final List<FilterButtonModel> buttonModels;

  final void Function(FilterButtonModel selectedFilter)? onChanged;

  final Object? initialSelected;

  final bool isAllActive;

  final double height;

  final AlignmentGeometry? alignment;

  final EdgeInsets? margin;

  final double? buttonHorPadding;

  late final Rx<Object> selectedFilter =
      Rx(initialSelected ?? buttonModels[0].value);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      alignment: alignment,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: buttonModels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        shrinkWrap: true,
        itemBuilder: (context, index) => Obx(
          () {
            bool isActive = isAllActive
                ? true
                : selectedFilter.value == buttonModels[index].value;

            return CustomOutlinedButton(
              onPressed: () {
                selectedFilter.value = buttonModels[index].value;
                buttonModels[index].onTap?.call();
                onChanged?.call(buttonModels[index]);
              },
              text: buttonModels[index].text.tr,
              height: height,
              leftIcon: buttonModels[index].iconPath != null
                  ? Row(
                      children: [
                        CustomImageView(
                          imagePath: buttonModels[index].iconPath!,
                          height: buttonModels[index].iconHeight ?? 24,
                          width: buttonModels[index].iconWidth ?? 24,
                        ),

                      ],
                    )
                  : null,
              buttonTextStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isActive ? Colors.white : null,
                  ),
              buttonStyle: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: buttonHorPadding ?? 15),
                backgroundColor: isActive ? AppColors.primary2 : isDarkMode? null : Colors.white,
              ),
              decoration: isActive
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.primary,
                    )
                  : null,
            );
            
          },
        ),
      ),
    );
  }
}

class FilterButtonModel<T> {
  T value;
  String text;
  double? textFontSize;
  Function()? onTap;
  String? iconPath;
  double? iconWidth;
  double? iconHeight;

  FilterButtonModel({
    required this.value,
    required this.text,
    this.textFontSize,
    this.onTap,
    this.iconPath,
    this.iconWidth,
    this.iconHeight,
  }) {
    iconHeight ??= 20;
    iconWidth ??= 20;
  }
}
