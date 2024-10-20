import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:e_training_mate/features/student_courses/screen/student_course_screen.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/features/home/widgets/activity_pichart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';


import '../../../common/header/app_header_with_profile.dart';
import '../../../common/widgets/course_widget.dart';
import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/titled_content_list.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  HomeController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : Colors.grey[350],
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    // controller.getAvailableCourses();
    return RefreshIndicator(
      onRefresh: () async { controller.getRecentlyViewedCourses(); },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                AppHeaderWithProfile(
                  name: controller.currentUser.value?.displayName ?? "",
                  photo: controller.currentUser.value?.photoURL,
                  height: 185,
                ),
                
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 20),

                      // -- Recently watched courses Widget
                      Obx(() => TitledContentList(
                        title: 'Recently watched courses',
                        showMore: false,
                        direction: Axis.horizontal,
                        titleStyle: TextStyle(
                          color: isDarkMode? null : AppColors.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                        useScrollWidget: true,
                        // contentBackColor: Colors.red,
                        listHeight: 125,
                        isLoading: controller.isLoading.value,
                        shimmerWidget: Skeleton.leaf(child: CourseWidget(course: CourseModel.faker().first, margin: AppHelper.startEndPadding(end: 12))),
                        children: List.generate(
                          controller.recentlyViewedCourses.length,
                          (index) => CourseWidget(
                            onTap: () => Get.to(() => StudentCourseScreen(studentCourse: controller.recentlyViewedCourses[index])),
                            course: controller.recentlyViewedCourses[index].course,
                            margin: AppHelper.startEndPadding(end: 12),
                            maxWidth: 300,
                          ),
                        ),
                      )),
                      const SizedBox(height: 30),

                      // ActivityPiechartWidget(),
                      Obx(() => Skeletonizer(
                          enabled: controller.isLoading.value,
                          containersColor: isDarkMode? const Color(0xff3a3a3a) : const Color(0xffebebf4),
                          child: !controller.isLoading.value && controller.recentlyViewedCourses.isEmpty
                            ? const SizedBox.shrink()
                            : ActivityPiechartWidget(
                                courses: controller.isLoading.value? StudentCourseModel.faker(length: 2) : controller.recentlyViewedCourses,
                              ),
                        ),
                      ),
                  
                      // const SizedBox(height: 50),
                      // Container(
                      //   alignment: Alignment.center,
                      //   child: const Text(
                      //     "HOME SCREEN",
                      //     style: TextStyle(
                      //       fontSize: 36,
                      //       fontWeight: FontWeight.w900,
                      //       height: 1.1,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ],
            ),

            // -- computer image
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              right: PrefHelper.getLangCode() == 'en'? 0 : null,
              left: PrefHelper.getLangCode() == 'ar'? 0 : null,
              child: Transform.flip(
                flipX: PrefHelper.getLangCode() == 'ar',
                child: CustomImageView(
                  imagePath: ImageConstant.computerHomeImage,
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
        
        // floatingActionButton: FloatingActionButton(onPressed: () async {
        //   await FakeData.fillFakeCoursesDataToFirebase();
        //   Logger.log("Success Add Faker Courses Data");
        // }),
      ),
    );
  }
}
