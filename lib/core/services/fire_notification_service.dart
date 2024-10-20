import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

import 'local_notification_service.dart';
import 'server_key_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log(':::: Handling a background message ${message.messageId}');
  LocalNotificationService.instance.showFirebaseNotification(message);
}


class FireNotificationService {
  final _localNotificationService = LocalNotificationService.instance;
  final _fireMessagging = FirebaseMessaging.instance;

  // Getter to provide access to the single instance of the class
  static FireNotificationService instance =
      FireNotificationService._internal();

  FireNotificationService._internal();
  
  Future<void> initialize() async {
    Logger.log("::::::: Initilaize App Notification");
    // Request permissions
    await _fireMessagging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    updateUserTokenWhenRefresh();
    
   

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!: ${message.notification}');

      if (message.notification != null) {
        log('Notification Title: ${message.notification!.title}');
        log('Notification Body: ${message.notification!.body}');

        _localNotificationService.showFirebaseNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      log(';;;;;;;;;;;;;;;;;;;;;;;;;; Open App From Notification');
      final conversationId = message.data['conversationId'];
      final isFromRoom = message.data['isFromRoom'] == 'true';
      final userOrActivityId = int.tryParse(message.data['userOrActivityId'] ?? '') ?? 0;

      log(' ========= onMessageOpenedApp: $conversationId - $isFromRoom - $userOrActivityId');
    });
  }

  void updateUserTokenWhenRefresh () {
    _fireMessagging.onTokenRefresh.listen((newToken) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        FirebaseFirestore.instance.collection('users')
            .doc(uid).update({'deviceToken': newToken});

        Logger.log(":::::: Refresh ans Store new Device Token");
      }
    });
  }

  void subscribeToTopicNotification(String topic) {
    log('::::::::::::::::::::: Subscribe To $topic');
    _fireMessagging.subscribeToTopic(topic);
  }

  void unsubscribeToTopicNotification(String topic) {
    _fireMessagging.unsubscribeFromTopic(topic);
  }

  Future<void> sendNotificationToToken({
    required String token, 
    String? title, 
    String? body,
  }) async {
    final notification = {
      'token': token,
      'notification': {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      },
    };
    await commonSendNotification({'message': notification});
  }

  Future<void> sendNotificationToTopic({
    required String topic, 
    required String title, 
    String? body,
  }) async {
    final notification = {
      'topic': topic,
      'notification': {
        'title': title,
        if (body != null) 'body': body,
      },
    };
    await commonSendNotification({'message': notification});
  }

  Future<void> commonSendNotification(Map<String, dynamic> message) async {
    try {
      const postUrl = 'https://fcm.googleapis.com/v1/projects/e-trainig-mate/messages:send';
      final oAuthToken =  await ServerKeyService.getServerKeyToken();

        if (oAuthToken != null) {
        final headers = {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $oAuthToken',
        };

        final response = await http.post(
          Uri.parse(postUrl),
          headers: headers,
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          log('Notification sent to Token');
        } else {
          log('Failed to send notification: ${response.statusCode} ${response.body}');
        }
      }
    } catch (e) {
      log('Error sending notification: $e');
    }
  }

  static Future<String?> getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    Logger.log(":::::: Get Device Token: $token");
    return token;
  }
}