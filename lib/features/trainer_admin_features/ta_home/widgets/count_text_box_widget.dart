import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/utils/extensions/num_extension.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CountTextBoxWidget extends StatelessWidget {
  const CountTextBoxWidget({
    super.key,
    required this.count,
    required this.text,
    this.height = 110,
    this.width = 110,
  });

  final int count;
  final String text;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isDarkMode? AppDarkColors.container : Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            offset: Offset(0, 5),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(1, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            text.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDarkMode? null : AppColors.textBlueBlack,
            ),
          ),
          
          Expanded(
            child: Align(
              child: AppHelper.buildTextWithShadaw(
                count.makeToString(),
                blurRadius: 8,
                offset: const Offset(0.5, 3),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w500,
                  height: 1.1,
                  color: isDarkMode? null : AppColors.textBlueBlack,
                ),
              ),
            ),
          ),
          
          
        ],
      ),
    );
  }
}
