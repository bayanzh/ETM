import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/ta_models/bottom_item_model.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_trainers_learners/screens/ta_trainers_learners_screen.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/image_constant.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/network_info.dart';
import '../../../notifications/screens/notifications_screen.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../authentication/screens/profile_screen.dart';
import '../screens/ta_home_screen.dart';

class TaMainController extends GetxController {
  final RxBool isLoading = false.obs;
  
  late Rx<User?> currentUser;
  Rx<UserModel?> currentUserInfo = Rx(null);
  Rx<UserTypeEnum?> userType = Rx(PrefHelper.getUserType());

  RxInt currentIndex = 0.obs;
  late PageController pageController;
  late RxList<Widget> pages;
  late RxList<BottomItemModel> bottomItems;
  
  @override
  void onInit() {
    super.onInit();

    currentUser = Rx(FirebaseAuth.instance.currentUser);

    pageController = PageController(initialPage: currentIndex.value);

    bottomItems = [
       BottomItemModel(icon: ImageConstant.homeIcon, name: 'Home'),
       if (userType.value == UserTypeEnum.admin)
        BottomItemModel(name: 'Users', icon: ImageConstant.usersIcon),
       BottomItemModel(icon: ImageConstant.notificationIcon, name: 'Notification'),
       BottomItemModel(icon: ImageConstant.profileIcon, name: 'Profile'),
    ].obs;

    pages = [
      const TaHomeScreen(),
      if (userType.value == UserTypeEnum.admin)
        const TaTrainersLearnersScreen(),
      const NotificationsScreen(),
      ProfileScreen(isEditProfile: true),
    ].obs;

    
    listenToCurrentUserInfo();

    // -- listen to user data changes
    FirebaseAuth.instance
        .userChanges()
        .listen((event) => currentUser.value = event);
  }

  Future<void> getCurrentUserInfo() async {
    isLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      currentUserInfo.value = await UserModel.getUserInfoById(currentUser.value!.uid);
      userType.value = currentUserInfo.value?.type;
      PrefHelper.setUserType(currentUserInfo.value?.type);
      Logger.log(':::::::::: USer Type: ${userType.value}');
    } catch (e){
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }
  
  Future<void> listenToCurrentUserInfo() async {
    isLoading.value = true;
    bool isFirstTime = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      UserModel.listenToUserInfoById(
        uid: currentUser.value!.uid,
        onData: (data) {
          currentUserInfo.value = data;
          userType.value = currentUserInfo.value?.type;
          PrefHelper.setUserType(currentUserInfo.value?.type);
          Logger.log(':::::::::: User Type: ${userType.value}');
          
          if (isFirstTime){
            setBottomBar();
            Logger.log('::::::::::::: Set BottomBar');
            isFirstTime = false;
          }
          isLoading.value = false;
        },
      );      
    } catch (e){
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }

  void setBottomBar() {
    if (currentUserInfo.value?.type == UserTypeEnum.admin && pages.length == 3) {
      pages.insert(1, const TaTrainersLearnersScreen());
      bottomItems.insert(1, BottomItemModel(name: 'Users', icon: ImageConstant.usersIcon));
    } else if (currentUserInfo.value?.type == UserTypeEnum.trainer && pages.length == 4) {
      pages.removeAt(1);
      bottomItems.removeAt(1);
    }
  }
}