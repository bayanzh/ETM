import 'package:e_training_mate/common/header/user_tile_header.dart';
import 'package:e_training_mate/core/models/quiz_question_answer_model.dart';
import 'package:e_training_mate/core/models/quiz_question_model.dart';
import 'package:e_training_mate/features/student_courses/controllers/quiz_controller.dart';
import 'package:e_training_mate/features/student_courses/screen/quiz_result_screen.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_outlined_button.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/constant/app_dark_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../widgets/question_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.quizDocId,
    required this.quizFullGrade,
    required this.questions,
  });

  final String quizDocId;
  final double quizFullGrade;
  final List<QuizQuestionModel> questions;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final quizController = Get.find<QuizController>();


  late final pageController = PageController();

  RxBool isLoading = false.obs;
  RxInt currentPage = 0.obs;
  RxBool isConfirmed = false.obs;
  RxDouble grade = 0.0.obs;

  void onBack() async {
    final confirmCancel = await DialogUtil.showConfirmDialog(message: 'Are you sure you want to stop the quiz?\nNote: When you return again, the quiz will be completed from the question you stopped at.');
    if (confirmCancel == true) {
      Get.back(
        closeOverlays: true,
        result: currentPage.value == widget.questions.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // -- reorder the questions by question number
    widget.questions.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));

    // -- extract the unansered questions from all quiz questions
    final unAnsweredQuestions = quizController.getUnAnsweredQuestion(
      quizDocId: widget.quizDocId,
      allQuestions: widget.questions,
    );

    final allQuestionLength = widget.questions.length;
    final answeredQuestionLength = widget.questions.length - unAnsweredQuestions.length;
    
    Logger.log(':::::: answeredQuestionLength: $unAnsweredQuestions');

    // -- set the current page to the answered questions count
    // To continue from the last question you stopped at
    currentPage.value = answeredQuestionLength;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        onBack();
      },
      child: RefreshIndicator(
        onRefresh: () async {
          quizController.refreshPage();
        },
        child: Scaffold(
          backgroundColor: isDarkMode? null : AppColors.scaffold,
          appBar: UserTileHeader(
            name: quizController.currentUser.value?.displayName ?? "",
            photo: quizController.currentUser.value?.photoURL,
            textColor: isDarkMode? null : AppColors.textBlueBlack,
            borderColor: const Color(0xFFBCC5DB),
            onBackTap: onBack,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.1),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => LinearProgressIndicator(
                        minHeight: 15,
                        borderRadius: BorderRadius.circular(15),
                        backgroundColor: Colors.white,
                        value: (currentPage.value + 1) / allQuestionLength,
                      )),
                  
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${currentPage.value + 1}/$allQuestionLength',
                              style: TextStyle(color: isDarkMode ? AppColors.primaryLight : AppColors.primary),
                            ),
                            
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
      
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
                  child: PageView.builder(
                    itemCount: unAnsweredQuestions.length,
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) {
                      currentPage.value = value;
                    },
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: QuestionWidget(
                          numberQuestion: currentPage.value + 1,
                          question: unAnsweredQuestions[index],
                          onConfirm: (isCorrect) async {
                            
                            isLoading.value = true;
                            await quizController.submitQuestionAnswer(
                              quizId: widget.quizDocId,
                              quizFullGrade: widget.quizFullGrade,
                              questionAnswer: QuizQuestionAnswerModel(
                                questionNumber: unAnsweredQuestions[index].questionNumber,
                                questionDegree: unAnsweredQuestions[index].questionDegree,
                                isAnswerCorrect: isCorrect,
                                answeredAt: DateTime.now(),
                              ),
                            );
                            isLoading.value = false;
                            isConfirmed.value = true;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
      
              // -- next button widget
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                alignment: AlignmentDirectional.topEnd,
                child: Obx(() => isLoading.value
                ? AppHelper.custumProgressIndecator()
                : CustomOutlinedButton(
                  text: 'Next'.tr,
                  onPressed: () {
                    if (!isConfirmed.value) {
                      AppHelper.showToastSnackBar(message: 'You must confirm your answer.');
                    } else if (currentPage.value < unAnsweredQuestions.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.bounceIn,
                      );
                      isConfirmed.value = false;
                    } else {
                     
                      Get.off(() => QuizResultScreen(quizDocId: widget.quizDocId));
                    }
                  },
                  buttonTextStyle: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: isConfirmed.value? (isDarkMode? AppColors.primaryLight : AppColors.primary) : Colors.grey),
                  buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
                  rightIcon: Padding(
                    padding: AppHelper.startEndPadding(start: 7),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: isConfirmed.value? (isDarkMode? AppColors.primaryLight : AppColors.primary) : Colors.grey,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}