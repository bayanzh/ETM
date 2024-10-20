import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PrefHelper{
  static final pref = Get.find<SharedPreferences>();
  static const _openAppForFirstTimeKey = "openAppForFirstTimeKey";
  static const _displayIntialSettingsKey = "displayIntialSettingsKey";
  static const _languageKey = "languageKey";
  static const _themeModeKey = "themeModeKey";
  static const _notificationKey = "notificationKey";
  static const _userTypeKey = "userTypeKey";
  static const _failUploadingLessonIdKey = "failUploadingLessonIdKey";
  static const _failVideoPathKey = "failVideoPathKey";

  // -- Initial App Cache
  static void setOpenAppForFirstTime(bool status) {
    pref.setBool(_openAppForFirstTimeKey, status);
  }
  static bool isOpenAppForFirstTime() {
    return pref.getBool(_openAppForFirstTimeKey) ?? true;
  }
  
  static void setDisplayIntialSettings(bool status) {
    pref.setBool(_displayIntialSettingsKey, status);
  }
  static bool isDisplayIntialSettings() {
    return pref.getBool(_displayIntialSettingsKey) ?? false;
  }


  // -- app language cashe
  static setLangCode(String langCode) {
    return pref.setString(_languageKey, langCode);
  }

  static String getLangCode() {
    return pref.getString(_languageKey) ?? 'en';
  }
 
 
  // -- app language cashe
  static setThemeMode(String themeMode) {
    return pref.setString(_themeModeKey, themeMode);
  }

  static String getThemeMode() {
    return pref.getString(_themeModeKey) ?? 'light';
  }
  


  // -- app notification cashe
  static setEnabledNotification(bool status) {
    return pref.setBool(_notificationKey, status);
  }
  
  static bool isNotificationEnabled() {
    return pref.getBool(_notificationKey) ?? false;
  }

  
  // -- user cashe
  static void setUserType(UserTypeEnum? userType) {
    if (userType == null) {
      pref.remove(_userTypeKey);
      return;
    }
    pref.setString(_userTypeKey, userType.name);
  }

  static UserTypeEnum? getUserType() {
    final type = pref.getString(_userTypeKey);
    return type != null? UserTypeEnum.values.byName(type) : null;
  }

  static void setFailUploadingLessonId(String? value) {
    if (value == null) {
      pref.remove(_failUploadingLessonIdKey);
      return;
    }
    pref.setString(_failUploadingLessonIdKey, value);
  }
  
  static String? getFailUploadingLessonId() {
    return pref.getString(_failUploadingLessonIdKey);
  }

  static void setFailVideoPath(String? value) {
    if (value == null) {
      pref.remove(_failVideoPathKey);
      return;
    }
    pref.setString(_failVideoPathKey, value);
  }
  static String? getFailVideoPath() {
    return pref.getString(_failVideoPathKey);
  }


}