import 'package:e_training_mate/common/enums/user_status_enum.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../core/models/notification_model.dart';
import '../../../../core/services/network_info.dart';
import '../../../../core/services/fire_notification_service.dart';
import '../../../../core/utils/helpers/app_helper.dart';
import '../../../../core/utils/logger.dart';

class TaTrainersLearnersController extends GetxController {
  RxBool isLoading = false.obs;
  List<UserModel> allUsers = <UserModel>[].obs;
  RxList<UserModel> trainerUsers = <UserModel>[].obs;
  RxList<UserModel> learnerUsers = <UserModel>[].obs;

  RxBool isDisplayLearnersActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
  }

  Future<void> getAllUsers() async {
    isLoading.value = true;
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      allUsers.clear();

      UserModel.listenToAllUsers(onData: (users) {
        allUsers.clear();
        allUsers.addAll(users);

        allUsers.sort((a, b) {
          // إنشاء خريطة تمثل ترتيب الحالات
          final statusOrder = {
            UserAccountStatusEnum.waiting: 0,  // "المنتظر" في المقدمة
            UserAccountStatusEnum.suspend: 1, // "الموقوف" في المنتصف
            UserAccountStatusEnum.accepted: 2  // "المقبول" في النهاية
          };

          // مقارنة المستخدمين بناءً على الترتيب المحدد
          return statusOrder[a.accountStatus]!.compareTo(statusOrder[b.accountStatus]!);
        });

        filterUsers();
      });

     
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    isLoading.value = false;
  }

  Future<void> changeUserAccountStatus({
    required UserModel user,
    required UserAccountStatusEnum status,
  }) async {
    try {
      NetworkInfo().isConnected.then((value) {
        if (!value) AppHelper.showToastSnackBar(message: "You have not internet");
      });

      await UserModel.changeUserAccountStatus(userId: user.uid ?? '', status: status);

      if (status == UserAccountStatusEnum.accepted) {
        FireNotificationService.instance.sendNotificationToToken(
          token: user.deviceToken,
          // title: 'Your Account Has Been Accepted',
          // body: 'Your account has been accepted as a trainer on the platform. You can now access all available features!',
          title: 'قبول حسابك في المنصة',
          body: 'تم قبول حسابك كمدرب على المنصة. يمكنك الآن الوصول إلى جميع المميزات المتاحة!',
        );

        final notification = NotificationModel(
          senderId: FirebaseAuth.instance.currentUser?.uid ?? '',
          recieversIds: [user.uid ?? ''],
          showToUsers: [user.uid ?? ''],
          senderName: FirebaseAuth.instance.currentUser?.displayName ?? '',
          title: 'قبول حسابك في المنصة',
          body: 'تم قبول حسابك كمدرب على المنصة. يمكنك الآن الوصول إلى جميع المميزات المتاحة!',
          createdAt: DateTime.now(),
        );
        notification.saveNotificationData();
      } else if (status == UserAccountStatusEnum.suspend) {
        FireNotificationService.instance.sendNotificationToToken(
          token: user.deviceToken,
          // title: 'Your Account Has Been Suspended',
          // body: 'Your account has been temporarily suspended. Please contact support for further information.',
          title: 'تم إيقاف حسابك',
          body: 'لقد تم إيقاف حسابك مؤقتًا. يرجى التواصل مع الدعم للحصول على مزيد من المعلومات.',
        );

        final notification = NotificationModel(
          senderId: FirebaseAuth.instance.currentUser?.uid ?? '',
          recieversIds: [user.uid ?? ''],
          showToUsers: [user.uid ?? ''],
          senderName: FirebaseAuth.instance.currentUser?.displayName ?? '',
          title: 'تم إيقاف حسابك',
          body: 'لقد تم إيقاف حسابك مؤقتًا. يرجى التواصل مع الدعم للحصول على مزيد من المعلومات.',
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

  void filterUsers() {
    List<UserModel> tempTrainers = [];
    List<UserModel> tempLearners = [];
    for (var user in allUsers) {
      if (user.type == UserTypeEnum.trainer) {
        tempTrainers.add(user);
      } else if (user.type == UserTypeEnum.learner) {
        tempLearners.add(user);
      }
    }

    trainerUsers.clear();
    trainerUsers.addAll(tempTrainers);
    learnerUsers.clear();
    learnerUsers.addAll(tempLearners);
  }

  int getWaitingAccountCount(List<UserModel> users) {
    final count = users.where(
          (element) => element.accountStatus == UserAccountStatusEnum.waiting,
        ).length;
    
    Logger.log('::::::::::::: Counts waitings: $count');
    return count;
  }
  
  int getSuspendAccountCount(List<UserModel> users) {
    final count = users.where(
          (element) => element.accountStatus == UserAccountStatusEnum.suspend,
        ).length;
    
    Logger.log('::::::::::::: Counts waitings: $count');
    return count;
  }
}