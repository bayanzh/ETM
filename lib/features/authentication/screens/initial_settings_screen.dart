import 'package:e_training_mate/features/authentication/widgets/allow_notification_slide.dart';
import 'package:e_training_mate/features/authentication/widgets/create_profile_slide.dart';
import 'package:e_training_mate/features/authentication/widgets/select_language_slide.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/header/app_header.dart';
import '../../../core/constant/app_dark_colors.dart';
import '../../../localization/app_locale_controller.dart';
import '../../../core/constant/app_colors.dart';
import 'profile_screen.dart';

class InitialSettingsScreen extends StatefulWidget {
  const InitialSettingsScreen({super.key});

  @override
  State<InitialSettingsScreen> createState() => _InitialSettingsScreenState();
}

class _InitialSettingsScreenState extends State<InitialSettingsScreen> {
  final pageController = PageController();
  RxInt currentPage = 0.obs;

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();

    pages = [
      SelectLanguageSlide(
        initialValue: PrefHelper.getLangCode() == 'en'? 1 : 2,
        onChange: (selectedLangCode) {
          Get.find<AppLocaleController>().changeLanguage(selectedLangCode);
        },
        onSubmit: (selectedLangCode) => goToNextPage(),
      ),
      AllowNotificationSlide(
        onSubmit: (value) {
          PrefHelper.setEnabledNotification(value);
          goToNextPage();
        },
      ),
      CreateProfileSlide(
        onSubmit: () => Get.off(() => ProfileScreen(
              isEditProfile: false,
              isEmailReadOnly: true,
              isNameReadOnly: true,
            )),
      ),
    ];
  }

  void goToNextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInToLinear,
    );
  }

  late bool isDarkMode;
  
  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : Colors.white,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));
    

    return Scaffold(
      appBar: const AppHeader(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
              child: PageView.builder(
                itemCount: pages.length,
                controller: pageController,
                onPageChanged: (value) {
                  currentPage.value = value;
                },
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    child: ListView(shrinkWrap: true, children: [pages[index]]),
                  );
                },
              ),
            ),
          ),

          // -- dottedIndicatorWidget
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Obx(() => dottedIndicatorWidget),
          ),
        ],
      ),
    );
  }

  Widget get dottedIndicatorWidget {
    final activeColor = isDarkMode? Colors.white : Colors.black;
    return Row(
        children: List.generate(pages.length, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 7,
            width: index == currentPage.value ? 24 : 7,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: index == currentPage.value ? activeColor : AppColors.border,
            ),
          );
        }),
      );
  }
}
