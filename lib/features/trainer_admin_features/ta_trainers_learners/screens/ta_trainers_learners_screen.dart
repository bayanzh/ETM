import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/controllers/ta_main_controller.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_trainers_learners/controllers/ta_trainers_learners_controller.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_trainers_learners/widgets/ta_user_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/user_tile_widget.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dark_colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';

class TaTrainersLearnersScreen extends StatelessWidget {
  const TaTrainersLearnersScreen({super.key});

  TaTrainersLearnersController get controller => Get.find();
  TaMainController get mainController => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return RefreshIndicator(
      onRefresh: () async {
        controller.getAllUsers();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDarkMode? null : AppColors.scaffold,
          
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  child: UserTileWidget(
                    name: mainController.currentUser.value?.displayName ?? "",
                    photo: mainController.currentUser.value?.photoURL,
                    borderColor: const Color(0xFFBCC5DB),
                    textColor: isDarkMode? null : AppColors.textBlueBlack,
                  ),
                ),
              ),
        
              SliverAppBar(
                pinned: true,
                expandedHeight: 65,
                collapsedHeight: 65,
                forceMaterialTransparency: true,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  alignment: Alignment.bottomCenter,
                  margin: const EdgeInsets.only(
                      top: 10,  bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.scaffold,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0XFF23408F).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: -1,
                        offset: const Offset(0, 8)
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildAppbarChoice(
                          text: 'Trainers',
                          isActive: !controller.isDisplayLearnersActive.value,
                          onTap: () => controller.isDisplayLearnersActive.value = false,
                        ),
                        _buildAppbarChoice(
                          text: 'Learners',
                          isActive: controller.isDisplayLearnersActive.value,
                          onTap: () => controller.isDisplayLearnersActive.value = true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
              SliverToBoxAdapter(
                child: Obx(
                  () {
                    if (controller.isLoading.value) {
                      return AppHelper.custumProgressIndecator();
                    }
                    if (controller.allUsers.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.only(top: 20),
                        alignment: Alignment.center,
                        child: Text('No data found'.tr),
                      );
                    }
                    return AnimatedCrossFade(
                      firstChild: _buildTrainersWidget(isDarkMode),
                      secondChild: _buildLearnersWidget(isDarkMode),
                      crossFadeState: controller.isDisplayLearnersActive.value
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    );
                  },
                ),
              ),
            ],
          ),
         
        ),
      ),
    );
  }

  Widget _buildAppbarChoice({
    required String text,
    required bool isActive,
    double? lineWidth = 70,
    void Function()? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFF757575),
                    ) ??
                const TextStyle(),
            child: Text(
              text.tr,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: AppColors.primary,
           
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            width: lineWidth,
            height: isActive ? 4 : 0,
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersWidget (bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.trainerUsers.length,
      itemBuilder: (context, index) {
        int waitingAccountCount = controller.getWaitingAccountCount(controller.trainerUsers);
        int suspendAccountCount = controller.getSuspendAccountCount(controller.trainerUsers);

        if (index == 0 && waitingAccountCount != 0) {
          return _buildTitleWithUserCard("Requests", controller.trainerUsers[index], isDarkMode);
        } else if (index == waitingAccountCount && suspendAccountCount != 0) {
          // build the first waiting account widget with the title "Requests"
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildTitleWithUserCard('Suspended', controller.trainerUsers[index], isDarkMode),
          );
        } else if (index == (waitingAccountCount + suspendAccountCount)) {
          // build the first accepted account widget with the title "Accepted"
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildTitleWithUserCard('Accepted', controller.trainerUsers[index], isDarkMode),
          );
        } else {
          return TaUserWidget(
            studentName: controller.trainerUsers[index].name,
            photo: controller.trainerUsers[index].photoUrl,
            status: controller.trainerUsers[index].accountStatus,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            onAccept: () => controller.changeUserAccountStatus(
              user: controller.trainerUsers[index],
              status: UserAccountStatusEnum.accepted,
            ),
            onSuspend: () => controller.changeUserAccountStatus(
              user: controller.trainerUsers[index],
              status: UserAccountStatusEnum.suspend,
            ),
            onUnsuspend: () => controller.changeUserAccountStatus(
              user: controller.trainerUsers[index],
              status: UserAccountStatusEnum.accepted,
            ),
          );
        }
      },
    );
  }
  
  Widget _buildLearnersWidget (bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.learnerUsers.length,
      itemBuilder: (context, index) {
        int waitingAccountCount = controller.getWaitingAccountCount(controller.learnerUsers);
        int suspendAccountCount = controller.getSuspendAccountCount(controller.learnerUsers);

        if (index == 0 && waitingAccountCount != 0) {
          // build the first waiting account widget with the title "Requests"
          return _buildTitleWithUserCard("Requests", controller.learnerUsers[index], isDarkMode);
        } else if (index == waitingAccountCount && suspendAccountCount != 0) {
          // build the first waiting account widget with the title "Requests"
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildTitleWithUserCard('Suspended', controller.learnerUsers[index], isDarkMode),
          );
        } else if (index == (waitingAccountCount + suspendAccountCount)) {
          // build the first accepted account widget with the title "Accepted"
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildTitleWithUserCard('Accepted', controller.learnerUsers[index], isDarkMode),
          );
        } else {
          return TaUserWidget(
            studentName: controller.learnerUsers[index].name,
            status: controller.learnerUsers[index].accountStatus,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            onAccept: () => controller.changeUserAccountStatus(
              user: controller.learnerUsers[index],
              status: UserAccountStatusEnum.accepted,
            ),
            onSuspend: () => controller.changeUserAccountStatus(
              user: controller.learnerUsers[index],
              status: UserAccountStatusEnum.suspend,
            ),
            onUnsuspend: () => controller.changeUserAccountStatus(
              user: controller.learnerUsers[index],
              status: UserAccountStatusEnum.accepted,
            ),
          );
        }
      },
    );
  }

  Widget _buildTitleWithUserCard(String title, UserModel user, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(title.tr,
            style: TextStyle(
              color: isDarkMode? null : AppColors.textBlueBlack,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),

        TaUserWidget(
          studentName: user.name,
          status: user.accountStatus,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          onAccept: () => controller.changeUserAccountStatus(
              user: user,
              status: UserAccountStatusEnum.accepted,
            ),
            onSuspend: () => controller.changeUserAccountStatus(
              user: user,
              status: UserAccountStatusEnum.suspend,
            ),
            onUnsuspend: () => controller.changeUserAccountStatus(
              user: user,
              status: UserAccountStatusEnum.accepted,
            ),
        ),
      ], 
    );
  }
}
