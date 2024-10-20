import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

class StudentLessonVRModel {
  String lessonId;
  double viewingRate;
  int? wrongAnswerCount;
  DateTime? correctAnswerAt;
  
  StudentLessonVRModel({
    required this.lessonId,
    required this.viewingRate,
    this.wrongAnswerCount,
    this.correctAnswerAt,
  });

  static List<StudentLessonVRModel> faker({int length = 2}) {
    var faker = Faker();
    return List.generate(
      length,
      (index) => StudentLessonVRModel(
        lessonId: faker.jwt.secret,
        viewingRate: faker.randomGenerator.decimal(),
        correctAnswerAt: faker.date.dateTime(),
      ),
    );
  }

  StudentLessonVRModel copyWith({
    String? lessonId,
    double? viewingRate,
    int? wrongAnswerCount,
    DateTime? correctAnswerAt,
  }) {
    return StudentLessonVRModel(
      lessonId: lessonId ?? this.lessonId,
      viewingRate: viewingRate ?? this.viewingRate,
      wrongAnswerCount: wrongAnswerCount ?? this.wrongAnswerCount,
      correctAnswerAt: correctAnswerAt ?? this.correctAnswerAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'viewingRate': viewingRate,
      if (wrongAnswerCount != null) 'wrongAnswerCount': wrongAnswerCount,
      if (correctAnswerAt != null) 'correctAnswerAt': correctAnswerAt,
    };
  }

  factory StudentLessonVRModel.fromMap(Map<String, dynamic> map) {
    return StudentLessonVRModel(
      lessonId: map['lessonId'] ?? '',
      viewingRate: map['viewingRate']?.toDouble() ?? 0.0,
      wrongAnswerCount: map['wrongAnswerCount']?.toInt(),
      correctAnswerAt: (map['correctAnswerAt'] as Timestamp?)?.toDate(),
    );
  }

  static List<Map<String, dynamic>> toMapList(List<StudentLessonVRModel> lessonsVR) {
    return lessonsVR.map((lesson) => lesson.toMap()).toList();
  }
  
  static List<StudentLessonVRModel> fromMapList(List<Map<String, dynamic>> mapList) {
    return mapList.map((map) => StudentLessonVRModel.fromMap(map)).toList();
  }

  String toJson() => json.encode(toMap());

  factory StudentLessonVRModel.fromJson(String source) => StudentLessonVRModel.fromMap(json.decode(source));

  @override
  String toString() => 'StudentLessonVRModel(lessonId: $lessonId, viewingRate: $viewingRate, wrongAnswerCount: $wrongAnswerCount, correctAnswerAt: $correctAnswerAt)';
}
