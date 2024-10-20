import 'package:e_training_mate/common/enums/applicant_status_enum.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/core/models/notification_model.dart';
import 'package:e_training_mate/core/services/fire_notification_service.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:e_training_mate/features/student_courses/screen/student_course_screen.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/models/course_applicant_model.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/logger.dart';

class CourseController extends GetxController {
  final RxBool lessonsLoading = false.obs;
  final RxBool applicantsLoading = false.obs;

  late Rx<User?> currentUser;

  RxList<LessonModel> courseLessons = <LessonModel>[].obs;
  RxList<CourseApplicantModel> courseApplicants = <CourseApplicantModel>[].obs;

  String? courseId;
  CourseModel? course;

  Rx<CourseApplicantModel?> currentUserApplicant = Rx(null);

  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);

    // -- listen to user data changes
    FirebaseAuth.instance.userChanges().listen((event) => currentUser.value = event);
  }

  Future<void> refreshPage() async {
    getCourseLessons();
    getCourseApplicants();
  }

  Future<void> getCourseLessons() async {
    lessonsLoading.value = true;

    try {
      if (courseId != null) {
        courseLessons.clear();
        courseLessons.addAll(
          await LessonModel.getCourseLessons(courseId!),
        );
        update();
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    lessonsLoading.value = false;
  }
  
  Future<void> getCourseApplicants() async {
    applicantsLoading.value = true;

    try {
      if (courseId != null) {
        courseApplicants.clear();
        courseApplicants.addAll(
          await CourseApplicantModel.getCourseApplicants(courseId: courseId!, fetchStudentData: false),
        );

        currentUserApplicant.value = courseApplicants.firstWhereOrNull(
            (element) => element.studentId == currentUser.value?.uid);
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    applicantsLoading.value = false;
  }
  
  Future<void> sendApplicantRequestToCourse() async {
    try {
      if (courseId != null) {
        DialogUtil.loadinDialog();
       
        final applicant = CourseApplicantModel(
          applicantDate: DateTime.now(),
          status: ApplicantStatusEnum.waiting,
          studentId: currentUser.value?.uid ?? '',
        );

        final applicantId = await CourseApplicantModel.sendApplicantRequest(
          applicant: applicant,
          courseId: courseId!,
        );
        
        if (course?.cDocId != null) {
          FireNotificationService.instance.subscribeToTopicNotification(course!.cDocId!);
        }

        CourseModel.incrementRegistrationsCount(courseId!);

        Logger.log(':::::::::::::: Trainer Account Token: ${course?.trainer?.deviceToken}');
        FireNotificationService.instance.sendNotificationToToken(
          token: course?.trainer?.deviceToken ?? '',
          title: 'متقدم جديد لـ ${course?.name}',
          body: '${currentUser.value?.displayName} قدَّم طلبًا جديدًا للانضمام إلى دورة ${course?.name}.',
        );

        final notification = NotificationModel(
          senderId: currentUser.value?.uid ?? '',
          recieversIds: [course?.trainerId ?? ''],
          showToUsers: [course?.trainerId ?? ''],
          senderName: currentUser.value?.displayName ?? '',
          title: 'متقدم جديد لـ ${course?.name}',
          body: '${currentUser.value?.displayName} قدَّم طلبًا جديدًا للانضمام إلى دورة ${course?.name}.',
          createdAt: DateTime.now(),
        );
        notification.saveNotificationData();

        
        applicant.docId = applicantId;
        currentUserApplicant.value = applicant;
        Get.back();
        AppHelper.showToastSnackBar(message: 'The request has been sent successfully.', isSuccess: true);
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      Get.back();
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      Get.back();
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }


  Future<void> cancelCourseApplicant() async {
    try {
      Logger.log(currentUserApplicant.value?.docId);
      if (courseId != null) {
        DialogUtil.loadinDialog();
       
        await CourseApplicantModel.cancelApplicantRequest(
          applicantDocId: currentUserApplicant.value?.docId ?? '',
          courseId: courseId!,
        );

        if (course?.cDocId != null) {
          FireNotificationService.instance.unsubscribeToTopicNotification(course!.cDocId!);
        }

        CourseModel.decrementRegistrationsCount(courseId!);
        
        currentUserApplicant.value = null;
        Get.back();
        AppHelper.showToastSnackBar(message: 'The request was successfully cancelled.', isSuccess: true);
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      Get.back();
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      Get.back();
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> goToWatchCourse() async {
    try {
      DialogUtil.loadinDialog();
      if (courseId != null) {
        final studentCourse = await StudentCourseModel.getStudentCourseDataByCourseId(
          courseId: courseId!,
          getCourseLessons: true,
        );
       Logger.log('CoursID: $courseId');
        
        Get.back();
        if (studentCourse != null ) {
          Get.to(() => StudentCourseScreen(studentCourse: studentCourse));
        } else {
          AppHelper.showToastSnackBar(message: 'Unexpected error!, try again.', isError: true);
        }
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      Get.back();
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      Get.back();
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }
}