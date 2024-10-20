import 'package:e_training_mate/core/models/notification_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

import '../../../core/constant/app_dark_colors.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key, required this.notification});
  
  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final isFromMe = FirebaseAuth.instance.currentUser?.uid == notification.senderId;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode
        ? AppDarkColors.container // const Color(0xff404040)
        : const Color(0xffCADDFF);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: isFromMe? containerColor.withOpacity(0.5) : containerColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xffEF69B1),
              child: Text(
                '${notification.senderName[0].toUpperCase()}.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
        
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isFromMe)
                          Text('You send'.tr, style: const TextStyle(fontStyle: FontStyle.italic)),
                        const Spacer(),
                        const SizedBox(width: 10),
                        Text(intl.DateFormat('d MMM').format(notification.createdAt)),
                        const SizedBox(width: 15),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(notification.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 5),
                     Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(notification.body, style: const TextStyle(fontSize: 14)),
                     ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}