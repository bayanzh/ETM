import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/core/models/quiz_question_answer_model.dart';
import 'package:e_training_mate/core/models/quiz_result_model.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/features/student_courses/models/student_lesson_vr_model.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentCourseModel {
  String? docId;
  double viewingRate;
  DateTime joiningDate;
  DateTime lastViewDate;
  CourseModel course;
  List<StudentLessonVRModel> lessonsViewingRate;
  List<QuizResultModel> quizResults;

  StudentCourseModel({
    this.docId,
    this.viewingRate = 0.0,
    required this.joiningDate,
    required this.lastViewDate,
    required this.course,
    required this.lessonsViewingRate,
    required this.quizResults,
  }) {
    calculateCourseViewingRate();
  }

  static List<StudentCourseModel> faker({int length = 2}) {
    var faker = Faker();
    return List.generate(
      length,
      (index) => StudentCourseModel(
        joiningDate: faker.date.dateTime(),
        lastViewDate: faker.date.dateTime(),
        course: CourseModel.faker(length: 1).first,
        lessonsViewingRate: StudentLessonVRModel.faker(length: 3),
        quizResults: [],
      ),
    );
  }

  factory StudentCourseModel.fromMap({
    String? docId,
    required Map<String, dynamic> map,
    
    required CourseModel course,
  }) {
    final model = StudentCourseModel(
      docId: docId,
      joiningDate: DateTime.parse(map['joiningDate']),
      lastViewDate: DateTime.parse(map['lastViewDate'] ?? map['joiningDate']),
      lessonsViewingRate: StudentLessonVRModel.fromMapList(
          map['lessonsViewingRate']?.cast<Map<String, dynamic>>() ?? []),
      quizResults: List<QuizResultModel>.from(map['quizResults']?.map((e) => QuizResultModel.fromMap(e)) ?? []),
      course: course,
    );

    model.calculateCourseViewingRate();
    return model;
  }

  double calculateCourseViewingRate() {
    int lessonLength = course.lessons?.length ?? 1;
    lessonLength = lessonLength > 0 ? lessonLength : 1;

    // -- calculate the  viewing rate of the course from
    // the viewing rate for every lesson in the course
    viewingRate = lessonsViewingRate.fold(0.0,
            (previousValue, element) => previousValue + element.viewingRate) /
        lessonLength;

    return viewingRate;
  }

  StudentCourseModel copyWith({
    double? viewingRate,
    DateTime? joiningDate,
    DateTime? lastViewDate,
    CourseModel? course,
    List<StudentLessonVRModel>? lessonsViewingRate,
    List<QuizResultModel>? quizResults,
  }) {
    return StudentCourseModel(
      viewingRate: viewingRate ?? this.viewingRate,
      joiningDate: joiningDate ?? this.joiningDate,
      lastViewDate: lastViewDate ?? this.lastViewDate,
      course: course ?? this.course,
      lessonsViewingRate: lessonsViewingRate ?? this.lessonsViewingRate,
      quizResults: quizResults ?? this.quizResults,
    );
  }

  StudentCourseModel copyWithMap(Map<String, dynamic> map) {
    final model = StudentCourseModel(
      docId: docId,
      joiningDate: DateTime.parse(map['joiningDate']),
      lastViewDate: DateTime.parse(map['lastViewDate'] ?? map['joiningDate']),
      course: course,
      viewingRate: viewingRate,
      lessonsViewingRate: StudentLessonVRModel.fromMapList(
          map['lessonsViewingRate']?.cast<Map<String, dynamic>>() ?? []),
      quizResults: List<QuizResultModel>.from(map['quizResults']?.map((e) => QuizResultModel.fromMap(e)) ?? []),
    );

    model.calculateCourseViewingRate();
    return model;
  }

  Map<String, dynamic> toMap() {
    return {
      'viewingRate': viewingRate,
      'joiningDate': joiningDate.toString(),
      'lastViewDate': lastViewDate.toString(),
      'course': course.toMap(),
      'lessonsViewingRate': StudentLessonVRModel.toMapList(lessonsViewingRate),
      'quizResults': quizResults.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  factory StudentCourseModel.fromJson(String source, CourseModel course) =>
      StudentCourseModel.fromMap(map: json.decode(source), course: course);


  @override
  String toString() =>
      'StudentCourseModel(joiningDate: $joiningDate, lastViewDate: $lastViewDate, viewingRate: $viewingRate, lessonsViewingRate: $lessonsViewingRate, quizResults: $quizResults, course: $course)';



  
  static Future<List<StudentCourseModel>> getStudentCourses({
    int? limit,
    bool orderBylastViewDate = false,
    bool orderByJoinigDate = false,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    List<StudentCourseModel> studentCourses = [];

    Query<Map<String, dynamic>> ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('registeredCourses');

    // -- Arrange the student's courses in descending order by lastViewedDate field
    if (orderBylastViewDate)  ref = ref.orderBy('lastViewDate', descending: true);

    // -- Arrange the student's courses in descending order by joiningDate field
    if (orderByJoinigDate) ref = ref.orderBy('joiningDate');

    if (limit != null) ref = ref.limit(limit);

    // -- get the
    final studentCoursesCol = await ref.get();

    final studentCoursesDocs = studentCoursesCol.docs;

    // extract the courses data from firbase docs
    for (int i = 0; i < studentCoursesDocs.length; i++) {
      final docData = studentCoursesDocs[i].data();

      final course = await CourseModel.getCourseDataById(
        courseId: docData['courseId'],
        getCourseLessons: true,
      );
      if (course != null) {
        studentCourses.add(StudentCourseModel.fromMap(
         
          map: docData,
          docId: studentCoursesDocs[i].id,
          course: course,
        ));
      }
    }
    return studentCourses;
  }

  // -- A function to listen to the course in which the student is registered,
  // to update every change in the course data, including changes in the viewing 
  // rate for each lesson in the course, and also changes in the student’s 
  // completion rate for quizes
  static void listenToStudentCourseData({
    required StudentCourseModel studentCourse,
    void Function(StudentCourseModel course)? onData,
  }) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final studentCourseDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('registeredCourses')
        .doc(studentCourse.docId);

    studentCourseDocRef.snapshots().listen((event) {
      Logger.log("::::: New Event From listenToStudentCourse: ${event.data()}");

      var eventData = event.data();
      if (eventData != null) {
        onData?.call(studentCourse.copyWithMap(eventData));
      }
    });
  }

  static Future<StudentCourseModel?> getStudentCourseDataByCourseId({
    required String courseId,
    bool getCourseLessons = true,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final snapshot = await FirebaseFirestore.instance.collection('users')
      .doc(uid).collection('registeredCourses')
      .where('courseId', isEqualTo: courseId).get();

    final studentCourseDoc = snapshot.docs.first;
    if (snapshot.docs.first.exists) {
      final course = await CourseModel.getCourseDataById(
        courseId: studentCourseDoc['courseId'],
        getCourseLessons: getCourseLessons,
      );

      if (course != null) {
        return StudentCourseModel.fromMap(
         
          map: studentCourseDoc.data(),
          docId: studentCourseDoc.id,
          course: course,
        );
      }
    }
    return null;
  }
  
  Future<void> updateLastViewDate() async {
    Logger.log("::: Begin update lastViewDate of course to: $lastViewDate");
    final uid = FirebaseAuth.instance.currentUser?.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('registeredCourses')
        .doc(docId)
        .update({'lastViewDate': lastViewDate.toString()});
    Logger.log("::: End update lastViewDate of course to: $lastViewDate");
  }

  Future<void> submitQuestionAnswer({
    required String quizId,
    required double quizFullGrade,
    required QuizQuestionAnswerModel questionAnswer,
  }) async {
    Logger.log("::: Begin submitQuestionAnswer For Quiz : $quizId ");
    
    int quizIndex = quizResults.indexWhere((element) => element.quizId == quizId);
    if (quizIndex == -1) {
      Logger.log("??????? Submit New Quiz");
      quizResults.add(QuizResultModel(
        quizId: quizId,
        quizFullGrade: quizFullGrade,
        questionsAnswer: [],
      ));
      quizIndex = quizResults.length - 1;
    }

    int questionAnswerIndex = quizResults[quizIndex].questionsAnswer.indexWhere((element) => element.questionNumber == questionAnswer.questionNumber);
    if (questionAnswerIndex == -1){
      Logger.log("??????? Submit New Answer");
      quizResults[quizIndex].questionsAnswer.add(questionAnswer);
    } else {
      Logger.log("??????? Update Existing Answer");
      quizResults[quizIndex].questionsAnswer[questionAnswerIndex] = questionAnswer;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;

    Logger.log(':::::::::: DocID: $docId');
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('registeredCourses')
        .doc(docId)
        .update({'quizResults': QuizResultModel.toMapList(quizResults)});
    Logger.log("::: Begin submitQuestionAnswer For Quiz : $quizId");
  }
}
