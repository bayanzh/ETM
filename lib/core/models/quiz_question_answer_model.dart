import 'dart:convert';

class QuizQuestionAnswerModel {
  int questionNumber;
  double questionDegree;
  bool isAnswerCorrect;
  DateTime answeredAt;

  QuizQuestionAnswerModel({
    required this.questionNumber,
    required this.questionDegree,
    required this.isAnswerCorrect,
    required this.answeredAt,
  });


  QuizQuestionAnswerModel copyWith({
    int? questionNumber,
    double? questionDegree,
    bool? isAnswerCorrect,
    DateTime? answeredAt,
  }) {
    return QuizQuestionAnswerModel(
      questionNumber: questionNumber ?? this.questionNumber,
      questionDegree: questionDegree ?? this.questionDegree,
      isAnswerCorrect: isAnswerCorrect ?? this.isAnswerCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'questionDegree': questionDegree,
      'isAnswerCorrect': isAnswerCorrect,
      'answeredAt': answeredAt.toString(),
    };
  }

  factory QuizQuestionAnswerModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionAnswerModel(
      questionNumber: map['questionNumber']?.toInt() ?? 0,
      questionDegree: map['questionDegree']?.toDouble() ?? 0.0,
      isAnswerCorrect: map['isAnswerCorrect'] ?? false,
      answeredAt: DateTime.parse(map['answeredAt']),
    );
  }

  static List<Map<String, dynamic>> toMapList(List<QuizQuestionAnswerModel> list) {
    return list.map((element) => element.toMap()).toList();
  }
  
  static List<QuizQuestionAnswerModel> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => QuizQuestionAnswerModel.fromMap(map)).toList();
  }

  String toJson() => json.encode(toMap());

  factory QuizQuestionAnswerModel.fromJson(String source) => QuizQuestionAnswerModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuestionAnswerModel(questionNumber: $questionNumber, questionDegree: $questionDegree, isAnswerCorrect: $isAnswerCorrect, answeredAt: $answeredAt)';
  }


}
