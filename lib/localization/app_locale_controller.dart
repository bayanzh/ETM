import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/utils/helpers/pref_helper.dart';
import '../core/utils/logger.dart';


class AppLocaleController extends GetxController {

  // late Locale language;

  @override
  void onInit() {
    super.onInit();
    String langCode = PrefHelper.getLangCode();
  }

  Future<void> changeLanguage(String langCode) async {
    Logger.log(":::::::::::Change language to: $langCode");
    PrefHelper.setLangCode(langCode);
    await Get.updateLocale(Locale(langCode));
  }
}