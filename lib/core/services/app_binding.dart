import 'package:e_training_mate/features/authentication/controllers/register_controller.dart';
import 'package:e_training_mate/features/explore/controllers/explore_controller.dart';
import 'package:get/get.dart';

import '../../features/authentication/controllers/forget_password_controller.dart';
import '../../features/authentication/controllers/login_controller.dart';
import '../../features/authentication/controllers/profile_controller.dart';
import '../../features/authentication/controllers/verify_email_controller.dart';
import '../../features/notifications/controllers/notifications_controller.dart';
import '../../features/student_courses/controllers/quiz_controller.dart';
import '../../features/student_courses/controllers/student_courses_controller.dart';
import '../../features/student_courses/controllers/student_course_controller.dart';
import '../../features/explore/controllers/course_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/trainer_admin_features/ta_courses/controllers/ta_add_course_controller.dart';
import '../../features/trainer_admin_features/ta_courses/controllers/ta_course_details_controller.dart';
import '../../features/trainer_admin_features/ta_home/controllers/ta_home_controller.dart';
import '../../features/trainer_admin_features/ta_home/controllers/ta_main_controller.dart';
import '../../features/trainer_admin_features/ta_trainers_learners/controllers/ta_trainers_learners_controller.dart';
import '../../localization/app_locale_controller.dart';

class AppBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AppLocaleController(), fenix: true);
    Get.lazyPut(() => RegisterController(), fenix: true);
    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => VerifyEmailController(), fenix: true);
    Get.lazyPut(() => ForgetPasswordController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
    Get.lazyPut(() => StudentCoursesController(), fenix: true);
    Get.lazyPut(() => StudentCourseController(), fenix: true);
    Get.lazyPut(() => ExploreController(), fenix: true);
    Get.lazyPut(() => CourseController(), fenix: true);
    Get.lazyPut(() => QuizController(), fenix: true);

    // ======================== Trainer Admin Controllers Injections ======================
    Get.lazyPut(() => TaMainController(), fenix: true);
    Get.lazyPut(() => TaHomeController(), fenix: true);
    Get.lazyPut(() => TaCourseDetailsController(), fenix: true);
    Get.lazyPut(() => TaAddCourseController(), fenix: true);
    Get.lazyPut(() => TaTrainersLearnersController(), fenix: true);
    Get.lazyPut(() => NotificationsController(), fenix: true);
  }
}