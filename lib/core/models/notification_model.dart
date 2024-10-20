import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationModel {
  String? docId;
  String senderId;
  List<String> recieversIds;
  List<String> showToUsers;
  String senderName;
  String title;
  String body;
  DateTime createdAt;
  
  NotificationModel({
    this.docId,
    required this.senderId,
    required this.recieversIds,
    required this.showToUsers,
    required this.senderName,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? docId,
    String? senderId,
    List<String>? recieversIds,
    List<String>? showToUsers,
    String? senderName,
    String? title,
    String? body,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      docId: docId ?? this.docId,
      senderId: senderId ?? this.senderId,
      recieversIds: recieversIds ?? this.recieversIds,
      showToUsers: showToUsers ?? this.showToUsers,
      senderName: senderName ?? this.senderName,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieversIds': recieversIds,
      'showToUsers': showToUsers,
      'senderName': senderName,
      'title': title,
      'body': body,
      'createdAt': createdAt,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      senderId: map['senderId'] ?? '',
      recieversIds: map['recieversIds']?.cast<String>() ?? [],
      showToUsers: map['showToUsers']?.cast<String>() ?? [],
      senderName: map['senderName'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) => NotificationModel.fromMap(json.decode(source));

  @override
  String toString() => 'NotificationModel(docId: $docId, senderId: $senderId, recieversIds: $recieversIds senderName: $senderName, title: $title, body: $body)';


  Future<String> saveNotificationData() async {
    final resultDoc = await FirebaseFirestore.instance.collection('notifications')
      .add(toMap());
    return resultDoc.id;
  }


  static Future<List<NotificationModel>> getCurrentUserNotifications() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    List<NotificationModel> notificationsList = [];

    final snapshot = await FirebaseFirestore.instance.collection('notifications')
      .where('showToUsers', arrayContains: uid)
      .get();

    for (var doc in snapshot.docs) {
      final notification = NotificationModel.fromMap(doc.data());
      notification.docId = doc.id;
      notificationsList.add(notification);
    }
    return notificationsList;
  }
  
  
  static void listenToCurrentUserNotifications({
    void Function(List<NotificationModel> notifications)? onDate,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final snapshot = FirebaseFirestore.instance.collection('notifications')
      .where('showToUsers', arrayContains: uid)
      .snapshots();

    snapshot.listen((event) {
      List<NotificationModel> notificationsList = [];
      for (var doc in event.docs) {
        final notification = NotificationModel.fromMap(doc.data());
        notification.docId = doc.id;
        notificationsList.add(notification);
      }

      onDate?.call(notificationsList);
    });
    
  }

 
}
