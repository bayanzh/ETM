import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/custom_image_view.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../core/constant/app_dark_colors.dart';
import '../../../../core/constant/image_constant.dart';

class TaUserWidget extends StatelessWidget {
  TaUserWidget({
    super.key,
    required this.studentName,
    required this.status,
    this.showStatusText = true,
    this.width,
    this.margin,
    this.photo,
    this.onTap,
    this.onAccept,
    this.onSuspend,
    this.onUnsuspend,
  });

  final String studentName;
  final UserAccountStatusEnum status;
  final bool showStatusText;
  final double? width;
  final EdgeInsets? margin;
  final String? photo;
  final void Function()? onTap;
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onSuspend;
  final Future<void> Function()? onUnsuspend;

  RxBool loadingChangeStatus = false.obs;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode? Colors.white : Colors.black),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        onTap: onTap ?? () {},
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            studentName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1,
            ),
          ),
        ),
        subtitle: showStatusText ? Text(
          "${'Status'.tr}: ${status.name.tr}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: status == UserAccountStatusEnum.accepted
                ? Colors.green
                : status == UserAccountStatusEnum.suspend
                    ? Colors.red
                    : isDarkMode? AppColors.primaryLight : AppColors.primary2,
          
          ),
        ) : null,
        leading: CircleAvatar(
          radius: 22,
          child: CustomImageView(
            imagePath: photo ?? ImageConstant.personIcon,
            placeHolder: ImageConstant.personIcon,
            border: Border.all(
                width: 0.5, color: isDarkMode? Colors.white : Colors.black),
            radius: BorderRadius.circular(26),
            width: 104,
            height: 104,
            fit: photo != null ? BoxFit.cover : null,
            padding: photo != null ? null : const EdgeInsets.all(2),
            color: isDarkMode && photo == null? AppDarkColors.iconColor : null,
          ),
        ),
        trailing: _buildStatusButton(isDarkMode: isDarkMode),
      ),
    );
  }

  Widget _buildStatusButton({required bool isDarkMode}) {
    String buttonText;
    Future<void> Function()? buttonFunction;

    if (status == UserAccountStatusEnum.accepted) {
      buttonText = 'Suspend';
      buttonFunction = onSuspend;
    } else if (status == UserAccountStatusEnum.suspend) {
      buttonText = 'Unsuspend';
      buttonFunction = onUnsuspend;
    } else {
      buttonText = 'Accept';
      buttonFunction = onAccept;
    }

    return CustomOutlinedButton(
      onPressed: () async {
        loadingChangeStatus.value = true;
        Logger.log('hhhhhhhhhhhh');
        await buttonFunction?.call();
        loadingChangeStatus.value = false;
      },
      isLoading: loadingChangeStatus.value,
      loadingIndicatorSize: 15,
      text: buttonText,
      buttonTextStyle: TextStyle(color: isDarkMode? null : Colors.black),
    );
  }
}
