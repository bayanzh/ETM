class FireConstant {
  static const profilePhotoFolderPath = 'profile_pictures/';
  static const courseIconsFolderPath = 'courses_icons/';
  
  static String getCourseVideosFolderPath({
    required String courseId,
    String? courseName = 'CourseName',
    String? userName = 'UserName',
  }) {
    return 'courses_media/$courseName - $userName - $courseId/';
  }
}