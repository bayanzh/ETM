import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../common/widgets/user_tile_widget.dart';
import '../../../core/constant/app_colors.dart';
import '../controllers/student_courses_controller.dart';
import '../models/student_course_model.dart';
import '../widgets/student_course_widget.dart';


class StudentCoursesScreen extends GetView<StudentCoursesController> {
  const StudentCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return RefreshIndicator(
      onRefresh: () async {
        controller.getStudentCourses();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: isDarkMode? null : AppColors.scaffold,
        
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: UserTileWidget(
                  name: controller.currentUser.value?.displayName ?? "",
                  photo: controller.currentUser.value?.photoURL,
                  borderColor: const Color(0xFFBCC5DB),
                  textColor: isDarkMode? null : AppColors.textBlueBlack,
                ),
              ),

              // -- title widget
              Obx(() => Skeletonizer(
                enabled: controller.isLoading.value,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Courses Registered'.tr,
                    style: TextStyle(
                      color: isDarkMode? null : AppColors.textBlueBlack,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              )),

              // -- courses widget
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoading.value){
                      // -- show progress indecator when loading fetch data
                      return Skeletonizer(
                        enabled: controller.isLoading.value,
                        containersColor: isDarkMode? null : const Color(0xC5F9F8F8),
                        child: ListView.builder(
                          itemCount: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemBuilder: (context, index) => StudentCourseWidget(
                            studentCourse: StudentCourseModel.faker().first,
                            margin: const EdgeInsets.only(bottom: 15),
                          ),
                        ),
                      );
                    } else if (controller.studentCourses.isEmpty) {
                      // -- show message if no items found
                      return Center(
                        child: ListView(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Center(child: Text("You have not registered for any course yet.".tr)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      physics: const AlwaysScrollableScrollPhysics(),
                      primary: false,
                      itemCount: controller.studentCourses.length,
                      itemBuilder: (BuildContext context, index) {
                        return StudentCourseWidget(
                          studentCourse: controller.studentCourses[index],
                          margin: const EdgeInsets.only(bottom: 15),
                          onTap: () => controller.onCourseTap(index),
                        );
                      },
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
}