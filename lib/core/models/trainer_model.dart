import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class TrainerModel {
  String? uid;
  String name;
  String email;
  String? password;
  String? photoUrl;
  String? gender;

  TrainerModel({
    this.uid,
    required this.name,
    required this.email,
    required this.password,
    this.photoUrl,
    this.gender,
  });

  TrainerModel copyWith({
    ValueGetter<String?>? uid,
    String? name,
    String? email,
    ValueGetter<String?>? password,
    String? photoUrl,
    String? gender,
  }) {
    return TrainerModel(
      uid: uid != null ? uid() : this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password != null ? password() : this.password,
      photoUrl: photoUrl ?? this.photoUrl,
      gender: gender ?? this.gender,
    );
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
      'password': password,
      'photoUrl': photoUrl,
      'gender': gender,
    };
  }

  factory TrainerModel.fromMap(Map<String, dynamic> map) {
    return TrainerModel(
      uid: map['uid'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      photoUrl: map['photoUrl'],
      gender: map['gender'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TrainerModel.fromJson(String source) => TrainerModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'TrainerModel(uid: $uid, name: $name, email: $email, password: $password, gender: $gender)';
  }

  static Future<TrainerModel?> getTrainerById(String trainerId) async {
    final trainerSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(trainerId)
        .get();

    if (trainerSnapshot.exists) {
      return TrainerModel.fromMap(trainerSnapshot.data()!);
    }
    return null;
  }
}
