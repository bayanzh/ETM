import 'package:e_training_mate/core/models/category_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/filter_buttons_widget.dart';
import '../../../core/models/course_model.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/logger.dart';

class ExploreController extends GetxController {
  final RxBool recentlyCoursesLoading = false.obs;
  final RxBool categoriesLoading = false.obs;
  final RxBool popularCoursesLoading = false.obs;

  late Rx<User?> currentUser;

  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<CourseModel> recentlyAddedCourses = <CourseModel>[].obs;
  RxList<CourseModel> popularCourses = <CourseModel>[].obs;
  RxList<CourseModel> resultSearchCourses = <CourseModel>[].obs;

  Rx<String> selectedCategory = Rx('0');

  FocusNode searchFocusNode = FocusNode();
  RxBool isSearching = false.obs;
  final searchCon = TextEditingController();
  RxString searchText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    refreshPage();

    searchFocusNode.addListener(() {
      isSearching.value = searchFocusNode.hasFocus;
      Logger.log(":::::::: Form search focus: ${isSearching.value}");
    });

    // -- listen to user data changes
    FirebaseAuth.instance.userChanges().listen((event) => currentUser.value = event);
  }

  @override
  void onClose() {
    searchCon.dispose();
    super.onClose();
  }

  Future<void> refreshPage() async {
    categoriesLoading.value = true;
    recentlyCoursesLoading.value = true;
    popularCoursesLoading.value = true;
    await getCategories();
    await getRecentlyAddedCourses();
    listenPopularCourses();
  }

  void changeCategory(FilterButtonModel  button) {
    selectedCategory.value = button.value;
    getRecentlyAddedCourses();
    listenPopularCourses();
  }

  Future<void> searchForCourses() async {
    if (searchCon.text.isEmpty) return;

    try {
      recentlyCoursesLoading.value = true;
      final results = await CourseModel.searchCoursesByNameOrDescription(
        query: searchCon.text,
        categoryId: selectedCategory.value,
      );
      resultSearchCourses.clear();
      resultSearchCourses.addAll(results);
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      if (!Get.isSnackbarOpen) {
        Logger.log('true');
        AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
      }
    } catch (e) {
      Logger.logError(e);
      if (!Get.isSnackbarOpen) {
        AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      }
    }
    recentlyCoursesLoading.value = false;
  }


  Future<void> getCategories() async {
    try {
      categoriesLoading.value = true;
      categories.clear();
      categories.addAll(await CategoryModel.getCategories());
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      if (!Get.isSnackbarOpen) {
        Logger.log('true');
        AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
      }
    } catch (e) {
      Logger.logError(e);
      if (!Get.isSnackbarOpen) {
        AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      }
    }
    categoriesLoading.value = false;
  }

  Future<void> getRecentlyAddedCourses() async {
    try {
      recentlyCoursesLoading.value = true;
      recentlyAddedCourses.clear();
      recentlyAddedCourses.addAll(await CourseModel.getCourses(
        limit: 5,
        orderByField: 'createdAt',
        descending: true,
        equalConditions: selectedCategory.value != '0'
            ? {'categoryId': selectedCategory.value}
            : null,
        fetchCourseTrainer: true,
      ));
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      if (!Get.isSnackbarOpen) {
        Logger.log('truetrue');
        AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
      }
    } catch (e) {
      Logger.logError(e);
      if (!Get.isSnackbarOpen) {
        Logger.log('true');
        AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      }
    }
     recentlyCoursesLoading.value = false;
  }
  
  void listenPopularCourses() {
    try {
      popularCoursesLoading.value = true;
      CourseModel.listenToCourses(
        limit: 5,
        orderByField: 'registrationsCount',
        descending: true,
        fetchCourseTrainer: true,
        equalConditions: selectedCategory.value != '0'
            ? {'categoryId': selectedCategory.value}
            : null,
        onData: (courses) {
          popularCourses.value = courses;
          popularCoursesLoading.value = false;
        },
        onError: (error) {
          if (!Get.isSnackbarOpen) {
            AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
          }
          popularCoursesLoading.value = false;
        },
      );
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      if (!Get.isSnackbarOpen) {
        Logger.log('true');
        AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
      }
    } catch (e) {
      Logger.logError(e);
      if (!Get.isSnackbarOpen) {
        Logger.log('true');
        AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      }
    }
  }
}