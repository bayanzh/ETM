import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constant/app_dark_colors.dart';
import '../../../core/models/lesson_model.dart';
import '../controllers/student_course_controller.dart';

class QuizResultScreen extends StatelessWidget {
  QuizResultScreen({
    super.key,
    required this.quizDocId,
  });

  final String quizDocId;

  StudentCourseController get studentCourseController => Get.find();

  RxBool isLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    
    // -- get the current quiz result from all Quizzes results
    final currentQuizResult = studentCourseController.studentCourse.quizResults
        .firstWhereOrNull((element) => element.quizId == quizDocId);
    
    // -- get the quiz data
    LessonModel? quizLesson = studentCourseController
        .studentCourse.course.lessons
        ?.firstWhereOrNull((element) => element.docId == currentQuizResult?.quizId);

    RxInt correctAnswerCount = 0.obs;
    RxInt wrongAnswerCount = 0.obs;
    RxDouble grade = 0.0.obs;
    currentQuizResult?.questionsAnswer.forEach((element) {
      if (element.isAnswerCorrect) {
        correctAnswerCount.value += 1;
        grade.value += element.questionDegree;
      } else {
        wrongAnswerCount.value += 1;
      }
    });


    final textTheme = Theme.of(context).textTheme;
    final dueDate = currentQuizResult?.questionsAnswer
        .reduce((a, b) => a.answeredAt.isAfter(b.answeredAt) ? a : b)
        .answeredAt ?? DateTime.now();

    return Scaffold(
      backgroundColor: isDarkMode? null : AppColors.scaffold,
      appBar: AppBar(
        title: Text(quizLesson?.title ?? 'Quiz result'.tr, 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        forceMaterialTransparency: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        children: [
          const SizedBox(height: 20),

          Text("${'QUIZ'.tr}  .  ${quizLesson?.quizQuestions?.length} ${'QUESTIONS'.tr}", style: textTheme.titleMedium),
          
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Text(quizLesson?.title ?? 'Your Quiz', style: textTheme.titleLarge),
          ),
          
          _buildIconTitleSubTitleWidget(
            context,
            iconData: Icons.check_circle,
            title: 'Submit your quiz',
            subTitle: '${'DUE'.tr} ${DateFormat.yMMMEd().format(dueDate)}',
          ),
          const Divider(height: 40),

          _buildIconTitleSubTitleWidget(
            context,
            iconData: Icons.check_circle,
            title: correctAnswerCount.value.toString(),
            subTitle: 'Correct answers',
            subTitleColor: Colors.green,
          ),
          const SizedBox(height: 20),

          _buildIconTitleSubTitleWidget(
            context,
            iconData: Icons.cancel,
            title: wrongAnswerCount.value.toString(),
            subTitle: 'Wrong answers',
            iconColor: Colors.red,
            subTitleColor: Colors.red,
          ),
          const Divider(height: 40),
          const SizedBox(height: 10),

           Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Grade:'.tr,
                style: textTheme.titleMedium
                    ?.copyWith(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),

              Flexible(
                child: Obx(
                  () => Text(
                    '${grade.value}/${quizLesson?.quizFullGrade}',
                    style: textTheme.displaySmall?.copyWith(fontSize: 30, color: Colors.green)
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final isViewingRateForQuizUploaded = studentCourseController.studentCourse.lessonsViewingRate.any((element) => element.lessonId == quizDocId);
              if (!isViewingRateForQuizUploaded) {
                isLoading.value = true;
                await studentCourseController.updateLessonViewingRate(quizDocId, viewingRate: 1);
                isLoading.value = false;
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: isDarkMode? Colors.grey[800] : null),
            child: Obx(
              () => isLoading.value
                  ? AppHelper.custumProgressIndecator()
                  : Text('Ok'.tr,
                      style: textTheme.titleMedium?.copyWith(fontSize: 17)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTitleSubTitleWidget(BuildContext context, {
    required IconData iconData,
    required String title,
    required String subTitle,
    Color iconColor = Colors.green,
    Color? subTitleColor,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(iconData, color: iconColor),
        ),
        const SizedBox(width: 12),

        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.tr,
                style: textTheme.titleMedium?.copyWith(fontSize: 17),
              ),
              Text(subTitle.tr, style: TextStyle(color: subTitleColor)),
            ],
          ),
        )
      ],
    );
  }
}
