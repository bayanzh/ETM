import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';

import '../utils/logger.dart';

class CategoryModel {
  String? docId;
  String name;
  String? imageUrl;
  
  CategoryModel({
    this.docId,
    required this.name,
    this.imageUrl,
  });

  static List<CategoryModel> faker({int length = 2}) {
    var faker = Faker();
    return List.generate(
      length,
      (index) => CategoryModel(
        name: faker.person.name(),
      ),
    );
  }

  CategoryModel copyWith({
    String? docId,
    String? name,
    String? imageUrl,
  }) {
    return CategoryModel(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      docId: map['docId'],
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) => CategoryModel.fromMap(json.decode(source));

  @override
  String toString() => 'CategoryModel(docId: $docId, name: $name, imageUrl: $imageUrl)';

  // ================= Start Model Functions =======================
  static Future<List<CategoryModel>> getCategories({
    int? limit,
  }) async {

    List<CategoryModel> categoriesList = [];
    Query<Map<String, dynamic>> categoriesRef = FirebaseFirestore.instance
        .collection('categories').orderBy('createdDate', descending: true);

    if (limit != null) categoriesRef = categoriesRef.limit(limit);

    final categoriesDocs = (await categoriesRef.get()).docs;

    // extract the categories data from firbase docs
    for (var doc in categoriesDocs) {
      final category = CategoryModel.fromMap(doc.data());
      category.docId = doc.id;
      categoriesList.add(category);
    }
  
    Logger.log("::::: Success get categories data (length): ${categoriesDocs.length}");
    return categoriesList;
  }
  // ================= End Model Functions =======================
}
