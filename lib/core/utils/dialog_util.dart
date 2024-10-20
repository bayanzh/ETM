import 'package:e_training_mate/common/screens/dialog_widget_screen.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/app_primary_button.dart';
import '../../common/widgets/custom_outlined_button.dart';
import '../constant/app_colors.dart';

class DialogOptionItem {
  String text;
  void Function()? onTap;
  bool isDeleteOption;

  DialogOptionItem({
    required this.text,
    this.onTap,
    this.isDeleteOption = false,
  });
}

class DialogUtil {
  static Widget buildBoxForDialog({
    required Widget child,
    Color? color,
  }) {
    if (color == null) {
      final isDarkMode = Theme.of(Get.context!).brightness == Brightness.dark;
      color = isDarkMode? AppDarkColors.container : Colors.white;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 25 * Get.width / 392),
          constraints: const BoxConstraints(maxWidth: 400, minWidth: 250),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15)
          ),
          child: Card(color: Colors.transparent, elevation: 0, child: child),
        )
      ],
    );
  }

  static showOptionsDialog(List<DialogOptionItem> options) {
    return Get.dialog(
      buildBoxForDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < options.length; i++) ...[
              SizedBox(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(Get.overlayContext!).pop();
                    Get.closeAllSnackbars();
                    options[i].onTap?.call();
                  },
                  child: Row(children: [
                    Text(options[i].text),
                  ]),
                ),
              ),
              if (i != options.length - 1)
                Divider(height: 3, endIndent: 15, indent: 15, color: AppColors.textGrey1)
            ],
          ],
        ),
      ),
    );
  }

  static Future<bool?> showDeleteDialog<bool>({
    required String message,
  }) {
    final textTheme = Theme.of(Get.context!).textTheme;
    return Get.dialog(
      buildBoxForDialog(
        child: Column(
          children: [
            const SizedBox(height: 5),
            Text("Confirm deletion!".tr, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(message.tr,
                textAlign: TextAlign.center, style: textTheme.bodyMedium),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomOutlinedButton(
                  text: "Delete",
                  onPressed: () => Get.back(result: true),
                  height: 37,
                  buttonTextStyle:
                      textTheme.bodyMedium?.copyWith(color: Colors.white),
                  buttonStyle: OutlinedButton.styleFrom(
                    backgroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 20),
                CustomOutlinedButton(
                  text: "Cancel",
                  height: 37,
                  buttonTextStyle: textTheme.bodyMedium,
                  onPressed: () async {
                    Get.closeAllSnackbars();
                    Navigator.of(Get.overlayContext!).pop(false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  static Future<bool?> showConfirmDialog<bool>({
    required String message,
    String? title,
  }) {
    final textTheme = Theme.of(Get.context!).textTheme;
    return Get.dialog(buildBoxForDialog(
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text(title ?? "Confirmation message".tr, style: textTheme.titleMedium),
          
          const SizedBox(height: 8),
          Text(message.tr, textAlign: TextAlign.center, style: textTheme.bodyMedium),
          
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppPrimaryButton(
                text: "Confirm",
                height: 37,
                textStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
                onTap: () {
                  Get.closeAllSnackbars();
                  Navigator.of(Get.overlayContext!).pop(true);
                },
              ),

              const SizedBox(width: 20),
              CustomOutlinedButton(
                text: "Cancel",
                height: 37,
                buttonTextStyle: textTheme.bodyMedium,
                onPressed: () async {
                  Get.closeAllSnackbars();
                  Navigator.of(Get.overlayContext!).pop(false);
                },
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    ));
  }
  
  static Future<bool?> showResultDialog<bool>({
    required String message,
    String? title,
    Color? titleColor,
  }) {
    final textTheme = Theme.of(Get.context!).textTheme;
    return Get.dialog(buildBoxForDialog(
      child: Column(
        children: [
          const SizedBox(height: 5),
          if (title != null)
            Text(title, style: textTheme.titleMedium?.copyWith(color: titleColor)),
          
          const SizedBox(height: 8),
          Text(message.tr, textAlign: TextAlign.center, style: textTheme.bodyMedium),
          
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppPrimaryButton(
                text: "Ok",
                height: 37,
                textStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
                onTap: () {
                  Get.closeAllSnackbars();
                  Navigator.of(Get.overlayContext!).pop(true);
                },
              ),

            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    ));
  }

  static Future<void> loadinDialog() async {
    return Get.dialog(
      PopScope(
        canPop: false,
        child: AppHelper.custumProgressIndecator(
          color: Colors.white,
          size: 50,
        ),
      ),
      barrierDismissible: false,
    );
  }

  static Future<void> displayScreenDialog(Widget child) async {
    return Get.dialog(DialogWidgetScreen(child: child));
  }
  
}
