import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/app_dark_colors.dart';
import '../../core/constant/image_constant.dart';
import '../../core/constant/app_colors.dart';
import 'custom_image_view.dart';

class UserTileWidget extends StatelessWidget {
  const UserTileWidget({
    super.key,
    this.photo,
    this.name,
    this.borderColor,
    this.textColor,
    this.showWelcome = false,
    this.accountStatus,
    this.userType,
  });

  final String? photo;
  final String? name;
  final Color? borderColor;
  final Color? textColor;
  final bool showWelcome;
  final UserAccountStatusEnum? accountStatus;
  final UserTypeEnum? userType;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          minLeadingWidth: 0,
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 26,
            child: CustomImageView(
              imagePath: photo ?? ImageConstant.personIcon,
              placeHolder: ImageConstant.personIcon,
              border: Border.all(
                  width: 3,
                  color: borderColor ?? AppColors.bottomNavigationBar),
              radius: BorderRadius.circular(26),
              width: 104,
              height: 104,
              fit: photo != null ? BoxFit.cover : null,
              padding: photo != null ? null : const EdgeInsets.all(2),
              color: isDarkMode && photo == null? AppDarkColors.iconColor : null,
            ),
          ),
          title: Text(
            (showWelcome? '${"Welcome".tr} ' : '') + (name?.split(' ')[0] ?? ''),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Container(
            alignment: AlignmentDirectional.centerStart,
            child: _buildAccountStatusMark(),
          ),
        ),
      ],
    );
  }

  Widget? _buildAccountStatusMark() {
    String markText = '';
    if (accountStatus == UserAccountStatusEnum.waiting) {
      markText = 'Account awaiting approval'.tr;
    } else if (accountStatus == UserAccountStatusEnum.suspend) {
      markText = 'Account suspended'.tr;
    } else if (userType != null && userType != UserTypeEnum.learner) {
      markText = '${userType!.name} account'.tr;
    }

    if (markText.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.green,
        ),
        child: Text(markText,
            style: Theme.of(Get.context!).textTheme.bodySmall
              ?.copyWith(color: Colors.white)),
      );
    }
    return null;
  }
}
