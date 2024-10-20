import 'dart:convert';

class QuizQuestionModel {
  int questionNumber;
  String question;
  List<String> answers;
  String  correctAnswer;
  double questionDegree;
  
  QuizQuestionModel({
    required this.questionNumber,
    required this.question,
    required this.answers,
    required this.correctAnswer,
    required this.questionDegree,
  });


  QuizQuestionModel copyWith({
    int? questionNumber,
    String? question,
    List<String>? answers,
    String? correctAnswer,
    double? questionDegree,
  }) {
    return QuizQuestionModel(
      questionNumber: questionNumber ?? this.questionNumber,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      questionDegree: questionDegree ?? this.questionDegree,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionNumber': questionNumber,
      'question': question,
      'answers': answers,
      'correctAnswer': correctAnswer,
      'questionDegree': questionDegree,
    };
  }

  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionModel(
      questionNumber: map['questionNumber'] ?? 0,
      question: map['question'] ?? '',
      answers: List<String>.from(map['answers']),
      correctAnswer: map['correctAnswer'] ?? '',
      questionDegree: map['questionDegree']?.toDouble() ?? 0.0,
    );
  }

  static List<Map<String, dynamic>> toMapList(List<QuizQuestionModel> questions) {
    return questions.map((e) => e.toMap()).toList();
  }

  static  List<QuizQuestionModel> fromMapList(List<Map<String, dynamic>> list) {
    return list.map((e) => QuizQuestionModel.fromMap(e)).toList();
  }


  String toJson() => json.encode(toMap());

  factory QuizQuestionModel.fromJson(String source) => QuizQuestionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'QuestionModel(question: $question, answers: $answers, correctAnswer: $correctAnswer, questionDegree: $questionDegree)';
  }
}
