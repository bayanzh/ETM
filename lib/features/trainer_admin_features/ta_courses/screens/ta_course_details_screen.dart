import 'package:e_training_mate/common/enums/lesson_type_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/common/widgets/send_notification_widget.dart';
import 'package:e_training_mate/core/models/course_applicant_model.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/controllers/ta_course_details_controller.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/widgets/ta_lesson_widget.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/widgets/ta_student_applicant_widget.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../../../common/widgets/course_widget.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/utils/helpers/app_helper.dart';

class TaCourseDetailsScreen extends StatefulWidget {
  const TaCourseDetailsScreen({super.key, required this.course});

  final CourseModel course;

  @override
  State<TaCourseDetailsScreen> createState() => _TaCourseDetailsScreenState();
}

class _TaCourseDetailsScreenState extends State<TaCourseDetailsScreen> {
  final controller = Get.find<TaCourseDetailsController>();

  @override
  void initState() {
    super.initState();
    controller.courseId = widget.course.cDocId;
    controller.courseName = widget.course.name;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.refreshPage();
    });
  }

  RxBool isDisplayLearnersActive = false.obs;

  late bool isDarkMode;
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (controller.uploadingLessonId.value.isNotEmpty) {
          final confirmResult = await DialogUtil.showConfirmDialog(
              message:'There is a video is being uploaded to the database, if you exit the page the video might be unloaded.\nAre you sure you want to exit?');
          if (confirmResult != true) {
            return;
          }
        }
        Get.back(closeOverlays: true);
      },
      child: RefreshIndicator(
        onRefresh: () async { controller.refreshPage(); },
        child: Scaffold(
          backgroundColor: isDarkMode? null : AppColors.scaffold,
          appBar: AppBar(
            title: Text('Course Details'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            forceMaterialTransparency: true,
          ),
          body: CustomScrollView(
            slivers: [
              // -- all course data widget
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15, top: 10),
                  child: CourseWidget(
                    course: widget.course,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    showAllData: true,
                    showBackgroundColor: F,
                  ),
                ),
              ),
        
              // -- delete , send buttons widgets
              SliverToBoxAdapter(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 15,
                  children: [
                    CustomOutlinedButton(
                      margin: AppHelper.startEndPadding(start: 14),
                      text: 'Delete',
                      buttonTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                      height: 20,
                      onPressed: controller.deleteCourse,
                      buttonStyle: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      leftIcon: Padding(
                        padding: AppHelper.startEndPadding(end: 8.0),
                        child: const Icon(Icons.delete, size: 21),
                      ),
                    ),
                    CustomOutlinedButton(
                      text: 'Send',
                      onPressed: () async {
                        Get.dialog(
                          SendNotificationWidget(
                            onSend: controller.sendNotificationToCourseLearners,
                          ),
                          useSafeArea: false
                        );
                      },
                      buttonTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                      height: 20,
                      buttonStyle: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      leftIcon: Padding(
                        padding: AppHelper.startEndPadding(end: 8.0),
                        child: const Icon(Icons.notification_add, size: 21),
                      ),
                    ),
                  ],
                ),
              ),
        
              // -- lessons, students appbar widget
              SliverAppBar(
                pinned: true,
                expandedHeight: 73,
                collapsedHeight: 73,
                forceMaterialTransparency: true,
                automaticallyImplyLeading: false,
                flexibleSpace: Container(
                  margin: const EdgeInsets.only(
                      top: 20, right: 10, left: 10, bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    color: AppColors.scaffold,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0XFF23408F).withOpacity(0.20),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAppbarChoice(
                        text: 'Lessons',
                        isActive: !isDisplayLearnersActive.value,
                        onTap: () {
                          isDisplayLearnersActive.value = false;
                        }
                      ),
                      _buildAppbarChoice(
                        text: 'Learners',
                        isActive: isDisplayLearnersActive.value,
                        onTap: () {
                          isDisplayLearnersActive.value = true;
                          if (controller.courseApplicants.isEmpty) {
                            controller.listenToApplicants();
                          }
                        }
                      ),
                    ],
                  )),
                ),
              ),

              // -- lessons , students body
              SliverToBoxAdapter(
                child: Obx(() => AnimatedCrossFade(
                      firstChild: _buildLessonsWidget(),
                      secondChild: _buildLearnersWidget(),
                      crossFadeState: isDisplayLearnersActive.value
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    )),
              ), 
            ],
          ),
          floatingActionButton: controller.userType == UserTypeEnum.trainer? FloatingActionButton(
            onPressed: () async {
             
              if (controller.uploadingLessonId.value.isNotEmpty){
                AppHelper.showToastSnackBar(message: 'There is another video being uploaded.');
                return;
              }

              controller.goToAddLessonPage();
             
            },
            backgroundColor: AppColors.primary2,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 31, color: Colors.white),
          ) : null,
        ),
      ),
    );
  }


  Widget _buildLessonsWidget () {
    if (controller.lessonsLoading.value) {
      return AppHelper.custumProgressIndecator();
    }
    if (controller.courseLessons.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Text('No data found'.tr),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.courseLessons.length,
      itemBuilder: (context, index) {
        final lesson = controller.courseLessons[index];
        return TaLessonWidget(
          lesson: lesson,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          onDelete: () => controller.deleteLesson(lesson.docId ?? ''),
          bottom: Obx(
            () {

              if (lesson.docId == controller.uploadingLessonId.value) {
                return _buildUploadinLessonVideo();
              }

              if (lesson.docId == controller.failUploadingLessonId.value) {
                return _buildFailUploadVideoWidget(isDarkMode: isDarkMode);
              }

              if (lesson.type == LessonTypeEnum.lesson && lesson.videoUrl == null){
                return _buildNotFoundVideoOnLessonWidget(lessonId: lesson.docId ?? '', isDarkMode: isDarkMode);
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
  
  Widget _buildLearnersWidget () {
    if (controller.applicantsLoading.value) {
      return AppHelper.custumProgressIndecator();
    }
    if (controller.courseApplicants.isEmpty) {
      return Container(
        padding: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Text('No data found'.tr),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.courseApplicants.length,
      itemBuilder: (context, index) {
        final applicant = controller.courseApplicants[index];
        
        if (index == 0) {
          return _buildTitleWithUserCard("Requests", applicant);
        } else if (index == controller.getWaitingApplicantsCount(controller.courseApplicants)) {
          return Padding(
            padding: const EdgeInsets.only(top: 15),
            child: _buildTitleWithUserCard('Accepted', applicant),
          );
        } else {
          return TaStudnetApplicantWidget(
            studentName: applicant.student?.name ?? 'Unknown',
            status: applicant.status,
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
            onAccept: () => controller.acceptLearnerRequest(applicant),
          );
        }
      },
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
            style: Theme.of(Get.context!).textTheme.titleMedium
              ?.copyWith(
                  fontSize: 17,
                  color: isActive ? AppColors.primary : const Color(0xFF757575),
                ) ?? const TextStyle() ,
            child: Text(text.tr),
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
            height: isActive? 4 : 0,
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadinLessonVideo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text('Waiting for the lesson video to be uploaded:'.tr),
        const SizedBox(height: 5),
        Row(
          children: [
            Flexible(child: LinearProgressIndicator(
              value: controller.uploadProgressPercentage.value,
              backgroundColor: Colors.white,
              minHeight: 7,
            )),
            const SizedBox(width: 10),
            Text('${(controller.uploadProgressPercentage.value * 100).toStringAsFixed(0)}%'),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "Please do not close this page and wait until the video upload is complete.".tr),
                    const TextSpan(text: '\n\n'),
                    TextSpan(text: "Important: If you close this page or upload another lesson, the current video upload will be cancelled.".tr,
                        style: const TextStyle(color: Colors.red))
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            AppHelper.custumProgressIndecator(size: 50),
          ],
        ),
      ],
    );
  }

  Widget _buildNotFoundVideoOnLessonWidget ({required String lessonId, required bool isDarkMode}) {
    return Row(
      children: [
        Expanded(
          child: Text('* Course video is not available'.tr,
              style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(width: 8),

        CustomOutlinedButton(
          onPressed: () => controller.uploadLessonVideo(lessonId),
          text: 'Upload now',
          buttonTextStyle: TextStyle(color: isDarkMode? Colors.white : Colors.black),
        ),
      ],
    );
  }

  Widget _buildFailUploadVideoWidget({required bool isDarkMode}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        
        Text('* Failed to upload lesson video'.tr,
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 8),

        Row(
          children: [
            CustomOutlinedButton(
              onPressed: () => controller.uploadLessonVideo(controller.failUploadingLessonId.value),
              text: 'Upload now',
              buttonTextStyle: TextStyle(color:  isDarkMode? Colors.white : Colors.black),
            ),
            const SizedBox(width: 8),
            CustomOutlinedButton(
              onPressed: controller.cancelFailUploadLesson,
              text: 'Cancel',
              buttonTextStyle: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget _buildTitleWithUserCard(String title, CourseApplicantModel applicant){
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

        TaStudnetApplicantWidget(
          studentName: applicant.student?.name ?? '',
          // status: user.accountStatus,
          status: applicant.status,
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          onAccept: () => controller.acceptLearnerRequest(applicant)
        ),
      ], 
    );
  }
}
