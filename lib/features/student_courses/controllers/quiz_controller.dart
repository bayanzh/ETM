import 'package:e_training_mate/core/models/quiz_question_answer_model.dart';
import 'package:e_training_mate/features/student_courses/controllers/student_course_controller.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/models/quiz_question_model.dart';
import '../../../core/utils/helpers/app_helper.dart';

class QuizController extends GetxController {
  final RxBool isLoading = false.obs;

  late Rx<User?> currentUser;

  final studentCourseController = Get.find<StudentCourseController>();



  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    refreshPage();
  }


  Future<void> refreshPage() async {
   
  }

  List<QuizQuestionModel> getUnAnsweredQuestion({
    required String quizDocId,
    required List<QuizQuestionModel> allQuestions,
  }) {
    // -- get the current quiz
    final currentQuiz = studentCourseController.studentCourse.quizResults
        .firstWhereOrNull((element) => element.quizId == quizDocId);

    // -- extract the numbers of answered questions
    final answeredQuestionsNumbers = currentQuiz?.questionsAnswer.map((e) => e.questionNumber).toList();
    
    // -- extract unanswered questions and return it
    final unAnsweredQuestions = allQuestions
        .where((element) => !(answeredQuestionsNumbers?.contains(element.questionNumber) ?? false))
        .toList();
    return unAnsweredQuestions;
  }

  Future<void> submitQuestionAnswer({
    required String quizId,
    required double quizFullGrade,
    required QuizQuestionAnswerModel questionAnswer,
  }) async {
    try {
      await studentCourseController.studentCourse.submitQuestionAnswer(
        quizId: quizId,
        quizFullGrade: quizFullGrade,
        questionAnswer: questionAnswer,
      );
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }
}