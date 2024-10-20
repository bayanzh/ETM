import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/common/enums/lesson_type_enum.dart';
import 'package:e_training_mate/core/models/quiz_question_model.dart';

import '../utils/helpers/app_helper.dart';
import '../utils/logger.dart';
import '../services/network_info.dart';

class LessonModel {
  String? docId;
  String title;
  String? description;
  int lessonOrderNum;
  DateTime createdAt;
  LessonTypeEnum type;

  String? question;

  List<String>? answers;

  String? correctAnswer;

  /// -- the quizFullGrade variable is'nt available when the type = lesson
  double? quizFullGrade;

  /// -- the videoUrl will be available when the type = lesson
  String? videoUrl;

  /// -- the quizQuestions will be available when the type = quiz
  List<QuizQuestionModel>? quizQuestions;
  
  

  LessonModel({
    this.docId,
    required this.title,
    this.description,
    this.quizFullGrade,
    required this.lessonOrderNum,
    required this.createdAt,
    required this.type,
    this.videoUrl,
    this.quizQuestions,
    this.question,
    this.answers,
    this.correctAnswer,
  });

  LessonModel copyWith({
    String? docId,
    String? title,
    String? description,
    double? quizFullGrade,
    int? lessonOrderNum,
    DateTime? createdAt,
    LessonTypeEnum? type,
    String? videoUrl,
    List<QuizQuestionModel>? quizQuestions,
    String? question,
    List<String>? answers,
    String? correctAnswer,
  }) {
    return LessonModel(
      docId: docId ?? this.docId,
      title: title ?? this.title,
      description: description ?? this.description,
      quizFullGrade: quizFullGrade ?? this.quizFullGrade,
      lessonOrderNum: lessonOrderNum ?? this.lessonOrderNum,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      videoUrl: videoUrl ?? this.videoUrl,
      quizQuestions: quizQuestions ?? this.quizQuestions,
      question: question ?? this.question,
      answers: answers ?? this.answers,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (docId != null) 'docId': docId,
      'title': title,
      if (description != null)  'description': description,
      if (quizFullGrade != null)  'quizFullGrade': quizFullGrade,
      'lessonOrderNum': lessonOrderNum,
      'createdAt': createdAt.toString(),
      'type': type.name,
      if (videoUrl != null)  'videoUrl': videoUrl,
      if (quizQuestions != null)  'quizQuestions': QuizQuestionModel.toMapList(quizQuestions!),
      if (question != null)  'question': question,
      if (answers != null)  'answers': answers,
      if (correctAnswer != null)  'correctAnswer': correctAnswer,
    };
  }

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      docId: map['lid'],
      title: map['title'] ?? '',
      description: map['description'],
      quizFullGrade: map['quizFullGrade']?.toDouble() ?? 0.0,
      lessonOrderNum: map['lessonOrderNum'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      type: LessonTypeEnum.values.byName(map['type'] ?? 'lesson'),
      videoUrl: map['videoUrl'],
      quizQuestions: map['quizQuestions'] != null? QuizQuestionModel.fromMapList(map['quizQuestions'].cast<Map<String, dynamic>>() ?? []) : null,
      question: map['question'],
      answers: map['answers'] != null? List<String>.from(map['answers']) : null,
      correctAnswer: map['correctAnswer'] ?? '',
    );
  }

  static List<Map<String, dynamic>> toMapList(List<LessonModel> lessons) {
    return lessons.map((lesson) => lesson.toMap()).toList();
  }
  
  static List<LessonModel> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => LessonModel.fromMap(map)).toList();
  }

  String toJson() => json.encode(toMap());

  factory LessonModel.fromJson(String source) => LessonModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CourseLessonModel(lid: $docId, title: $title, description: $description, quizFullGrade: $quizFullGrade, createdAt: $createdAt, type: $type, videoUrl: $videoUrl, quizQuestions: $quizQuestions, question: $question, answers: $answers, correctAnswer: $correctAnswer)';
  }


  static Future<List<LessonModel>> getCourseLessons(String courseId) async {
    List<LessonModel> courseLessons = [];
    NetworkInfo().isConnected.then((value) {
      if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
    });

    final courseLessonsCol = await FirebaseFirestore.instance
        .collection('courses').doc(courseId).collection('lessons').orderBy('lessonOrderNum').get();

    // extract the courses data from firbase docs
    for (var doc in courseLessonsCol.docs) {
      final lesson = LessonModel.fromMap(doc.data());
      lesson.docId = doc.id;
      courseLessons.add(lesson);
    }
  
    Logger.log("::::: Success get course lessons (length): ${courseLessons.length}");
    return courseLessons;
  }

  static Future<void> deleteLesson({required String courseId, required String lessonId,}) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }
}
