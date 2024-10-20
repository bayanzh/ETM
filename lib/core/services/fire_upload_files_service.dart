import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../utils/logger.dart';
import '../models/lesson_model.dart';

class FireUploadFilesService {
  static Future<String> uploadImage(
    String photoPath, {
    String folderPath = '',
    String? fileName,
  }) async {
    String? storeFileName = fileName ?? FirebaseAuth.instance.currentUser?.uid;

    if (storeFileName != null) {
      String photoExt = photoPath.split('.').last;

      String destination = '$folderPath$storeFileName.$photoExt';
      Reference storageRef = FirebaseStorage.instance.ref().child(destination);

      // upload the image and get image url
      TaskSnapshot storageSnapshot = await storageRef.putFile(File(photoPath));
      return await storageSnapshot.ref.getDownloadURL();
    }
    return '';
  }

  static Future<String> uploadVideo(String videoPath, {
    String folderPath = '',
    required String fileName,
    void Function(double progress)? onProgress,
    void Function(dynamic error)? onError,
  }) async {
    String videoExt = videoPath.split('.').last;
    final destination = '$folderPath$fileName.$videoExt';

    UploadTask uploadTask = FirebaseStorage.instance.ref(destination).putFile(File(videoPath));

    uploadTask.snapshotEvents.listen(
      (event) {
        onProgress?.call((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()));
      },
      onError: (error) {
        Logger.logError('Error in snapshots listener: $error');
        onError?.call(error);
      },
    );

    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

 

  /// Deletes a specific file or files from Firebase Storage.
  /// 
  /// [folderPath] is the path to the folder containing the file.
  /// [fileName] is the exact or partial name of the file to be deleted.
  /// If [isFileNamePartOfOriginFileName] is true, the function searches for files 
  /// that contain [fileName] within their name.
  /// The [deleteAllMatches] parameter determines whether to delete all matching 
  /// files (true) or just the first one (false).
  /// If [isFileNamePartOfOriginFileName] is false, it deletes the file with the exact [fileName].
  static Future<bool> deleteFile({
    required String folderPath,
    required String fileName,
    bool isFileNamePartOfOriginFileName = false,
    bool deleteAllMatches = false, // New parameter to control multiple deletions
  }) async {
    try {
      // Get the root reference from Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref(folderPath);

      if (!isFileNamePartOfOriginFileName) {
        // Delete the file with the exact name
        final Reference fileRef = storageRef.child(fileName);
        await fileRef.delete();
        Logger.log('Successfully deleted file: $fileName in $folderPath');
      } else {
        // Retrieve the list of files in the folder
        final ListResult result = await storageRef.listAll();

        // Search for files that contain the provided partial name
        for (var fileRef in result.items) {
          if (fileRef.name.contains(fileName)) {
            await fileRef.delete();
            Logger.log('Successfully deleted file: ${fileRef.name}');
            
            // If not deleting all matches, stop after the first match
            if (!deleteAllMatches) {
              break;
            }
          }
        }
      }
      return true;
    } catch (e) {
      Logger.logError("Unexpected error!, try again: $e");
      return false;
    }
}



  static Future<bool> deleteFolderWithItsFiles({
    required String folderPath,
    String? deleteWhereFolderNameContains,
  }) async {
    try {
      // يجيب مرجع الجذر من Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref(folderPath);

      if (deleteWhereFolderNameContains == null) {
        // حذف جميع الملفات في المجلد الرئيسي
        final ListResult result = await storageRef.listAll();
        for (var fileRef in result.items) {
          await fileRef.delete();
        }
        Logger.log('Successfully deleted all files in $folderPath');
      } else {
        // استرجاع قائمة المجلدات الموجودة في المسار الرئيسي
        final ListResult result = await storageRef.listAll();

        // البحث عن المجلد الذي يحتوي على النص في اسمه
        for (var folderRef in result.prefixes) {
          Logger.log('::::: Folder name: ${folderRef.name}');
          if (folderRef.name.contains(deleteWhereFolderNameContains)) {
            // استرجاع قائمة الملفات داخل المجلد
            final ListResult folderContents = await folderRef.listAll();
            Logger.log(':::::::::::: Match: $folderContents');

            // حذف جميع الملفات في المجلد
            for (var fileRef in folderContents.items) {
              await fileRef.delete();
            }

            Logger.log('Successfully deleted all files in ${folderRef.name}');
            // -- End The loop
            break;
          }
        }
      }
      return true;
    } catch (e) {
      Logger.logError("Unexpected error!, try again: $e");
      return false;
    }
  }

}