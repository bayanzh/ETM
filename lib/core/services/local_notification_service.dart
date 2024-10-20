import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotificationService {
  late FlutterLocalNotificationsPlugin localNotifiPlugin;
  late String channelId;
  late String channelName;
  late String channelDescription;

  // Getter to provide access to the single instance of the class
  static LocalNotificationService instance =
      LocalNotificationService._internal();

  LocalNotificationService._internal() {
    localNotifiPlugin = FlutterLocalNotificationsPlugin();

    // -- To requesting permissions on Android 13 or higher
    localNotifiPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    initialize();
  }

  /// initialize the service. call this function just once in your app
  Future<void> initialize({
    String notifiChannelId = "ETM notification",
    String notifiChannelName = "ETM Notification Channel",
    String notifiChannelDesc =
        'This channel is used for important notifications.',
    String? notifiIcon,
  }) async {
    print("::::::::::::::::::::: initialize Local Notification Service");
    channelId = notifiChannelId;
    channelName = notifiChannelName;
    channelDescription = notifiChannelDesc;

    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(notifiIcon ?? '@mipmap/ic_launcher');
    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await localNotifiPlugin.initialize(initializationSettings);
  }

  NotificationDetails get _getNotifiDetails {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        enableVibration: true,
        playSound: true,
        // if true the user can't delete the notification unless click on it
        ongoing: false,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  void cancelSpecificNotification(int notificationId) async {
    await localNotifiPlugin.cancel(notificationId);
  }

  /// function to show notification in current time
  /// you must call initialize function before this function
  void showLocalNotification({
    required int uniqueId,
    String? title = "Notification Title",
    String? body = "Notification Body",
  }) {
    print("::::::::::::::::::::: show Local Notification");
    localNotifiPlugin.show(
      uniqueId,
      title,
      body,
      _getNotifiDetails,
    );
  }
  
  /// function to show notification from RemoteMessage in current time
  /// you must call initialize function before this function
  void showFirebaseNotification(RemoteMessage message) {
    print("::::::::::::::::::::: show Local Notification");
    final title = message.notification!.title;
    final body = message.notification!.body;
    // use hashCode if messageId is available, otherwis use time as id
    final notificationUniqId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch;

    showLocalNotification(
      uniqueId: notificationUniqId,
      title: title,
      body: body,
    );
  }
}
