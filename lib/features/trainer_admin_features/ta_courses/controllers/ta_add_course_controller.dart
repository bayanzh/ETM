import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/constant/fire_constant.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/core/services/fire_upload_files_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/category_model.dart';
import '../../../../core/services/network_info.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/utils/logger.dart';

class TaAddCourseController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool categoriesLoading = false.obs;

  late Rx<User?> currentUser;

  final formKey = GlobalKey<FormState>();
  final nameCon = TextEditingController();
  final descriptionCon = TextEditingController();
  final Rx<String?> selectedCategory = Rx(null);
  final RxString iconPath = ''.obs;

  
  RxList<CategoryModel> categories = <CategoryModel>[].obs;
  RxList<LessonModel> courseLessons = <LessonModel>[].obs;

  String? courseId;

   @override
  void onInit() {
    super.onInit();
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    refreshPage();

    // -- listen to user data changes
  }

  @override
  void onClose() {
    descriptionCon.dispose();
    nameCon.dispose();
    

    super.onClose();
  }

  Future<void> refreshPage() async {


    getCategories();
  }

  Future<void> getCategories() async {
    try {
      categoriesLoading.value = true;
      categories.clear();
      categories.addAll(await CategoryModel.getCategories());
      categoriesLoading.value = false;
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) iconPath.value = image.path;
  }

  Future submitSaveButton() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isLoading.value = true;
    try {
      if (await NetworkInfo().isConnected) {
        final course = CourseModel(
          name: nameCon.text.trim(),
          description: descriptionCon.text.trim(),
          trainerId: currentUser.value!.uid,
          createdAt: DateTime.now(),
          registrationsCount: 0,
          applicantsCount: 0,
          category: categories.firstWhere((element) => element.docId == selectedCategory.value),
        );

        // -- upload the course icon if availabe
        if (iconPath.isNotEmpty) {
          course.iconUrl = await FireUploadFilesService.uploadImage(
            iconPath.value,
            folderPath: FireConstant.courseIconsFolderPath,
            fileName: nameCon.text,
          );

          if (course.iconUrl?.isEmpty ?? false) {
            AppHelper.showToastSnackBar(message: 'We could not load the course icon, please try again after uploading the course data');
          }
        }

        await FirebaseFirestore.instance.collection('courses').add(course.toMap());
        Get.back(closeOverlays: true);
        AppHelper.showToastSnackBar(
          message: 'Course data has been uploaded successfully.',
          isSuccess: true
        );
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } catch (e){
      Logger.log(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = true;
  }
}