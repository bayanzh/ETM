import 'package:e_training_mate/common/enums/lesson_type_enum.dart';
import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/models/quiz_question_model.dart';
import 'package:e_training_mate/features/student_courses/models/student_lesson_vr_model.dart';
import 'package:e_training_mate/features/student_courses/screen/lesson_question_screen.dart';
import 'package:e_training_mate/features/student_courses/screen/quiz_result_screen.dart';
import 'package:e_training_mate/features/student_courses/screen/quiz_screen.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/services/network_info.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/common/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';


class LessonWidget extends StatelessWidget {
  const LessonWidget({
    super.key,
    required this.lesson,
    this.lessonViewingRate = 0.0,
    this.lessonVRModel,
    this.canOpen = false,
    this.width,
    this.margin,
    this.previewOnly = true,
    this.isLessonFinish,
    this.updateCourseViewingRate,
  });

  final LessonModel lesson;
  final bool canOpen;
  final double lessonViewingRate;
  final StudentLessonVRModel? lessonVRModel;
  final double? width;
  final EdgeInsets? margin;
  final bool previewOnly;
  final bool? isLessonFinish;
  final void Function(String lessonId, double viewingRate)?
      updateCourseViewingRate;

  void goToLessonQuestionScreen() {
    Get.to(
      () => LessonQuestionScreen(
        lessonId: lesson.docId ?? '',
        questionTitle: '${lesson.title} ${'Question'.tr}',
        question: QuizQuestionModel(
          questionNumber: 1,
          question: lesson.question ?? '',
          answers: lesson.answers ?? [],
          correctAnswer: lesson.correctAnswer ?? '',
          questionDegree: 0,
        ),
      ),
    );
  }

  Future<void> onLessonTap(BuildContext context) async {
    // -- check the internet
    context.loaderOverlay.show();
    final isInterentConnected = await NetworkInfo().isConnected;
    context.loaderOverlay.hide();

    if (lesson.videoUrl != null && isInterentConnected) {
      if (lessonVRModel != null && lessonVRModel!.viewingRate == 1 && lessonVRModel!.correctAnswerAt == null) {
        // -- Go to lesson question
        goToLessonQuestionScreen();
      } else {
        // -- show video player screen and then recieve the viewing rate after close it
        final viewingRate = await Get.to(() => VideoPlayerScreen(videoUrl: lesson.videoUrl!));

        if (viewingRate != null && viewingRate > lessonViewingRate) {
          Logger.log("::::::::::::::::::::::::::: Update Viewing rate");
          updateCourseViewingRate?.call(lesson.docId ?? "", viewingRate);

          if (viewingRate == 1 && lesson.question != null && lesson.answers != null) {
            goToLessonQuestionScreen();
          }
        }
      }
    } else {
      AppHelper.showToastSnackBar(
          message: "The video is not available or You have not internet",
          isError: true);
    }
  }

  Future onQuizTap(BuildContext context) async {
    // -- check the internet
    context.loaderOverlay.show();
    final isInterentConnected = await NetworkInfo().isConnected;
    context.loaderOverlay.hide();

    if (isLessonFinish == true) {
      Get.to(() => QuizResultScreen(quizDocId: lesson.docId ?? ''));
      return;
    }

    if (lesson.quizQuestions != null && isInterentConnected) {
      // -- show quiz screen and then recieve boolean value that after close it
      // -- that indicate to finish the quiz or not
      // final isFinished =
       await Get.to(() => QuizScreen(
            quizDocId: lesson.docId ?? '',
            quizFullGrade: lesson.quizFullGrade ?? 0.0,
            questions: lesson.quizQuestions!,
          ));

      
    } else {
      AppHelper.showToastSnackBar(
          message: "The quiz is not available or You have not internet",
          isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000)),
            color: canOpen || previewOnly? null : Colors.grey.withOpacity(0.2), // لون رمادي خفيف
          ),
          child: ListTile(
            minTileHeight: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            minVerticalPadding: previewOnly? 7 : 2,
            onTap: () {
              if (!canOpen || previewOnly){
              } else if (lesson.type == LessonTypeEnum.lesson) {
                onLessonTap(context);
              } else if (lesson.type == LessonTypeEnum.quiz) {
                onQuizTap(context);
              }
            },
            title: Container(
              padding: EdgeInsets.symmetric(
                vertical: previewOnly ? 4 
                  : lesson.type == LessonTypeEnum.quiz && isLessonFinish != true ? 10 : 3,
              ),
              child: Text(
                lesson.title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ),
            subtitle: Visibility(
              visible: !previewOnly,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (lesson.type == LessonTypeEnum.quiz && isLessonFinish == true)
                      const Icon(Icons.check_circle, size: 22, color: Colors.green),

                    if (lesson.type == LessonTypeEnum.lesson) ...[
                      Row(
                        children: [
                          const Icon(Icons.slow_motion_video, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LinearProgressIndicator(
                              minHeight: 15,
                              borderRadius: BorderRadius.circular(15),
                              value: lessonViewingRate.clamp(0, 1),
                              backgroundColor: canOpen? Colors.grey[100] : Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            ),
                          ),
                        ],
                      ),

                      Wrap(
                        spacing: 10,
                        children: [
                          if (lessonVRModel?.viewingRate == 1)
                            CustomOutlinedButton(
                              text: 'lesson',
                              leftIcon: Padding(
                                padding: AppHelper.startEndPadding(end: 8.0),
                                child: const Icon(Icons.check_circle, size: 22, color: Colors.green),
                              ),
                              margin: const EdgeInsets.only(bottom: 4, top: 8),
                              buttonTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              buttonStyle: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              )
                            ),
                            
                          if (lessonVRModel?.correctAnswerAt != null)
                            CustomOutlinedButton(
                              text: 'quiz',
                              leftIcon: Padding(
                                padding: AppHelper.startEndPadding(end: 8.0),
                                child: const Icon(Icons.check_circle, size: 22, color: Colors.green),
                              ),
                              margin: const EdgeInsets.only(top: 8),
                              buttonTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                              buttonStyle: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                              )
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

        ),
      ],
    );


  }
}
