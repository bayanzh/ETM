import 'package:e_training_mate/features/notifications/widgets/notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/helpers/app_helper.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  NotificationsController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
   
    
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Notifications'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          forceMaterialTransparency: true,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 50),
              child: AppHelper.custumProgressIndecator(),
            );
          } else if (controller.userNotifications.isEmpty) {
            return Container(
              padding: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Text('No data found'.tr),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: controller.userNotifications.length,
            itemBuilder: (context, index) {
              return NotificationWidget(
                notification: controller.userNotifications[index],
              );
            },
          );
        }
    ));
  }
}