import 'package:e_training_mate/common/header/user_tile_header.dart';
import 'package:e_training_mate/core/models/quiz_question_model.dart';
import 'package:e_training_mate/features/student_courses/controllers/student_course_controller.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_dark_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../widgets/question_widget.dart';

class LessonQuestionScreen extends StatelessWidget {
  const LessonQuestionScreen({
    super.key,
    required this.lessonId,
    required this.questionTitle,
    required this.question,
    this.uploadResults = true,
  });

  final String lessonId;
  final String questionTitle;
  final QuizQuestionModel question;
  final bool uploadResults;

  

  void onBack() async {
    final confirmCancel = await DialogUtil.showConfirmDialog(message: 'Are you sure you want to stop the quiz?');
    if (confirmCancel == true) {
      Get.back(closeOverlays: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Logger.log('Insidel Lesson Question Screen');
    
    final studentCourseController = Get.find<StudentCourseController>();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    
    return LoaderOverlay(
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Logger.log('back From  Lesson Question Screen');

          onBack();
        },
        child: Scaffold(
          backgroundColor: isDarkMode? null : AppColors.scaffold,
          appBar: UserTileHeader(
            name: studentCourseController.currentUser?.displayName ?? "",
            photo: studentCourseController.currentUser?.photoURL,
            textColor: isDarkMode? null : AppColors.textBlueBlack,
            borderColor: const Color(0xFFBCC5DB),
            showBackArrow: false,
            onBackTap: onBack,
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 20),
                
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
                child: QuestionWidget(
                  questionTitle: questionTitle,
                  question: question,
                  markCorrectAnswerWhenWrong: false,
                  onConfirm: (isCorrect) async {
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (uploadResults) {
                      await Get.showOverlay(
                        opacity: 0.3,
                        asyncFunction: () async {
                          if (isCorrect) {
                            await studentCourseController.updateLessonViewingRate(
                                lessonId,
                                correctAnswer: true);
                          } else {
                            await studentCourseController.updateLessonViewingRate(
                              lessonId,
                              wrongAnswer: true,
                              viewingRate: 0.0,
                            );
                          }
                        },
                        loadingWidget: AppHelper.custumProgressIndecator(size: 50),
                      );
                    }

                    if (!isCorrect) {
                      await DialogUtil.showResultDialog(
                        title: 'Wrong answer'.tr,
                        message: 'You must re-study the lesson and then try to answer the question correctly so that you can move on to the next lesson.'.tr,
                      );
                    }
                    Get.back();
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