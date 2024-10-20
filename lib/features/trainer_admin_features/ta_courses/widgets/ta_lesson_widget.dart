import 'package:e_training_mate/common/enums/lesson_type_enum.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/services/network_info.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/common/screens/video_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/quiz_question_model.dart';
import '../../../student_courses/screen/lesson_question_screen.dart';

class TaLessonWidget extends StatelessWidget {
  const TaLessonWidget({
    super.key,
    required this.lesson,
    this.width,
    this.margin,
    this.isQuizFinished,
    this.onDelete,
    this.bottom,
  });

  final LessonModel lesson;
  final double? width;
  final EdgeInsets? margin;
  final bool? isQuizFinished;
  final void Function()? onDelete;
  
  final Widget? bottom;

  void goToLessonQuestionScreen() {
    Get.to(
      LessonQuestionScreen(
        lessonId: lesson.docId ?? '',
        questionTitle: '${lesson.title} ${'Question'.tr}',
        uploadResults: false,
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
    try {
      // -- check the internet
      DialogUtil.loadinDialog();
      final isInterentConnected = await NetworkInfo().isConnected;
      Get.back();
      Logger.log('::: Open Lesson Video: ${lesson.videoUrl}');

      if (lesson.videoUrl != null && isInterentConnected) {
        // -- show video player screen and then recieve the viewing rate after close it
        final viewingRate = await Get.to(() => VideoPlayerScreen(videoUrl: lesson.videoUrl!));

        if (viewingRate == 1 && lesson.question != null && lesson.answers != null) {
          goToLessonQuestionScreen();
        }
      } else {
        AppHelper.showToastSnackBar(
            message: "The video is not available or You have not internet",
            isError: true);
      }
    } catch (e) {
      Logger.logError('Error While Open Video: $e');
    }
  }

  Future onQuizTap(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {},
        child: ListTile(
          onTap: () {
            if (lesson.type == LessonTypeEnum.lesson) {
              onLessonTap(context);
            } else if (lesson.type == LessonTypeEnum.quiz) {
              onQuizTap(context);
            }
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          minVerticalPadding: 0,
          minTileHeight: 0,

          // -- lesson title
          title: Container(
            padding: EdgeInsets.symmetric(
              vertical: lesson.type == LessonTypeEnum.quiz && isQuizFinished != true ? 5 : 3,
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

          subtitle: bottom,

          trailing: SizedBox(
            width: 22,
            height: 30,
            child: IconButton(
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              icon: Icon(Icons.delete, size: 21, color: Colors.grey[600]),
            ),
          ),
        ),
        
      ),
    );
  }
}
