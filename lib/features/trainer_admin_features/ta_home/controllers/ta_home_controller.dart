import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../common/enums/user_type_enum.dart';
import '../../../../core/models/course_model.dart';
import '../../../../core/models/trainer_model.dart';
import '../../../../core/services/network_info.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/utils/logger.dart';
import 'ta_main_controller.dart';

class TaHomeController extends GetxController {
  TaMainController get mainController => Get.find();

  final RxBool activeCoursesLoading = false.obs;
  final RxBool trainerCoursesLoading = false.obs;

  // late Rx<User?> currentUser;
  late Rx<UserTypeEnum?> userType;

  RxList<CourseModel> mostActiveCourses = <CourseModel>[].obs;
  RxList<CourseModel> trainerCourses = <CourseModel>[].obs;

  // -- for trainer: represent the number of courses for the trainer
  // -- for admin: represent the number of all courses in the application
  Rx<int?> coursesCount = Rx(0);

  Rx<int?> applicantsCount = Rx(0);

  Rx<int?> trainersCount = Rx(null);
  Rx<int?> learnersCount = Rx(0);

  @override
  void onInit() {
    super.onInit();
   
    userType = Rx(PrefHelper.getUserType());

    refreshPage();

    if (userType.value == UserTypeEnum.admin) {
      CourseModel.listenToAllCourseCount(
          onData: (newCount) => coursesCount.value = newCount);

      UserModel.listenToTrainersCount(
          onData: (newCount) => trainersCount.value = newCount);
      
      UserModel.listenToLearnersCount(
          onData: (newCount) => learnersCount.value = newCount);
    }

  
  }

  Future<void> refreshPage() async {
    await getMostActiveCourses();

    if (userType.value == UserTypeEnum.trainer) {
      getApplicantsCount();
      getTrainerCourses();
    }
  }

  Future<void> getApplicantsCount() async {
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      if (userType.value != null) {
        final sumApplicants = await CourseModel.getTrainerCoursesApplicantsCount(
          trainerId: mainController.currentUser.value?.uid ?? '',
        );

        applicantsCount.value = sumApplicants?.toInt() ?? 0;
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
    // activeCoursesLoading.value = false;
  }

  // -- for trainer: Get the 2 most active trainer courses.
  //  for admin: Get the most active course out of all the courses in the app.
  Future<void> getMostActiveCourses() async {
    activeCoursesLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      if (userType.value != null) {
        mostActiveCourses.value = await CourseModel.getCourses(
          limit: userType.value == UserTypeEnum.trainer ? 2 : 1,
          orderByField: 'registrationsCount',
          descending: true,
          equalConditions: userType.value == UserTypeEnum.trainer
              ? {'trainerId': mainController.currentUser.value?.uid}
              : null,
        );
      }

      

      Logger.log(
          "::::: Success get most active courses data (length): ${mostActiveCourses.length}");
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
    activeCoursesLoading.value = false;
  }

  // -- Get all courses for the trainer
  Future<void> getTrainerCourses() async {
    trainerCoursesLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) {
          AppHelper.showToastSnackBar(message: "You have not internet");
        }
      });

      if (userType.value != null) {
        trainerCourses.value = await CourseModel.getCourses(
          orderByField: 'createdAt',
          descending: true,
          equalConditions: {'trainerId': mainController.currentUser.value?.uid},
        );
      }
      coursesCount.value = trainerCourses.length;

      Logger.log(
          "::::: Success get all trainer courses data (length): ${trainerCourses.length}");
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(
          message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(
          message: "Unexpected error!, try again.", isError: true);
    }
    trainerCoursesLoading.value = false;
  }
}
