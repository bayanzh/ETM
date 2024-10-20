import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/models/quiz_question_model.dart';
import '../../../core/constant/app_colors.dart';

class QuestionWidget extends StatefulWidget {
  const QuestionWidget({
    super.key,
    this.numberQuestion,
    this.questionTitle,
    required this.question,
    this.margin,
    this.markCorrectAnswerWhenWrong = true,
    this.onConfirm,
  });

  final int? numberQuestion;
  final String? questionTitle;
  final QuizQuestionModel question;
  final EdgeInsets? margin;
  final bool markCorrectAnswerWhenWrong;
  final void Function(bool isCorrect)? onConfirm;

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget>
    with TickerProviderStateMixin  {
  int? selectedAnswer;
  bool isConfirmed = false;
  late int correctAnswer;
  final scrollController = ScrollController();

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    Logger.log('::::::::: Correct Answer: ${widget.question.correctAnswer}');
    Logger.log('::::::::: All Answers: ${widget.question.answers}');

    correctAnswer = widget.question.answers
        .indexWhere((element) => element == widget.question.correctAnswer);
    Logger.log('::::::::: correct answer index: $correctAnswer');

    // إعداد الـ Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // مدة اهتزاز الإجابة
    );

    // إعداد تأثير الاهتزاز
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_shakeController);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void selectAnswer(int index) {
    setState(() {
      selectedAnswer = index;
    });
  }

  void confirmAnswer() {
    setState(() {
      isConfirmed = true;
    });

    
    if (selectedAnswer != correctAnswer) {
      _shakeController.repeat(reverse: true); // تكرار الاهتزاز
      Future.delayed(const Duration(seconds: 2), () {
        _shakeController.stop(); // إيقاف الاهتزاز بعد 2 ثانية
        _shakeController.reverse();
      });
    }
  }

  late bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
 
    return Column(
     
      children: [
        // -- Question Widget
        Container(
          padding: const EdgeInsets.all(10),
          margin: widget.margin ?? const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:  isDarkMode? AppDarkColors.container : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.questionTitle != null
                    ? widget.questionTitle!
                    : '${'Question'.tr} ${widget.numberQuestion ?? ''}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
              ),
              const Divider(color: Colors.grey),

              // -- question text widget with scrollable if the question is too long
              Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 80),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 170),
                  child: Scrollbar(
                    controller: scrollController,
                    interactive: true,
                    thumbVisibility: true,  // for show the scrollbar when the widget need scroll
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Text(widget.question.question,
                      textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    
        // -- answers options
        for (var i = 0; i < widget.question.answers.length; i++)
          buildOptionTile(i, widget.question.answers[i]),
    
    
        const SizedBox(height: 10),
    
        // زر التأكيد مع تأثير ظهور تدريجي
        Container(
          // color: Colors.red,
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          // height: 35,
          child: AnimatedOpacity(
            opacity: (selectedAnswer != null && !isConfirmed) ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: () {
                confirmAnswer();
                widget.onConfirm?.call(selectedAnswer == correctAnswer);
              },
              style: ElevatedButton.styleFrom(backgroundColor: isDarkMode? Colors.grey[800] : null),
              child: Text('Confirm Answer'.tr),
            ),
          ),
        ),
      ],
    );
  }

  // دالة لإنشاء خيار مع margin و radius
  Widget buildOptionTile(int index, String text) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, childWidget) {
        double offset = 0;
        if (isConfirmed && selectedAnswer == index && selectedAnswer != correctAnswer) {
          offset = _shakeAnimation.value;  // تطبيق الاهتزاز فقط على الحاوية الخاطئة
        }

        return Transform.translate(
          offset: Offset(offset, 0), // حركة أفقية (اهتزاز)
          child: childWidget,
        );
      },
      child: AnimatedContainer(
        // height: getTileHeight(index),
        duration: const Duration(milliseconds: 300), // مدة تأثير تغيير اللون
        margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: getTileColor(index),
          borderRadius: BorderRadius.circular(20), // تدوير الحواف
          border: getTileDecoration(index),
        ),
        child: ListTile(
          title: Text(text, textAlign: TextAlign.center),
          visualDensity: const VisualDensity(vertical: -1),
          titleTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: getTileTextColor(index)),
          onTap: !isConfirmed ? () => selectAnswer(index) : null,
          trailing: getIconWithAnimation(index),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  double getTileHeight(int index) {
    if (isConfirmed) {
      if (index == selectedAnswer && index != correctAnswer){
        return 51;
      }
    } 
    return 55;
  }

  // دالة لاختيار لون البلاطة
  Color getTileColor(int index) {
    Color normalColor = isDarkMode? AppDarkColors.container : Colors.white;
    if (!isConfirmed) {
      return selectedAnswer == index ? AppColors.primary2 : normalColor;
    } else {
      if (index == correctAnswer && (widget.markCorrectAnswerWhenWrong || index == selectedAnswer)) {
        return Colors.green; 
      }
    }
    return normalColor;
  }
  
  Color? getTileTextColor(int index) {
    Color normalColor = isDarkMode? Colors.white : Colors.black;
    if (!isConfirmed && selectedAnswer == index){
      // -- set the text color to white in the selected choice
      return Colors.white;
    } else if (isConfirmed && index == correctAnswer) {
      // -- set the text color to white in the correct choice
      return Colors.white;
    }
    return normalColor;
  }

  Border? getTileDecoration(int index) {
    if (isConfirmed && index == selectedAnswer && index != correctAnswer) {
      return Border.all(color: Colors.red, width: 2); // إطار أحمر للإجابة الخاطئة
    }
    return null;
  }

  // دالة لتحديد الرمز الظاهر بجانب الخيار مع تأثير الحركات
  Widget? getIconWithAnimation(int index) {
    if (isConfirmed) {
      if (index == correctAnswer && widget.markCorrectAnswerWhenWrong) {
        return const Icon(Icons.check, color: Colors.white);
      } else if (index == selectedAnswer && index != correctAnswer) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: const Icon(Icons.close, color: Colors.red),
        );
      }
    }
    return null;
  }
}