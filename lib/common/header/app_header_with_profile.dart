import 'package:e_training_mate/common/header/app_header.dart';
import 'package:e_training_mate/common/widgets/user_tile_widget.dart';
import 'package:flutter/material.dart';

import '../enums/user_status_enum.dart';
import '../enums/user_type_enum.dart';

class AppHeaderWithProfile extends AppHeader {
  final String name;
  final String? photo;
  final UserAccountStatusEnum? accountStatus;
  final UserTypeEnum? userType;
  final bool showWelcome;
  
  AppHeaderWithProfile({
    super.key,
    super.color,
    super.curveOutside,
    super.height = 140,
    required this.name,
    this.photo,
    this.showWelcome = true,
    this.accountStatus,
    this.userType,
  }) : super(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                
                const SizedBox(height: 47),
                UserTileWidget(
                  photo: photo,
                  name: name,
                  showWelcome: showWelcome,
                  accountStatus: accountStatus,
                  userType: userType,
                ),
              ],
            ),
          ),
        );

  
  
  
}
