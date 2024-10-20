
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../localization/app_locale_controller.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  late RxString selectedLang;
  late RxBool allowNotification;
  final localeController = Get.find<AppLocaleController>();

  @override
  void initState() {
    super.initState();
    selectedLang = RxString(PrefHelper.getLangCode());
    allowNotification = PrefHelper.isNotificationEnabled().obs;
  }

  Widget buildListTile(String text, IconData icon, void Function()? tapHandler) {
    return ListTile(
      leading: Icon(
        icon,
        color: Get.theme.iconTheme.color,
      ),
      title: Text(
        text.tr,
        style: Get.textTheme.titleMedium,
      ),
      onTap: tapHandler,
    );
  }

  Widget buildRadioListTile({
    required String title,
    required String value,
    required String? groupValue,
    required void Function(String?)? onChanged,
  }) {
    return RadioListTile(
      title: Text(title.tr),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      visualDensity: const VisualDensity(vertical: -3),
    );
  }

  @override
  Widget build(BuildContext context) {
    Logger.log("::::: Selected Lang: ${selectedLang.value}");
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDarkMode ? Colors.grey[800] : AppColors.scaffold,
      child: SafeArea(
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back)),
                  
                  // -- notifications choice
                  ExpansionTile(
                    leading: Icon(
                      Icons.notifications_none,
                      color: Get.theme.iconTheme.color
                    ),
                    title: Text("Notifications".tr, style: Get.textTheme.titleMedium),
                    children: [
                      Obx(() => CheckboxListTile(
                        value: allowNotification.value,
                        title: Text('Allow us to send notifications to you'.tr),
                        onChanged: (value) {
                          allowNotification.value = value ?? true;
                          PrefHelper.setEnabledNotification(allowNotification.value);
                        },
                      )),
                    ],
                  ),

                  // -- Language choice
                  Obx(() => ExpansionTile(
                    leading: Icon(
                      Icons.language,
                      color: Get.theme.iconTheme.color,
                    ),
                    title: Text("Language".tr, style: Get.textTheme.titleMedium),
                    children: [
                      buildRadioListTile(
                        title: "English",
                        value: "en",
                        groupValue: selectedLang.value,
                        onChanged: (value) {
                          selectedLang.value = value ?? 'en';
                          localeController.changeLanguage(selectedLang.value);
                        },
                      ),
                      buildRadioListTile(
                        title: "Arabic",
                        value: "ar",
                        groupValue: selectedLang.value,
                        onChanged: (value) {
                          selectedLang.value = value ?? 'ar';
                          localeController.changeLanguage(selectedLang.value);
                        },
                      ),
                    ],
                  )),

                  // -- Theme mode
                  ExpansionTile(
                    leading: Icon(
                      Icons.color_lens,
                      color: Get.theme.iconTheme.color,
                    ),
                    title: Text("Theme Mode".tr, style: Get.textTheme.titleMedium),
                    children: [
                      buildRadioListTile(
                        title: "Light Mode",
                        value: "light",
                        groupValue: PrefHelper.getThemeMode(),
                        onChanged: (value) {
                          PrefHelper.setThemeMode("light");
                          Get.changeThemeMode(ThemeMode.light);
                        },
                      ),
                      buildRadioListTile(
                        title: "Dark Mode",
                        value: "dark",
                        groupValue: PrefHelper.getThemeMode(),
                        onChanged: (value) {
                          PrefHelper.setThemeMode("dark");
                          Get.changeThemeMode(ThemeMode.dark);
                          Logger.log("dark");
                        },
                      ),
                    ],
                  ),
              
                  buildListTile("Help", Icons.help, null),
                  const Divider(indent: 30, endIndent: 30),
              
                  buildListTile("Invite Friends", Icons.share_rounded, null),
                ],
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                alignment: AlignmentDirectional.bottomStart,
                padding: const EdgeInsets.only(bottom: 20),
                child: buildListTile(
                  "Log out",
                  Icons.logout,
                  () async {
                    final result = await DialogUtil.showConfirmDialog(message: 'Are you sure you want to log out?');
                    if (result == true) {
                      PrefHelper.setUserType(null);
                      Get.offAll(() => const WelcomeScreen());
                      FirebaseAuth.instance.signOut();
                      Get.reloadAll(force: true);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
