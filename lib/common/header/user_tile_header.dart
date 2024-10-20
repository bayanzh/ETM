import 'package:e_training_mate/common/widgets/user_tile_widget.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../enums/user_status_enum.dart';
import '../enums/user_type_enum.dart';

class UserTileHeader extends StatelessWidget implements PreferredSizeWidget {
  const UserTileHeader({
    super.key,
    this.photo,
    this.name,
    this.borderColor,
    this.textColor,
    this.height = 77,
    this.padding,
    this.showWelcome = false,
    this.accountStatus,
    this.userType,
    this.showBackArrow = true,
    this.onBackTap,
  });

  final String? photo;
  final String? name;
  final Color? borderColor;
  final Color? textColor;
  final double? height;
  final EdgeInsets? padding;
  final bool showWelcome;
  final UserAccountStatusEnum? accountStatus;
  final UserTypeEnum? userType;
  final bool showBackArrow;
  final void Function()? onBackTap;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 80);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.only(top: kToolbarHeight, right: 10, left: 10, bottom: 5),
      alignment: Alignment.bottomCenter,
      child: Row(
        children: [
          if (showBackArrow && (navigator?.canPop() ?? false))
            SizedBox(
              width: 35,
              child: IconButton(
                padding: AppHelper.startEndPadding(end: 10),
                onPressed: onBackTap ?? () => Get.back(closeOverlays: true),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          
          Flexible(
            child: UserTileWidget(
              name: name,
              photo: photo,
              textColor: textColor,
              borderColor: borderColor,
              showWelcome: showWelcome,
              accountStatus: accountStatus,
              userType: userType,
            ),
          ),
        ],
      )
    );
  }
}
