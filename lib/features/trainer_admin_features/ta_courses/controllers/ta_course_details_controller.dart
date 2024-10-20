import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/common/enums/applicant_status_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/models/course_applicant_model.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/screens/ta_add_lesson_screen.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/enums/lesson_type_enum.dart';
import '../../../../core/constant/fire_constant.dart';
import '../../../../core/models/notification_model.dart';
import '../../../../core/models/quiz_question_model.dart';
import '../../../../core/services/network_info.dart';
import '../../../../core/services/fire_notification_service.dart';
import '../../../../core/services/fire_upload_files_service.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/utils/logger.dart';

class TaCourseDetailsController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool lessonsLoading = false.obs;
  final RxBool applicantsLoading = false.obs;

  late Rx<User?> currentUser;
  UserTypeEnum? userType = PrefHelper.getUserType();

  RxList<LessonModel> courseLessons = <LessonModel>[].obs;
  RxList<CourseApplicantModel> courseApplicants = <CourseApplicantModel>[].obs;
  List<CourseApplicantModel> pendingApplicants = [];
  List<CourseApplicantModel> othersApplicants = [];

  String? courseId;
  String? courseName;


  final globalLessonFormKey = GlobalKey<FormState>();
  final lessonFormKey = GlobalKey<FormState>();
  final quizFormKey = GlobalKey<FormState>();
  final lessonTitleCon = TextEditingController();
  final lessonDescriptionCon = TextEditingController();
  final lessonOrderNumCon = TextEditingController(text: '1');
  final Rx<LessonTypeEnum?> lessonType = Rx(null);
  final RxString videoPath = ''.obs;
  final questionCon = TextEditingController();
  final answerControllers = <TextEditingController>[].obs;
  final RxInt correctAnswerIndex  = 0.obs;
  RxList<QuizQuestionModel> quizQuestions = [
    QuizQuestionModel(
      questionNumber: 1,
      question: '',
      answers: ['', ''],
      correctAnswer: '',
      questionDegree: 1,
    ),
  ].obs;


  
  // -- fields to handle video upload
  RxString uploadingLessonId = ''.obs;
  RxDouble uploadProgressPercentage = 0.0.obs;

  RxString failUploadingLessonId = ''.obs;
  

  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);

    searchForFailUploadLesson();

  }

  @override
  void onClose() {
    lessonDescriptionCon.dispose();
    lessonOrderNumCon.dispose();
    lessonTitleCon.dispose();
    
    for (var controller in answerControllers) {
      controller.dispose();
    }

    if (uploadingLessonId.value.isNotEmpty) {
      PrefHelper.setFailUploadingLessonId(uploadingLessonId.value);
      PrefHelper.setFailVideoPath(videoPath.value);
    }
    super.onClose();
  }

  Future<void> refreshPage() async {
    getCourseLessons();
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

  void listenToApplicants() async {
    if (courseId != null) {
      applicantsLoading.value = true;

      CourseApplicantModel.listenToCourseApplicants(
        courseId: courseId!,
        onData: (updatedData) {
          courseApplicants.clear();
          courseApplicants.addAll(updatedData);

          // -- sort the users to set waiting users in the first
          courseApplicants.sort((a, b) {
            if (a.status == ApplicantStatusEnum.waiting &&
                b.status != ApplicantStatusEnum.waiting) {
              return -1; // يجعل المستخدمين "قيد الانتظار" في المقدمة
            } else if (a.status != ApplicantStatusEnum.waiting &&
                b.status == ApplicantStatusEnum.waiting) {
              return 1; // يجعل بقية المستخدمين بعدهم
            } else {
              return 0; // المستخدمين بنفس الحالة يبقون كما هم
            }
          });
          applicantsLoading.value = false;
        },
      );
    }
  }

  int getWaitingApplicantsCount(List<CourseApplicantModel> applicants) {
    final count = applicants.where(
          (element) => element.status == ApplicantStatusEnum.waiting,
        ).length;
    
    Logger.log('::::::::::::: Counts waitings: $count');
    return count;
  }

  Future<void> acceptLearnerRequest(CourseApplicantModel applicant) async {
    try {
      if (courseId != null) {
        await CourseApplicantModel.acceptApplicantRequest(
          applicant: applicant,
          courseId: courseId ?? '',
        );

        FireNotificationService.instance.sendNotificationToToken(
          token: applicant.student?.deviceToken ?? '',
         
          title: 'قبول طلبك للانضمام إلى $courseName',
          body: 'تم قبول طلبك للانضمام إلى دورة $courseName. نتطلع لرؤيتك قريبًا!',
        );

        final notification = NotificationModel(
          senderId: currentUser.value?.uid ?? '',
          recieversIds: [applicant.studentId],
          showToUsers: [applicant.studentId],
          senderName: currentUser.value?.displayName ?? '',
          title: 'قبول طلبك للانضمام إلى $courseName',
          body: 'تم قبول طلبك للانضمام إلى دورة $courseName. نتطلع لرؤيتك قريبًا!',
          createdAt: DateTime.now(),
        );
        notification.saveNotificationData();

      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> deleteCourse() async {
    try {
      if (courseId == null) return;
      
      // -- display confirmation dialog
      final confirmResult = await DialogUtil.showDeleteDialog(message: 'Are you sure you want to delete the course?');

      // -- delete course if the user confirms the deletion process
      if (confirmResult == true) {
        await Get.showOverlay(
          asyncFunction: () async {
            final result = await FireUploadFilesService.deleteFolderWithItsFiles(
              folderPath: '',
              deleteWhereFolderNameContains: courseId,
            );

            if (result) {
              await CourseModel.deleteCourse(courseId ?? '');
              Get.back();
            }
          },
          loadingWidget: AppHelper.custumProgressIndecator(size: 50),
        );
        AppHelper.showToastSnackBar(message: 'Deleted successfully', isSuccess: true);
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> deleteLesson(String lessonId) async {
    Logger.log(':::::::: Delete Lesson: $lessonId');
    try {
      if (courseId == null) return;
      
      // -- display confirmation dialog
      final confirmResult = await DialogUtil.showDeleteDialog(message: 'Are you sure you want to delete the lesson?');

      // -- delete lesson if the user confirms the deletion process
      if (confirmResult == true) {
        await Get.showOverlay(
          asyncFunction: () async {
            final result = await FireUploadFilesService.deleteFile(
              // folderPath: '$courseName - ${currentUser.value?.displayName} - $courseId/',
              folderPath: FireConstant.getCourseVideosFolderPath(
                courseName: courseName,
                userName: currentUser.value?.displayName,
                courseId: courseId ?? '',
              ),
              fileName: lessonId,
              isFileNamePartOfOriginFileName: true,
              deleteAllMatches: true,
            );

            if (result) {
              await LessonModel.deleteLesson(
                courseId: courseId ?? '',
                lessonId: lessonId,
              );
              // -- remove the lesson from the displayed data
              courseLessons.removeWhere((element) => element.docId == lessonId);
            }
          },
          loadingWidget: AppHelper.custumProgressIndecator(size: 50),
        );
        AppHelper.showToastSnackBar(message: 'Deleted successfully', isSuccess: true);
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> sendNotificationToCourseLearners(String title, String? body) async {
    Logger.log('::::::::: title: $title, body: $body');
    if (courseId != null) {
      // -- save the notification data on firebasefirestore
      final notification = NotificationModel(
        senderId: currentUser.value?.uid ?? '',
        recieversIds: ['$courseId-token'],
        showToUsers: courseApplicants.map((element) => element.studentId).toList()..insert(0, currentUser.value?.uid ?? ''),
        senderName: currentUser.value?.displayName ?? '',
        title: title,
        body: body ?? '',
        createdAt: DateTime.now(),
      );
      notification.saveNotificationData();

      // -- send the notification for the course learners
      FireNotificationService.instance.sendNotificationToTopic(topic: courseId!, title: title, body: body);
    }
  }





  // -- Add Lesson Functions
  void goToAddLessonPage() {
    lessonTitleCon.text = '';
    lessonDescriptionCon.text = '';
    lessonOrderNumCon.text = (courseLessons.length + 1).toString();
    lessonType.value = null;
    videoPath.value = '';
    questionCon.text = '';
    answerControllers.clear();
    correctAnswerIndex.value = 0;
    answerControllers.addAll([TextEditingController(), TextEditingController()]);
    quizQuestions.value = [
      QuizQuestionModel(
        questionNumber: 1,
        question: '',
        answers: ['', ''],
        correctAnswer: '0',
        questionDegree: 1,
      ),
    ];

    Get.to(() => TaAddLessonScreen(
          courseDocId: courseId ?? '',
          // lessonsCount: courseLessons.length,
        ));
  }

  void searchForFailUploadLesson() {
    failUploadingLessonId.value = PrefHelper.getFailUploadingLessonId() ?? '';
    Logger.log('::::::::: Fail  uploading lesson id: $failUploadingLessonId');

    if (failUploadingLessonId.value.isNotEmpty) {
      videoPath.value = PrefHelper.getFailVideoPath() ?? '';
    }
  }

  void cancelFailUploadLesson() {
    PrefHelper.setFailUploadingLessonId(null);
    PrefHelper.setFailVideoPath(null);

    failUploadingLessonId.value = '';
    videoPath.value = '';
  }

  void uploadLessonVideo(String lessonId) async {
    if (uploadingLessonId.value.isNotEmpty){
      AppHelper.showToastSnackBar(message: 'There is another video being uploaded.');
      return;
    }
    
    if (videoPath.isEmpty){
      await pickVideo();
    }
    startUploadLessonVideo(lessonId);
  }

  /// function for upload the lesson data without the lesson video
  Future uploadNewQuizData(String courseDocId) async {
    if (!(globalLessonFormKey.currentState?.validate() ?? false)) return false;
    if (!(quizFormKey.currentState?.validate() ?? false)) return false;
    quizFormKey.currentState?.save();

    isLoading.value = true;
    Logger.log(quizQuestions);
     try {
      if (await NetworkInfo().isConnected) {
        final lesson = LessonModel(
          title: lessonTitleCon.text.trim(),
          description: lessonDescriptionCon.text.trim(),
          type: lessonType.value ?? LessonTypeEnum.lesson,
          lessonOrderNum: int.tryParse(lessonOrderNumCon.text) ?? 1,
          createdAt: DateTime.now(),
          quizQuestions: quizQuestions,
          quizFullGrade: quizQuestions.length.toDouble(),
          
        );

        final result = await FirebaseFirestore.instance.collection('courses')
          .doc(courseDocId).collection('lessons').add(lesson.toMap());

        // -- close add lesson screen
        Get.back(closeOverlays: true, result: result.id);

        
        AppHelper.showToastSnackBar(
          message: 'Quiz data has been uploaded successfully.',
          isSuccess: true
        );
        await refreshPage();

        Logger.log('Finish upload data.');
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } catch (e){
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }
  
  Future uploadNewLessonData(String courseDocId) async {
    if (!(globalLessonFormKey.currentState?.validate() ?? false)) return false;
    if (!(lessonFormKey.currentState?.validate() ?? false)) return false;

    isLoading.value = true;
    try {
      if (await NetworkInfo().isConnected) {
        final lesson = LessonModel(
          title: lessonTitleCon.text.trim(),
          description: lessonDescriptionCon.text.trim(),
          type: lessonType.value ?? LessonTypeEnum.lesson,
          lessonOrderNum: int.tryParse(lessonOrderNumCon.text) ?? 1,
          createdAt: DateTime.now(),
          question: questionCon.text.trim(),
          answers: List.generate(answerControllers.length,
              (index) => answerControllers[index].text.trim()),
          correctAnswer: answerControllers[correctAnswerIndex.value].text.trim(),
        );

        final result = await FirebaseFirestore.instance.collection('courses')
          .doc(courseDocId).collection('lessons').add(lesson.toMap());

        // -- close add lesson screen
        Get.back(closeOverlays: true, result: result.id);

        
        AppHelper.showToastSnackBar(
          message: 'Lesson data has been uploaded successfully.',
          isSuccess: true
        );
        await refreshPage();

        Logger.log('Finish ypload data, next upload video');
        await startUploadLessonVideo(result.id);
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } catch (e){
      Logger.log(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }

  Future<void> startUploadLessonVideo(String lessonId) async {
    try {
      // -- upload the video
      if (videoPath.isNotEmpty) {
        Logger.log('Start Upload Video');
        uploadingLessonId.value = lessonId;
        final result = await FireUploadFilesService.uploadVideo(
          videoPath.value,
          fileName: '${lessonTitleCon.text}-$lessonId',
          // folderPath: '$courseName - ${currentUser.value?.displayName} - $courseId/',
          folderPath: FireConstant.getCourseVideosFolderPath(
            courseName: courseName,
            userName: currentUser.value?.displayName,
            courseId: courseId ?? '',
          ),
          onProgress: (progress) {
            uploadProgressPercentage.value = progress;
          },
          onError: (error) {
            // AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
            uploadingLessonId.value = '';
          },
        );

        await FirebaseFirestore.instance.collection('courses').doc(courseId)
          .collection('lessons').doc(lessonId).update({'videoUrl': result});
        refreshPage();

        AppHelper.showToastSnackBar(message: 'Video uploaded successfully', isSuccess: true);
        uploadingLessonId.value = '';
        videoPath.value = '';
      }
    } catch (e){
      Logger.log(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      uploadingLessonId.value = '';
    }
  }

  Future<void> pickVideo() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) videoPath.value = video.path;
  }
}