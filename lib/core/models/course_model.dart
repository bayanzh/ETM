import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_training_mate/core/models/category_model.dart';
import 'package:e_training_mate/core/models/lesson_model.dart';
import 'package:faker/faker.dart';

import '../utils/logger.dart';
import 'user_model.dart';

class CourseModel {
  String? cDocId;
  String name;
  String? description;
  String trainerId;
  DateTime createdAt;
  int registrationsCount;
  int applicantsCount;
  String? iconUrl;
  UserModel? trainer;
  CategoryModel category;
  List<LessonModel>? lessons;

  CourseModel({
    this.cDocId,
    required this.name,
    required this.trainerId,
    required this.createdAt,
    required this.registrationsCount,
    required this.applicantsCount,
    required this.category,
    this.description,
    this.iconUrl,
    this.lessons,
  });

  static List<CourseModel> faker({int length = 2}) {
    var faker = Faker();
    return List.generate(
      length,
      (index) => CourseModel(
        name: faker.person.name(),
        trainerId: faker.jwt.secret,
        createdAt: faker.date.dateTime(),
        registrationsCount: faker.randomGenerator.integer(10000),
        applicantsCount: faker.randomGenerator.integer(100),
        category: CategoryModel.faker(length: 1).first,
      ),
    );
  }

  CourseModel copyWith({
    String? cDocId,
    String? name,
    String? description,
    int? registrationsCount,
    int? applicantsCount,
    String? trainerId,
    String? iconUrl,
    DateTime? createdAt,
    CategoryModel? category,
    List<LessonModel>? lessons,
  }) {
    return CourseModel(
      cDocId: cDocId ?? this.cDocId,
      name: name ?? this.name,
      description: description ?? this.description,
      registrationsCount: registrationsCount ?? this.registrationsCount,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      trainerId: trainerId ?? this.trainerId,
      createdAt: createdAt ?? this.createdAt,
      iconUrl: iconUrl ?? this.iconUrl,
      lessons: lessons ?? this.lessons,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': cDocId,
      'name': name,
      'description': description,
      'registrationsCount': registrationsCount,
      'applicantsCount': applicantsCount,
      'trainerId': trainerId,
      'createdAt': createdAt,
      'iconUrl': iconUrl,
      'categoryId': category.docId,
      'categoryName': category.name,
      if (lessons != null) 'lessons': LessonModel.toMapList(lessons!),
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map) {
    Logger.log(':::: NAme: ${map['name']}');
    return CourseModel(
      name: map['name'] ?? '',
      description: map['description'],
     
      registrationsCount: map['registrationsCount'] ?? 0,
      applicantsCount: map['applicantsCount'] ?? 0,
      trainerId: map['trainerId'] ?? '',
      category: CategoryModel.fromMap(map),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      iconUrl: map['iconUrl'],
      lessons: map['lessons'] != null? LessonModel.fromMapList(map['lessons']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CourseModel.fromJson(String source) => CourseModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CourseModel(uid: $cDocId, name: $name, description: $description, registrationsCount: $registrationsCount, trainerId: $trainerId, iconUrl: $iconUrl, category: $category, lessons: $lessons)';
  }




  static Future<void> incrementRegistrationsCount(String courseId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
          'registrationsCount': FieldValue.increment(1),
        });
  }

  static Future<void> decrementRegistrationsCount(String courseId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
          'registrationsCount': FieldValue.increment(-1),
        });
  }


  static Future<int?> getAllCoursesCount() async {
    final coursesCollection = FirebaseFirestore.instance.collection('courses');

    AggregateQuerySnapshot querySnapshot = await coursesCollection.count().get();

    return querySnapshot.count;
  }

  static void listenToAllCourseCount({
    void Function(int count)? onData,
  }) {
    FirebaseFirestore.instance
        .collection('courses')
        .snapshots()
        .listen((snapshot) => onData?.call(snapshot.size));
  }
  
  
  static Future<double?> getTrainerCoursesApplicantsCount({
    required String trainerId,
  }) async {
      Query coursesRef = FirebaseFirestore.instance.collection('courses')
        .where('trainerId', isEqualTo: trainerId);

     
      
      final aggregates = await coursesRef.aggregate(sum('registrationsCount')).get();

      return aggregates.getSum('registrationsCount');
  }


  static Future<List<CourseModel>> getCourses({
    int? limit,
    String? orderByField,
    bool descending = false,
    bool fetchCourseTrainer = false,
    Map<String, dynamic>? equalConditions,
    
  }) async {

    List<CourseModel> coursesList = [];
    Query<Map<String, dynamic>> coursesRef = FirebaseFirestore.instance
        .collection('courses');

    if (equalConditions != null) {
      equalConditions.forEach(
        (key, value) => coursesRef = coursesRef.where(key, isEqualTo: value),
      );
    }

    // -- Arrange the courses by orderByField parameter
    if (orderByField != null) {
      coursesRef = coursesRef.orderBy(orderByField, descending: descending);
    }

    if (limit != null) coursesRef = coursesRef.limit(limit);

    final coursesDocs = (await coursesRef.get()).docs;

    // extract the courses data from firbase docs
    for (var doc in coursesDocs) {
      final course = CourseModel.fromMap(doc.data());
      course.cDocId = doc.id;

      // -- fetch the trainer data of the course
      if (fetchCourseTrainer && course.trainerId.isNotEmpty){
        course.trainer = await UserModel.getUserInfoById(course.trainerId);
      }
      coursesList.add(course);
    }
  
    Logger.log("::::: Success get courses data (length): ${coursesDocs.length}");
    return coursesList;
  }
  
  
  static void listenToCourses({
    int? limit,
    String? orderByField,
    bool descending = false,
    bool fetchCourseTrainer = false,
    Map<String, dynamic>? equalConditions,
    void Function(List<CourseModel> courses)? onData,
    void Function(dynamic error)? onError,
  }) {
    List<CourseModel> coursesList = [];
    Query<Map<String, dynamic>> coursesRef = FirebaseFirestore.instance
        .collection('courses');

    if (equalConditions != null) {
      equalConditions.forEach(
        (key, value) => coursesRef = coursesRef.where(key, isEqualTo: value),
      );
    }
    
    // -- Arrange the courses by orderByField parameter
    if (orderByField != null) {
      coursesRef = coursesRef.orderBy(orderByField, descending: descending);
    }

    if (limit != null) coursesRef = coursesRef.limit(limit);

    coursesRef.snapshots().listen(
      (event) async {
        Logger.log("::::: New Event From listenToCourses (length): ${event.docs.length}");
        for (var doc in event.docs) {
          final course = CourseModel.fromMap(doc.data());
          course.cDocId = doc.id;

          // -- fetch the trainer data of the course
          if (fetchCourseTrainer && course.trainerId.isNotEmpty) {
            course.trainer = await UserModel.getUserInfoById(course.trainerId);
          }
          coursesList.add(course);
        }
        onData?.call(coursesList);
      },
      onError: (error) {
        Logger.logError('Error in snapshots listener: $error');
        onError?.call(error);
      },
    );
  }

  static Future<List<CourseModel>> searchCoursesByNameOrDescription({
    required String query,
    String? categoryId,
  }) async {
    List<CourseModel> coursesList = [];
    query = query[0].toUpperCase() + query.substring(1);
    
    Query<Map<String, dynamic>> coursesRef = FirebaseFirestore.instance
        .collection('courses');

    Query<Map<String, dynamic>> coursesQuery = coursesRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '$query\uf7ff')
        
    ;
    // -- fetch the result from specific category
    if (categoryId != null && categoryId != '0') {
      Logger.log(':::: Query: $query -- caregoryId: $categoryId');
      coursesQuery = coursesQuery.where('categoryId', isEqualTo: categoryId);
    }

    
    
    
    final coursesDocs = (await coursesQuery.get()).docs;

    for (var doc in coursesDocs) {
      final course = CourseModel.fromMap(doc.data());
      course.cDocId = doc.id;
      coursesList.add(course);
    }
    
    Logger.log(':::::: Courses founded by search: ${coursesList.length}.');
    
    return coursesList;
  }

  static Future<CourseModel?> getCourseDataById({
    required String courseId,
    bool getCourseLessons = true,
  }) async {
    final courseSnapshot = await FirebaseFirestore.instance.collection('courses')
        .doc(courseId).get();

    if (courseSnapshot.exists) {
      CourseModel course = CourseModel.fromMap(courseSnapshot.data()!);
      course.cDocId = courseSnapshot.id;

      // -- get course lessons data
      if (getCourseLessons){
        final lessonsCol = await courseSnapshot.reference.collection('lessons').orderBy('lessonOrderNum').get();
        course.lessons = lessonsCol.docs.map((lessonDoc) {
          final lessonModel = LessonModel.fromMap(lessonDoc.data());
          lessonModel.docId = lessonDoc.id;
          return lessonModel;
        }).toList();
      }

      return course;
    }
    return null;
  }

  static Future<void> deleteCourse(String courseId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .delete();
  }
}
