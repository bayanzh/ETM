import 'dart:convert';

import 'quiz_question_answer_model.dart';

class QuizResultModel {
  String quizId;
  double quizFullGrade;
  List<QuizQuestionAnswerModel> questionsAnswer;
  
  QuizResultModel({
    required this.quizId,
    required this.quizFullGrade,
    required this.questionsAnswer,
  });

  QuizResultModel copyWith({
    String? quizId,
    double? quizFullGrade,
    int? correctAnswerCount,
    int? wrongAnswerCount,
    List<QuizQuestionAnswerModel>? questionsAnswer,
  }) {
    return QuizResultModel(
      quizId: quizId ?? this.quizId,
      quizFullGrade: quizFullGrade ?? this.quizFullGrade,
      questionsAnswer: questionsAnswer ?? this.questionsAnswer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'quizFullGrade': quizFullGrade,
      'questionsAnswer': QuizQuestionAnswerModel.toMapList(questionsAnswer),
    };
  }

  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      quizId: map['quizId'] ?? '',
      quizFullGrade: map['quizFullGrade']?.toDouble() ?? 0.0,
      questionsAnswer: List<QuizQuestionAnswerModel>.from(map['questionsAnswer']?.map((x) => QuizQuestionAnswerModel.fromMap(x)) ?? []),
    );
  }

  static List<Map<String, dynamic>> toMapList(List<QuizResultModel> list) {
    return list.map((element) => element.toMap()).toList();
  }
  
  static List<QuizResultModel> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => QuizResultModel.fromMap(map)).toList();
  }

  String toJson() => json.encode(toMap());

  factory QuizResultModel.fromJson(String source) => QuizResultModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuizResultModel(quizId: $quizId, quizFullGrade: $quizFullGrade, questionsAnswer: $questionsAnswer)';
  }
}
