
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/constant/fire_constant.dart';
import 'package:e_training_mate/core/services/fire_upload_files_service.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/services/network_info.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/check_password_widget.dart';

class ProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  late Rx<User?> currentUser;
  Rx<UserModel?> student = Rx(null);

  RxString photoPath = "".obs;

  final formKey = GlobalKey<FormState>();

  final nameCon = TextEditingController();
  final emailCon = TextEditingController();
  final ageCon = TextEditingController();
  final Rx<String?> gender = Rx(null);

  RxBool isFieldsFill = false.obs;

  /// -- we need the password for the user when change the email
  String? userPassword;

  @override
  void onInit() {
    super.onInit();

    nameCon.addListener(checkFieldsFill);
    emailCon.addListener(checkFieldsFill);
    ageCon.addListener(checkFieldsFill);
    gender.listenAndPump((event) => checkFieldsFill());
    photoPath.listenAndPump((event) => checkFieldsFill());

    
    currentUser = Rx(FirebaseAuth.instance.currentUser);
    // -- listen to user data changes
    FirebaseAuth.instance.userChanges().listen((event) => currentUser.value = event);


    emailCon.text = currentUser.value?.email ?? '';
    nameCon.text = currentUser.value?.displayName ?? '';
    photoPath.value = currentUser.value?.photoURL ?? '';
    Logger.log(photoPath.value);

    
    getStudentInfo();
  }

  @override
  void onClose() {
    emailCon.dispose();
    nameCon.dispose();
    super.onClose();
  }

  
  // Update the validation of fill fields status
  void checkFieldsFill() {
    Logger.log("status: ${student.value?.name}");
    isFieldsFill.value = emailCon.text.isNotEmpty &&
        nameCon.text.isNotEmpty &&
        (ageCon.text.trim() != student.value?.age.toString() ||
        nameCon.text.trim() != student.value?.name ||
        emailCon.text.trim() != student.value?.email ||
        (gender.value != null && gender.value != student.value?.gender) ||
        (photoPath.value != (student.value?.photoUrl ?? '')));
  }

  Future<void> getStudentInfo() async {
    isLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      student.value = await UserModel.getUserInfoById(currentUser.value!.uid);
      if (student.value != null) {
        gender.value = student.value?.gender;
        ageCon.text = student.value?.age?.toString() ?? '';
      } else {
        AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
      }
    } catch (e){
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }

  Future<bool> submitSaveEditButton() async {
    if (!(formKey.currentState?.validate() ?? false)) return false;

    isLoading.value = true;
    try {
      if (await NetworkInfo().isConnected) {
        Map<String, dynamic> updatedData = {};

        if (emailCon.text.trim() != currentUser.value?.email) {
          final isSuccess = await updateUserEmail(emailCon.text.trim());
          if (!isSuccess) {
            isLoading.value = false;
            return false;
          }
          isFieldsFill.value  = false;

        }

        // -- add or change photo
        if (photoPath.value.isNotEmpty && photoPath.value != student.value?.photoUrl){
          String downloadUrl = await FireUploadFilesService.uploadImage(
            photoPath.value,
            folderPath: FireConstant.profilePhotoFolderPath
          );
          
          // update photoURL for student in Firebase Authentication
          await currentUser.value!.updatePhotoURL(downloadUrl);

          // save the photo url to Firestore
          updatedData['photoUrl'] = downloadUrl;
        }

        // -- delete the photo
        if (photoPath.value.isEmpty && (student.value?.photoUrl?.isNotEmpty ?? false)){
          // delete photoURL for student in Firebase Authentication
          await currentUser.value!.updatePhotoURL(null);

          // delete the photo url from Firestore
          updatedData['photoUrl'] = null;
        }

        if (nameCon.text.trim() != student.value?.name) {
          await currentUser.value?.updateDisplayName(nameCon.text.trim());
          updatedData['name'] = nameCon.text.trim();
        }
        
        if (gender.value != student.value?.gender) {
          updatedData['gender'] = gender.value;
        }

        if (ageCon.text.trim() != student.value?.age?.toString()){
          updatedData['age'] = ageCon.text.trim();
        }

        if (updatedData.isNotEmpty) {
          await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.value!.uid)
            .update(updatedData);
        
          AppHelper.showToastSnackBar(message: "The data has been modified successfully", isSuccess: true);
          student.value = student.value?.copyWithMap(updatedData);
          isFieldsFill.value = false;
        }

        isLoading.value = false;
        return true;
      } else {
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } on FirebaseException catch(e) {
      AppHelper.showToastSnackBar(message: e.message ?? '', isError: true);
    } catch (e){
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
    return false;
  }

  Future<bool> updateUserEmail(String newEmail) async {
    final isSuccessChecked = await getPasswordFromUser();
    Logger.log(':::::::::::: Result Check password: $isSuccessChecked');
    
    if (isSuccessChecked == true) {
      await currentUser.value?.verifyBeforeUpdateEmail(newEmail);
      DialogUtil.showResultDialog(
        title: 'Alert',
        message: 'We have sent a verification link to the new email to verify the email.\nOpen the link to change your account email',
      );

      return true;
      // - We will change the email stored in firestore when the app is opened the
      // second time if the user checks the new email
    }
    return false;
  }

  Future<bool?> getPasswordFromUser() async {
    return await Get.defaultDialog(
      title: "",
      content: CheckPasswordWidget(
        onCorrectCheck: (String password) {
          userPassword = password;
        },
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
    ).then((value) {
      Get.delete<CheckPasswordController>();
      return value;
    });
  }
}
