import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/notification_model.dart';
import 'package:e_training_mate/core/services/network_info.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/logger.dart';

class NotificationsController extends GetxController {
  final RxBool isLoading = false.obs;
  RxList<NotificationModel> userNotifications = <NotificationModel>[].obs;


  @override
  void onInit() {
    super.onInit();
    listenToUserNotifications();
  }

  Future<void> listenToUserNotifications() async {
    isLoading.value = true;

    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      NotificationModel.listenToCurrentUserNotifications(onDate: (notifications) {
        userNotifications.clear();
        userNotifications.addAll(notifications);
        isLoading.value = false;
      });      
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
  }
}