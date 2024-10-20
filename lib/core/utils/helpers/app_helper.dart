import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:intl/intl.dart';

import '../../../common/widgets/circle_indecator.dart';


class AppHelper {
  static EdgeInsets startEndPadding({double start = 0, double end = 0, double? vertical, double  top = 0, double bottom = 0}) {
    print("----------- lang: ${Get.locale?.languageCode}");
    return EdgeInsets.only(
      right: Get.locale?.languageCode == 'en' ? end : start,
      left: Get.locale?.languageCode == 'en' ? start : end,
      top: vertical ?? top,
      bottom: vertical ?? bottom,
    );
  }

  static Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255, // الشفافية ثابتة على 255 للحصول على ألوان غير شفافة
      random.nextInt(256), // قيمة الأحمر
      random.nextInt(256), // قيمة الأخضر
      random.nextInt(256), // قيمة الأزرق
    );
  }

  static Color generateLightColorFromId(String id) {
    // إنشاء مجموع للـ ASCII code الخاص بكل حرف في id
    int sum = id.runes.fold(0, (int previousValue, int element) => previousValue + element);

    // استخدم المجموع لإنشاء لون، والتحكم بدرجة اللون الأساسية (Hue)
    double hue = (sum % 360).toDouble(); // توليد قيمة hue فريدة
    double saturation = 0.3 + (sum % 50) / 100; // تعديل التشبع لزيادة التفريق
    double lightness = 0.65; // تعديل السطوع لجعله فاتحاً

    // إنشاء لون من Hue, Saturation, Lightness
    HSLColor hslColor = HSLColor.fromAHSL(1.0, hue, saturation, lightness);
    return hslColor.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final darkerHsl = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darkerHsl.toColor();
  }

  static String handleFirebaseException(FirebaseException e) {
    if (e.code == 'weak-password') {
      return 'Password is To weak...'.tr;
    } else if (e.code == 'email-already-in-use') {
      return "The account already exists for that email.".tr;
    } else if (e.code == 'user-not-found') {
      return "No user found for that email.".tr;
    } else if (e.code == 'wrong-password') {
      return "Invalid password or email.".tr;
    } else {
      return "Oops! Some thing error! check your data and try again.".tr;
    }
  }

  static Widget buildTextWithShadaw(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    double? blurRadius = 20,
    Offset? offset = const Offset(1, 1),
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: (style ?? Theme.of(Get.context!).textTheme.bodyMedium)?.copyWith(
        // color: Colors.white,
        shadows: [
          BoxShadow(
            color: const Color(0xAA000000),
            blurRadius: blurRadius ?? 0.0,
            spreadRadius: 1,
            offset: offset ?? Offset.zero,
          )
        ],
      ),
    );
  }

  static Future<void> pickDateAndTime(Rx<DateTime?> date, {bool pickTime = false}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: Get.context!,
      initialDate: date.value ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      locale: const Locale('en'),
    );

    if (pickedDate != null) {
      TimeOfDay time = TimeOfDay.now();

      if (pickTime) {
        // Pick Time
        TimeOfDay? pickedTime = await showTimePicker(
          context: Get.context!,
          initialTime: TimeOfDay.fromDateTime(date.value ?? DateTime.now()),
          initialEntryMode: TimePickerEntryMode.input,
        );

        if (pickedTime != null) {
          time = pickedTime;
        }
      } 

      date.value = DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
          time.hour, time.minute, DateTime.now().second);
    }
  }

  static Future<void> pickTime(Rx<TimeOfDay?> time) async {
    // Pick Time
    final TimeOfDay? pickedTime = await showTimePicker(
      context: Get.context!,
      initialTime: time.value ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
    );

    if (pickedTime != null) {
      time.value = TimeOfDay(hour: pickedTime.hour, minute: pickedTime.minute);
    }
  }

  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('yyyy-MM-dd  h:mm a').format(dateTime);
  }
  
  static String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
  
  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('h:mm a').format(dateTime);
  }
  
  static String formatTimeFromTime(TimeOfDay? dateTime) {
    if (dateTime == null) return '';
    String hours = dateTime.hourOfPeriod.toString().padLeft(2, '0');
    String minutes = dateTime.minute.toString().padLeft(2, '0');
    String period = dateTime.period.name.toUpperCase().tr;
    return '$hours:$minutes  $period';
    // return DateFormat('h:mm a').format(dateTime.);
  }

  static Widget circularProgressIndicator({Color? color, double? size}){
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: color),
    );
  }

  static Widget custumProgressIndecator({Color? color, double size = 40.0}) {
    return Container(
      alignment: Alignment.center,
      child: CircleIndecator(
        duration: const Duration(milliseconds: 2000),
        color: color ?? Colors.blue,
        size: size,
        
      ),
    );
  }

  static showToastSnackBar({
    required String message,
    bool isError = false,
    bool isSuccess = false,
  }) {
    final context = Get.context;
    if (context != null) {
      final snackBar = SnackBar(
        content: Text(message.tr, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : isSuccess? Colors.green : Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        showCloseIcon: true,
        closeIconColor: Colors.white,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

}
