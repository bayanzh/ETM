import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/services/fire_notification_service.dart';

import '../../common/enums/user_status_enum.dart';
import '../utils/helpers/app_helper.dart';
import '../utils/logger.dart';

class UserModel {
  String? uid;
  String name;
  String email;
  UserTypeEnum type;
  int? age;
  String? password;
  UserAccountStatusEnum accountStatus;
  String? photoUrl;
  String? gender;
  String deviceToken;

  UserModel({
    this.uid,
    required this.name,
    required this.email,
    required this.type,
    this.age,
    this.password,
    required this.accountStatus,
    this.photoUrl,
    this.gender,
    required this.deviceToken,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserTypeEnum? type,
    int? age,
    String? password,
    UserAccountStatusEnum? accountStatus,
    String? studentID,
    String? idPassword,
    String? photoUrl,
    String? gender,
    String? deviceToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      age: age ?? this.age,
      password: password ?? this.password,
      accountStatus: accountStatus ?? this.accountStatus,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
      deviceToken: deviceToken ?? this.deviceToken,
    );
  }

  UserModel copyWithMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? uid,
      name: map['name'] ?? name,
      email: map['email'] ?? email,
      type: map['type'] != null? UserTypeEnum.values.byName(map['type']) : type,
      age: int.tryParse(map['age'] ?? '') ?? age,
      password: map['password'] ?? password,
      accountStatus: map['accountStatus'] != null
          ? UserAccountStatusEnum.values.byName(map['accountStatus'])
          : accountStatus,
      photoUrl: map['photoUrl'] ?? photoUrl,
      gender: map['gender'] ?? gender,
      deviceToken: map['deviceToken'] ?? deviceToken,
    );
  }

  Map<String, dynamic> additinalInfoMap() {
    return {
      // -- Store the email in additional information in firestore
      // so you can check whether the email is registered in the app or not
      'email': email,
      'name': name,
      'type': type.name,
      'age': age,
      'accountStatus': accountStatus.name,
      'photoUrl': photoUrl,
      'gender': gender,
      'deviceToken': deviceToken,
    };
  }

  Map<String, dynamic> authInfoMap() {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'type': type.name,
      'age': age,
      'accountStatus': accountStatus,
      'photoUrl': photoUrl,
      'gender': gender,
      'deviceToken': deviceToken,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      type: UserTypeEnum.values.byName(map['type'] ?? 'learner'),
      accountStatus: UserAccountStatusEnum.values.byName(map['accountStatus'] ?? 'waiting'),
      age: int.tryParse(map['age'] ?? ''),
      password: map['password'],
      photoUrl: map['photoUrl'],
      gender: map['gender'],
      deviceToken: map['deviceToken'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'StudentModel(uid: $uid, name: $name, email: $email, type: $type password: $password, accountStatus: $accountStatus, gender: $gender, deviceToken: $deviceToken)';
  }


  Future<bool> updateUserToken() async {
    try {
      final deviceToken = await FireNotificationService.getToken();
      if (deviceToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid)
          .update({'deviceToken': deviceToken});
        Logger.log('::::::: Successful update deeviceToken to: $deviceToken');

        return true;
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
    } catch (e) {
      Logger.logError(e);
    }
    return false;
  }

  static Future<List<UserModel>> getAllUsers() async {
    List<UserModel> usersList = [];
    final usersDoc = await FirebaseFirestore.instance.collection('users').get();

    // extract the courses data from firbase docs
    Logger.log("::::: Success get user data");
    for (var doc in usersDoc.docs) {
      final user = UserModel.fromMap(doc.data());
      user.uid = doc.id;
      usersList.add(user);
    }
    return usersList;
  }
  
  static void listenToAllUsers({
    void Function(List<UserModel> users)? onData,
  }) async {
    FirebaseFirestore.instance.collection('users')
      .snapshots().listen((event) {
        List<UserModel> usersList = [];
        // extract the courses data from firbase docs
        Logger.log("::::: Success get user data");
        for (var doc in event.docs) {
          final user = UserModel.fromMap(doc.data());
          user.uid = doc.id;
          usersList.add(user);
        }

        onData?.call(usersList);
      });    
  }
  

  static Future<UserModel?> getUserInfoById(String? uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // extract the courses data from firbase docs
      if (userDoc.exists && userDoc.data() != null) {
        Logger.log("::::: Success get user data");
        final user = UserModel.fromMap(userDoc.data()!);
        user.uid = uid;
        return user;
      }
    } on FirebaseException catch (e) {
      Logger.logError(e.message);
      AppHelper.showToastSnackBar(message: AppHelper.handleFirebaseException(e), isError: true);
    } catch (e) {
      Logger.logError(e);
      AppHelper.showToastSnackBar(message: "Unexpected error!, try again.", isError: true);
    }
    return null;
  }
  
  static void listenToUserInfoById({
    required String? uid,
    void Function(UserModel data)? onData,
  }) {
    if (uid != null) {
      final snapshot =
          FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

      snapshot.listen((event) {
        final user = UserModel.fromMap(event.data()!);
        user.uid = uid;
        onData?.call(user);
      });
    }
  }

  static Future<void> changeUserAccountStatus({
    required String userId,
    required UserAccountStatusEnum status,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId)
      .update({
        'accountStatus': status.name,
      });

  }

  static void listenToLearnersCount({
    void Function(int newCount)? onData,
  }) {
    FirebaseFirestore.instance
        .collection('users').where('type', isEqualTo: UserTypeEnum.learner.name)
        .snapshots()
        .listen((snapshot) => onData?.call(snapshot.size));
  }
  
  static void listenToTrainersCount({
    void Function(int newCount)? onData,
  }) {
    FirebaseFirestore.instance
        .collection('users').where('type', isEqualTo: UserTypeEnum.trainer.name)
        .snapshots()
        .listen((snapshot) => onData?.call(snapshot.size));
  }

}
