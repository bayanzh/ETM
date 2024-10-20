import 'package:e_training_mate/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/services/network_info.dart';
import '../../../core/utils/logger.dart';
import '../../student_courses/models/student_course_model.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;

  late Rx<User?> currentUser;

  RxList<StudentCourseModel> recentlyViewedCourses = <StudentCourseModel>[].obs;
  // late StudentModel student;

  Rx<DateTime> selectedDay = Rx(DateTime.now());
  Rx<DateTime> focusedDay = Rx(DateTime.now());


  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    getRecentlyViewedCourses();

    // -- listen to user data changes
    FirebaseAuth.instance.userChanges().listen((event) => currentUser.value = event);
  }

  Future<void> getRecentlyViewedCourses() async {
    isLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      recentlyViewedCourses.value = await StudentCourseModel.getStudentCourses(
        limit: 4,
        orderBylastViewDate: true,
      );

      for (int i =0; i < recentlyViewedCourses.length; i++) {
        recentlyViewedCourses[i].course.trainer =
            await UserModel.getUserInfoById(recentlyViewedCourses[i].course.trainerId);
      }
    
      Logger.log("::::: Success get most acomplished courses data (length): ${recentlyViewedCourses.length}");
    } on FirebaseAuthException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }
}