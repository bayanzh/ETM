import 'package:e_training_mate/common/enums/applicant_status_enum.dart';
import 'package:e_training_mate/common/widgets/app_primary_button.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_dark_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../common/widgets/course_widget.dart';
import '../../../common/widgets/lesson_widget.dart';
import '../controllers/course_controller.dart';

class PreviewCourseScreen extends StatefulWidget {
  const PreviewCourseScreen({super.key, required this.course});

  final CourseModel course;

  @override
  State<PreviewCourseScreen> createState() => _PreviewCourseScreenState();
}

class _PreviewCourseScreenState extends State<PreviewCourseScreen> {
  final controller = Get.find<CourseController>();

  @override
  void initState() {
    super.initState();
    controller.courseId = widget.course.cDocId;
    controller.course = widget.course;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.refreshPage();
    });
  }

  late bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return RefreshIndicator(
      onRefresh: () async {
        controller.refreshPage();
      },
      child: Scaffold(
        backgroundColor: isDarkMode? null : AppColors.scaffold,
        appBar: AppBar(
          title: Text('Course Preview'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          forceMaterialTransparency: true,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 10),
                child: CourseWidget(
                  course: widget.course,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  showAllData: true,
                ),
              ),
            ),
            SliverAppBar(
              pinned: true,
              expandedHeight: 56,
              collapsedHeight: 56,
              forceMaterialTransparency: true,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                margin: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
                padding: const EdgeInsets.symmetric(vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0XFF23408F).withOpacity(0.20),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Lessons'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppColors.primary),
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          width: 90,
                          height: 6,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Obx(
                () {
                  if (controller.lessonsLoading.value) {
                    return AppHelper.custumProgressIndecator();
                  }
                  if (controller.courseLessons.isEmpty){
                    return Container(
                      padding: const EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      child: Text('No data found'.tr),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) => LessonWidget(
                      lesson: controller.courseLessons[index],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                    ),
                    itemCount: controller.courseLessons.length,
                  );
                },
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.all(10),
                child: Obx(()=> _buidlApplicantButton()),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buidlApplicantButton() {
    final userApplicant = controller.currentUserApplicant.value;
    if (userApplicant == null || userApplicant.status == ApplicantStatusEnum.accepted) {
      return AppPrimaryButton(
        text: userApplicant == null? 'Applicant' : 'Go to watch the course',
        onTap: userApplicant == null
            ? controller.sendApplicantRequestToCourse
            : controller.goToWatchCourse,
        isLoading: controller.applicantsLoading.value,
        width: double.maxFinite,
      );
    } else {
      return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isDarkMode ? null : AppColors.scaffold,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0XFF23408F).withOpacity(0.20),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userApplicant.status == ApplicantStatusEnum.rejected) ...[
              const Icon(Icons.sentiment_dissatisfied),
              const SizedBox(height: 5),
              Text('Your request has been rejected.'.tr),
            ],

            if (userApplicant.status == ApplicantStatusEnum.waiting) ...[
              Text('Your request is pending approval.'.tr),
              TextButton(onPressed: controller.cancelCourseApplicant, child: Text('Cancel Request'.tr))
            ],
          ],
        ),
      );
      
    }
  }
}