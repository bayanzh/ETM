import 'package:e_training_mate/common/enums/lesson_type_enum.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/common/widgets/lesson_widget.dart';
import 'package:e_training_mate/features/student_courses/screen/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_dark_colors.dart';
import '../../../core/models/quiz_question_model.dart';
import '../controllers/student_course_controller.dart';
import '../widgets/student_course_widget.dart';

class StudentCourseScreen extends StatefulWidget {
  const StudentCourseScreen({super.key, required this.studentCourse});

  final StudentCourseModel studentCourse;

  @override
  State<StudentCourseScreen> createState() => _StudentCourseScreenState();
}

class _StudentCourseScreenState extends State<StudentCourseScreen> {
  final controller = Get.find<StudentCourseController>();

  @override
  void initState() {
    super.initState();
    controller.listenToStudentCourse(widget.studentCourse);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Get.back(closeOverlays: true, result: controller.studentCourse);
      },
      child: LoaderOverlay(
        child: Scaffold(
          backgroundColor: isDarkMode ? null : AppColors.scaffold,
          
          appBar: AppBar(
            title: Text(widget.studentCourse.course.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            forceMaterialTransparency: true,
          ),
          body: RefreshIndicator(
            onRefresh: controller.refreshScreen,
            child: Column(
              children: [
               
                GetBuilder<StudentCourseController>(
                  builder: (_) {
                    return StudentCourseWidget(
                      studentCourse: controller.studentCourse,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    );
                  }
                ),
                const SizedBox(height: 10),
                
                Expanded(
                  child: Obx(
                    () {
                      if (controller.isLoading.value){
                        return AppHelper.custumProgressIndecator();
                      } else if (controller.courseLessons.isEmpty) {
                        return Center(
                          child: ListView(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Center(child: Text("There are no lessons available".tr)),
                            ],
                          ),
                        );
                      }

                      return GetBuilder<StudentCourseController>(
                        builder: (context) => ListView.builder(
                          itemCount: controller.courseLessons.length,
                          itemBuilder: (context, index) {
                            final beforeLesson = controller.courseLessons[index >  0 ? index - 1 : 0];
                            final lesson = controller.courseLessons[index];
                            final lessonVR = controller.studentCourse.lessonsViewingRate
                              .firstWhereOrNull((element) => element.lessonId == lesson.docId);

                            final beforeLessonVR = controller.studentCourse.lessonsViewingRate
                              .firstWhereOrNull((element) => element.lessonId == beforeLesson.docId);

                            final lessonQuizResult = controller.studentCourse.quizResults
                              .firstWhereOrNull((element) => element.quizId == lesson.docId);

                            bool isLessonFinish = lesson.type == LessonTypeEnum.quiz && lesson.quizQuestions?.length == lessonQuizResult?.questionsAnswer.length;
                            isLessonFinish = isLessonFinish || (lessonVR?.viewingRate == 1 && lessonVR?.correctAnswerAt != null);

                            // -- condition for can open the first lesson
                            bool canOpen = index == 0;
                            // -- condition for can open the next lesson if the previous lesson is finish watching and finish its quiz
                            canOpen = canOpen || (beforeLessonVR != null && beforeLessonVR.correctAnswerAt != null);
                            //  -- condition for can open the next lesson if the previous lesson is finish watching but not have quiz
                            canOpen = canOpen || (beforeLesson.question == null && beforeLesson.answers == null && beforeLessonVR != null && beforeLessonVR.viewingRate ==1);
                            
                            return LessonWidget(
                              lesson: lesson,
                              lessonViewingRate: lessonVR?.viewingRate ?? 0.0,
                              lessonVRModel: lessonVR,
                              previewOnly: false,
                              canOpen: canOpen,
                              isLessonFinish: isLessonFinish,
                              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              updateCourseViewingRate: (lessonId, viewingRate) {
                                context.loaderOverlay.show();
                                controller.updateLessonViewingRate(lessonId, viewingRate: viewingRate)
                                  .then((value) {
                                    
                                    context.loaderOverlay.hide();
                                    controller.update();
                                  });
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
