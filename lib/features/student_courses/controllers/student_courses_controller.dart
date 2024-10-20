import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/services/network_info.dart';
import '../../../core/utils/logger.dart';
import '../screen/student_course_screen.dart';

class StudentCoursesController extends GetxController {
  final RxBool isLoading = false.obs;

  late Rx<User?> currentUser;

  RxList<StudentCourseModel> studentCourses = <StudentCourseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    getStudentCourses();

    // -- listen to user data changes
    FirebaseAuth.instance.userChanges().listen((event) => currentUser.value = event);
  }

  Future<void> getStudentCourses() async {
    isLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

     

      studentCourses.value = await StudentCourseModel.getStudentCourses(orderByJoinigDate: true);
    
      Logger.log("::::: Success get courses data (length): ${studentCourses.length}");
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }

  Future<CourseModel?> getCourseDataById(String courseId) async {
    final courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get();

    if (courseSnapshot.exists) {
      CourseModel course = CourseModel.fromMap(courseSnapshot.data()!);
      course.cDocId = courseSnapshot.id;

      // -- get course lessons data
      final lessonsCol = await courseSnapshot.reference.collection('lessons').orderBy('createdAt').get();
      course.lessons = lessonsCol.docs.map((lessonDoc) {
        final lessonModel = LessonModel.fromMap(lessonDoc.data());
        lessonModel.docId = lessonDoc.id;
        return lessonModel;
      }).toList();

      return course;
    }
    return null;
  }

  Future<void> onCourseTap(int courseIndex) async {
    // -- go to SpecificCourseScreen and after close it recieve the updated course object 
    // from SpecificCourseScreen then replace the current course object with the update
    // course object to update the course data in current the screen.

    Get.to(() {
      return StudentCourseScreen(studentCourse: studentCourses[courseIndex]);
    })?.then((value) {
      if (value != null && value is StudentCourseModel) {
        studentCourses[courseIndex] = value;
      }
    });
    

    studentCourses[courseIndex].lastViewDate = DateTime.now();
    await studentCourses[courseIndex].updateLastViewDate();
  }
}