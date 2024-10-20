import 'package:animated_emoji/emoji.dart';
import 'package:animated_emoji/emojis.g.dart';
import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/screens/ta_add_course_screen.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/screens/ta_course_details_screen.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/controllers/ta_main_controller.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/widgets/count_text_box_widget.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../common/header/app_header_with_profile.dart';
import '../../../../common/widgets/course_widget.dart';
import '../../../../common/widgets/titled_content_list.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/constant/app_dark_colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../controllers/ta_home_controller.dart';

class TaHomeScreen extends StatelessWidget {
  const TaHomeScreen({super.key});

  TaHomeController get controller => Get.find();
  TaMainController get mainController => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : Colors.grey[350],
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    
    final isTrainer = PrefHelper.getUserType() == UserTypeEnum.trainer;
    final screenWidth = MediaQuery.of(context).size.width;

    Logger.log('UserType:::: ${controller.userType.value}');
    Logger.log('UserAccountStatusEnum :::: ${mainController.currentUserInfo.value?.accountStatus}');

    return RefreshIndicator(
      onRefresh: () async { controller.refreshPage(); },
      child: SafeArea(
        child: Scaffold(
          body: ListView(
            children: [
              Obx(() => AppHeaderWithProfile(
                height: 185,
                name: mainController.currentUser.value?.displayName ?? "",
                photo: mainController.currentUser.value?.photoURL,
                accountStatus: mainController.currentUserInfo.value?.accountStatus,
                userType: controller.userType.value,
              )),
          
              Obx(
                () {
                  if (mainController.currentUserInfo.value?.accountStatus != UserAccountStatusEnum.accepted) {
                    return _buildStatusAccountWidget(mainController.currentUserInfo.value?.accountStatus);
                  }
                  
                  return Column(
                    children: [
                      Obx(() => Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          if (!isTrainer) ...[
                            CountTextBoxWidget(
                              count: controller.trainersCount.value ?? 0,
                              text: 'Trainers',
                              width: screenWidth * 0.40,
                            ),
                            CountTextBoxWidget(
                              count: controller.learnersCount.value ?? 0,
                              text: 'Learners',
                              width: screenWidth * 0.40,
                            ),
                          ],
                                
                          if (isTrainer)
                            CountTextBoxWidget(
                              count: controller.applicantsCount.value ?? 0,
                              text: 'Applicants',
                              width: screenWidth * 0.40,
                            ),
                                
                          CountTextBoxWidget(
                            count: controller.coursesCount.value ?? 0,
                            text: 'Courses',
                            width: screenWidth * 0.40,
                          ),
                        ],
                      )),
                  
                      const SizedBox(height: 20),
                            
                      // -- Most active courses for trainer or admin
                      Obx(() => TitledContentList(
                        title: isTrainer? 'The most requested courses' : 'Most active course',
                        showMore: false,
                        direction: isTrainer? Axis.horizontal : Axis.vertical,
                        useScrollWidget: true,
                        // contentBackColor: Colors.red,
                        listHeight: 125,
                        isLoading: controller.activeCoursesLoading.value,
                        children: List.generate(
                          controller.mostActiveCourses.length,
                          (index) => CourseWidget(
                            width: isTrainer? Get.width * 0.4 - 5 : double.maxFinite,
                            course: controller.mostActiveCourses[index],
                            margin: AppHelper.startEndPadding(end: 10),
                            onTap: () => Get.to(() => TaCourseDetailsScreen(
                                course: controller.mostActiveCourses[index])),
                          ),
                        ),
                      )),
                      const SizedBox(height: 15),
                  
                      // -- all trainer courses for trainer
                      if (isTrainer)
                        Obx(() => TitledContentList(
                          title: 'All your courses',
                          showMore: false,
                          direction: Axis.vertical,
                          useScrollWidget: false,
                          isLoading: controller.trainerCoursesLoading.value,
                          children: List.generate(
                            controller.trainerCourses.length,
                            (index) => CourseWidget(
                              width: double.maxFinite,
                              height: 115,
                              course: controller.trainerCourses[index],
                              margin: AppHelper.startEndPadding(bottom: 10),
                              onTap: () => Get.to(() => TaCourseDetailsScreen(
                                course: controller.trainerCourses[index])),
                            ),
                          ),
                        )),
                    ],
                  );
                }
              ),
          
              
            ],
          ),
          floatingActionButton: isTrainer? Obx(
            () => mainController.currentUserInfo.value?.accountStatus != UserAccountStatusEnum.accepted 
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () async {
                  await Get.to(() => const TaAddCourseScreen());
                  controller.refreshPage();
                },
                backgroundColor: AppColors.primary2,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, size: 31, color: Colors.white),
              )
          ) : null,
        ),
      ),
    );
  }

  Widget _buildStatusAccountWidget(UserAccountStatusEnum? status) {
    if (status == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedEmoji(
            status == UserAccountStatusEnum.waiting
                ? AnimatedEmojis.slightlyHappy
                : AnimatedEmojis.sad,
            size: 100,
          ),
          const SizedBox(height: 20),
          Text(
            status == UserAccountStatusEnum.waiting
                ? 'Your account is pending review and approval by the administration.'.tr
                : 'Your account has been temporarily suspended. Please contact support for further information.'.tr,
            textAlign: TextAlign.center,
            style: Theme.of(Get.context!).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}