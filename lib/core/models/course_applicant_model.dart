import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:e_training_mate/core/utils/logger.dart';

import '../../common/enums/applicant_status_enum.dart';

class CourseApplicantModel {
  String? docId;
  String studentId;
  DateTime applicantDate;
  DateTime? responseDate;
  ApplicantStatusEnum status;
  UserModel? student;

  CourseApplicantModel({
    this.docId,
    required this.applicantDate,
    this.responseDate,
    required this.status,
    required this.studentId,
    this.student,
  });


  CourseApplicantModel copyWith({
    String? docId,
    DateTime? applicantDate,
    DateTime? responseDate,
    ApplicantStatusEnum? status,
    String? studentId,
    UserModel? student,
  }) {
    return CourseApplicantModel(
      docId: docId ?? this.docId,
      applicantDate: applicantDate ?? this.applicantDate,
      responseDate: responseDate ?? this.responseDate,
      status: status ?? this.status,
      studentId: studentId ?? this.studentId,
      student: student ?? this.student,
    );
  }
  
  CourseApplicantModel copyWithObject(CourseApplicantModel object) {
    return CourseApplicantModel(
      docId: object.docId ?? docId,
      applicantDate: object.applicantDate,
      responseDate: object.responseDate ?? responseDate,
      status: object.status,
      studentId: object.studentId,
      student: object.student ?? student,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (docId != null) 'docId': docId,
      'applicantDate': applicantDate,
      if (responseDate != null) 'responseDate': responseDate,
      'status': status.name,
      'studentId': studentId,
    };
  }

  factory CourseApplicantModel.fromMap(Map<String, dynamic> map) {
    return CourseApplicantModel(
      docId: map['docId'],
      applicantDate: (map['applicantDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      responseDate: (map['responseDate'] as Timestamp?)?.toDate(),
      status: map['status'] != null
          ? ApplicantStatusEnum.values.byName(map['status'])
          : ApplicantStatusEnum.waiting,
      studentId: map['studentId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CourseApplicantModel.fromJson(String source) => CourseApplicantModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ApplicantModel(docId: $docId, applicantDate: $applicantDate, responseDate: $responseDate, status: $status, studentId: $studentId, student: $student)';
  }


  static Future<List<CourseApplicantModel>> getCourseApplicants({
    required String courseId,
    bool fetchStudentData = true,
  }) async {
    final List<CourseApplicantModel> applicantsList = [];

    final applicantsCol = await FirebaseFirestore.instance.collection('courses')
      .doc(courseId).collection('applicants').get();

    // extract the courses data from firbase docs
    for (var doc in applicantsCol.docs) {
      final applicant = CourseApplicantModel.fromMap(doc.data());
      applicant.docId = doc.id;

      Logger.log(applicant);

      // -- fetch the trainer data of the course
      if (fetchStudentData && applicant.studentId.isNotEmpty){
        applicant.student = await UserModel.getUserInfoById(applicant.studentId);
      }
      applicantsList.add(applicant);
    }

    return applicantsList;
  }
  
  static void listenToCourseApplicants({
    required String courseId,
    bool fetchStudentData = true,
    void Function(List<CourseApplicantModel> updatedData)? onData,
  }) async {
    final applicantsColSnapshot = FirebaseFirestore.instance.collection('courses')
      .doc(courseId).collection('applicants').snapshots();
    
    // Create an empty list to store applicants
    List<CourseApplicantModel> applicantsList = [];

    applicantsColSnapshot.listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        final docData = change.doc.data();
        final docId = change.doc.id;

        if (docData == null) continue;

        final applicant = CourseApplicantModel.fromMap(docData);
        applicant.docId = docId;

        // Handle added or modified applicants
        if (change.type == DocumentChangeType.added ||
          change.type == DocumentChangeType.modified) {
          // Check if the applicant is already in the list
          int index = applicantsList.indexWhere((item) => item.docId == docId);

          if (index == -1) {
            // Add new applicant and fetch student data if needed
            if (fetchStudentData && applicant.studentId.isNotEmpty) {
              applicant.student = await UserModel.getUserInfoById(applicant.studentId);
            }
            applicantsList.add(applicant);
          } else {
            // -- get student data if was not found
            if (fetchStudentData &&
                applicant.studentId.isNotEmpty &&
                applicantsList[index].student == null) {
              applicant.student = await UserModel.getUserInfoById(applicant.studentId);
            }
            
            // -- Update existing applicant
            applicantsList[index] = applicantsList[index].copyWithObject(applicant);
          }
        }

        // Handle removed applicants
        if (change.type == DocumentChangeType.removed) {
          applicantsList.removeWhere((item) => item.docId == docId);
        }
      }

      // Trigger the callback function with the updated data
      onData?.call(applicantsList);
    });
  }

  static Future<String> sendApplicantRequest({required CourseApplicantModel applicant, required String courseId}) async {
    final firestore = FirebaseFirestore.instance;

    // -- Refrsh the course applicants data
    final resultDoc = await firestore.collection('courses').doc(courseId)
      .collection('applicants').add(applicant.toMap());
    return resultDoc.id;
  }

  static Future<void> acceptApplicantRequest({required CourseApplicantModel applicant, required String courseId}) async {
    final firestore = FirebaseFirestore.instance;

    // -- Add the course to the courses in which the learner is registered
    await firestore.collection('users').doc(applicant.studentId)
      .collection('registeredCourses').add({
        'courseId': courseId,
        'joiningDate': DateTime.now().toString(),
      });

    // -- Refrsh the course applicants data
    await firestore.collection('courses').doc(courseId).collection('applicants')
      .doc(applicant.docId).update({
        'status': ApplicantStatusEnum.accepted.name,
        'responseDate': DateTime.now(),
      });
  }
  
  
  static Future<void> cancelApplicantRequest({required String applicantDocId, required String courseId}) async {
    final firestore = FirebaseFirestore.instance;

    // -- Refrsh the course applicants data
    await firestore.collection('courses').doc(courseId).collection('applicants')
      .doc(applicantDocId).delete();
  }

  
}
