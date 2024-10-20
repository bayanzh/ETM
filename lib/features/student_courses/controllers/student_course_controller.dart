import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:e_training_mate/features/student_courses/models/student_lesson_vr_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/services/network_info.dart';
import '../../../core/utils/logger.dart';

class StudentCourseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isUpdateViewingRateLoading = false.obs;

  late User? currentUser;
  late StudentCourseModel studentCourse;

  List<LessonModel> courseLessons = [];

  @override
  void onInit() {
    super.onInit();
    currentUser = FirebaseAuth.instance.currentUser;

    
  }

  Future<void> refreshScreen() async {
    try {
     
      await refreshCourseLessons(studentCourse);
      studentCourse.calculateCourseViewingRate();
      update();
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
  }

  // -- A function to listen to the course in which the student is registered,
  // to update every change in the course data, including changes in the viewing
  // rate for each lesson in the course, and also changes in the student’s
  // completion rate for quizes.
  Future<void> listenToStudentCourse(StudentCourseModel course) async {
    try {
      studentCourse = course;
      Logger.logError(':::: Student Model Id: ${studentCourse.docId}');
      courseLessons = studentCourse.course.lessons ?? [];

      StudentCourseModel.listenToStudentCourseData(
        studentCourse: studentCourse,
        onData: (event) {
          studentCourse = event;
          update();
        },
      );
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> refreshCourseLessons(StudentCourseModel course) async {
    studentCourse = course;
    isLoading.value = true;

    try {
      final courseId = studentCourse.course.cDocId!;

      courseLessons = await LessonModel.getCourseLessons(courseId);
      studentCourse.course.lessons = courseLessons;

      Logger.log(
          "::::: Success get course lessons (length): ${courseLessons.length}");
      update();
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }

  Future<bool> updateLessonViewingRate(
    String lessonId, {
    double? viewingRate,
    bool? wrongAnswer,
    bool? correctAnswer,
  }) async {
    try {
      Logger.log("--- Update Lesson viewing rate");

      // -- update lesson viewing rate
      List<StudentLessonVRModel> lessonsVRList = studentCourse.lessonsViewingRate;

      final index = lessonsVRList.indexWhere((element) => element.lessonId == lessonId);
      if (index != -1) {
        StudentLessonVRModel lessonVR = lessonsVRList[index];
        if (viewingRate != null) {
          lessonVR = lessonVR.copyWith(viewingRate: viewingRate);
        } 
        if (wrongAnswer != null && wrongAnswer == true) {
          lessonVR = lessonVR.copyWith(wrongAnswerCount: (lessonVR.wrongAnswerCount ?? 0) + 1);
          Logger.log(lessonVR);
        } 
        if (correctAnswer != null && correctAnswer == true) {
          lessonVR = lessonVR.copyWith(correctAnswerAt: DateTime.now());
        }

        lessonsVRList[index] = lessonVR;
      } else {
        lessonsVRList.add(StudentLessonVRModel(
          lessonId: lessonId,
          viewingRate: viewingRate ?? 0.0,
          wrongAnswerCount: wrongAnswer != null && wrongAnswer == true ? 1 : null,
          correctAnswerAt: correctAnswer != null && correctAnswer == true? DateTime.now() : null,
        ));
      }

      // -- calculate the course viewing rate from viewing rate for every course lesson
      final courseViewingRate = lessonsVRList.fold(
              0.0, (previousV, element) => previousV + element.viewingRate) /
          (studentCourse.course.lessons?.length ?? 1.0);

      if (await NetworkInfo().isConnected) {
        Logger.log("---------- connected Internet");

        // -- update the data to firebase
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('registeredCourses')
            .doc(studentCourse.docId)
            .update({
          'viewingRate': courseViewingRate,
          'lessonsViewingRate': StudentLessonVRModel.toMapList(lessonsVRList),
        });


        return true;
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
    return false;
  }
}
