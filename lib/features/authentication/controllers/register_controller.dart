import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/services/fire_notification_service.dart';
import 'package:e_training_mate/features/authentication/screens/verify_email_screen.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/network_info.dart';
import '../../../core/utils/logger.dart';

class RegisterController extends GetxController{
  final RxBool isLoading = false.obs;

  final registerFormKey = GlobalKey<FormState>();
  final idFormKey = GlobalKey<FormState>();

  RxBool isRegisterFieldsFill = false.obs;
  RxBool isIdFieldsFill = false.obs;

  final emailCon = TextEditingController();
  final nameCon = TextEditingController();
  final passwordCon = TextEditingController();
  final confirmPasswordCon = TextEditingController();

  final idCon = TextEditingController();
  final idPasswordCon = TextEditingController();
  
  RxBool checkProviderAccount = false.obs;
  RxBool securePassword = true.obs;
  RxBool securePasswordId = true.obs;


  @override
  void onInit() {
    super.onInit();
    
    emailCon.addListener(_checkFieldsFill);
    nameCon.addListener(_checkFieldsFill);
    passwordCon.addListener(_checkFieldsFill);
    confirmPasswordCon.addListener(_checkFieldsFill);
    
    idCon.addListener(_checkFieldsFill);
    idPasswordCon.addListener(_checkFieldsFill);

  
  }

  @override
  void onClose() {
    emailCon.dispose();
    nameCon.dispose();
    passwordCon.dispose();
    confirmPasswordCon.dispose();
    idCon.dispose();
    idPasswordCon.dispose();
    super.onClose();
  }

  // Update the validation of fill fields status
  void _checkFieldsFill() {
    isRegisterFieldsFill.value = emailCon.text.isNotEmpty &&
        nameCon.text.isNotEmpty &&
        passwordCon.text.isNotEmpty &&
        confirmPasswordCon.text.isNotEmpty;

    isIdFieldsFill.value =
        idCon.text.isNotEmpty && idPasswordCon.text.isNotEmpty;
  }

  void changPasswordVisible() {
    securePassword.value = !securePassword.value;
  }
  
  void changPasswordIdVisible() {
    securePasswordId.value = !securePasswordId.value;
  }


  Future<void> submitRegisterSignUpButton () async {
    if (!(registerFormKey.currentState?.validate() ?? false)) return;

    final isTrainer = PrefHelper.getUserType() == UserTypeEnum.trainer;

    if (isTrainer && !checkProviderAccount.value) {
      AppHelper.showToastSnackBar(message: 'You must confirm the creation of a service provider account.');
      return;
    }

    isLoading.value = true;

    String? uid;
    if (isTrainer) {
      uid = await registerStudent(UserModel(
        name: nameCon.text.trim(),
        email: emailCon.text.trim(),
        password: passwordCon.text,
        accountStatus: UserAccountStatusEnum.waiting,
    
        type: UserTypeEnum.trainer,
        deviceToken: await FireNotificationService.getToken() ?? '',
      ));

      if (uid != null) {
        // -- Send a notification to the admin to notify of a new user in the application
        FireNotificationService.instance.sendNotificationToTopic(
          topic: 'adminTopic',
          title: 'مدرب جديد',
          body: 'المدرب ${nameCon.text.trim()} سجل في التطبيق',
        );
      }
    } else {
      uid = await registerStudent(UserModel(
        name: nameCon.text.trim(),
        email: emailCon.text.trim(),
        password: passwordCon.text,
        accountStatus: UserAccountStatusEnum.accepted,
    
        type: UserTypeEnum.learner,
        deviceToken: await FireNotificationService.getToken() ?? '',
      ));

      if (uid != null) {
        // -- Send a notification to the admin to notify of a new user in the application
        FireNotificationService.instance.sendNotificationToTopic(
          topic: 'adminTopic',
          title: 'متدرب جديد',
          body: 'المتدرب ${nameCon.text.trim()} سجل في التطبيق',
        );
      }
    }

    if (uid != null) {
   
      Get.offAll(() => const VerifyEmailScreen());
    }
    isLoading.value = false;
  }



  Future<String?> registerStudent(UserModel user) async {
    try {
      if (await NetworkInfo().isConnected) {
        // 1. Create the user using FirebaseAuth
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: user.password ?? "123456", // Default password if not provided
        );

        // 2. Update the user's display name in FirebaseAuth
        await credential.user!.updateDisplayName(user.name);

        // 3. Run a transaction to store additional student information in Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.runTransaction((transaction) async {
          Logger.log(":::::::::: Start TRansaction");
          // 4. Define the document reference where student data will be stored
          DocumentReference studentDocRef = firestore.collection('users').doc(credential.user!.uid);

          // 5. Store student data in Firestore within the transaction
          transaction.set(studentDocRef, user.additinalInfoMap());
          Logger.log(":::::::::: End TRansaction");
        }).then((_) {
          Logger.log("::::: Success: Created Student Credential and Stored Data in Firestore");
        }).catchError((error) async {
          // If storing data in Firestore fails, delete the created user account
          await credential.user!.delete();
          Logger.logError("Transaction failed: $error. User account deleted.");
          throw Exception("Failed to store student data. Account creation has been rolled back.");
        });

        // 6. Return the user's UID if everything is successful
        return credential.user!.uid;
      } else {
        // Show a message if there is no internet connection
        AppHelper.showToastSnackBar(message: "You have not internet");
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth-specific errors
      Logger.logError('Code: ${e.code} -- messgae: ${e.message}');
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      // Handle any other unexpected errors
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error! Please try again.", isError: true);
    }

    // Return null if the process failed
    return null;
  }
}