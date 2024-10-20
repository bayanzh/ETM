import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/constant/image_constant.dart';
import 'package:e_training_mate/features/student_courses/screen/student_courses_screen.dart';
import 'package:e_training_mate/features/explore/screens/explore_screen.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../notifications/screens/notifications_screen.dart';
import '../../authentication/screens/profile_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;

  late int _pageIndex;

  late final List<Widget> _scrren;

  @override
  void initState() {
    super.initState();
    _pageIndex = 1;
    _pageController = PageController(initialPage: _pageIndex);

    _scrren = [
      const HomeScreen(),
      // const ScheduleScreen(),
      const Explorecreen(),
      const StudentCoursesScreen(),
      const NotificationsScreen(),
      ProfileScreen(isEditProfile: true),
      // const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? Theme.of(context).scaffoldBackgroundColor : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      // backgroundColor: AppColors.scaffold,
      body: PageView.builder(
        itemCount: _scrren.length,
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {
          setState(() {
            _pageIndex = value;
          });
        },
        itemBuilder: (context, index) => _scrren[index],
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(right: 10, left: 10, bottom: 7),
        // height: 60,
        // padding: EdgeInsets.symmetric(),
        constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
        decoration: BoxDecoration(
          // color: AppColors.bottomNavigationBar,
          // color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          color: isDarkMode? AppDarkColors.fillInputs : AppColors.bottomNavigationBar,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _buildNavItem(context: context, iconPath: ImageConstant.homeIcon, index: 0, text: 'Home'),
            _buildNavItem(context: context, iconPath: ImageConstant.searchIcon, index: 1, text: 'Explore'),
            _buildNavItem(context: context, iconPath: ImageConstant.coursesIcon, index: 2, text: 'Courses'),
            _buildNavItem(context: context, iconPath: ImageConstant.notificationIcon, index: 3, text: 'Notification'),
            _buildNavItem(context: context, iconPath: ImageConstant.profileIcon, index: 4, text: 'Profile'),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: () async {
      //   context.loaderOverlay.show();
      //   // await FakeData.fillFakeCoursesDataToFirebase();
      //   Future.delayed(Duration(seconds: 5), () => context.loaderOverlay.hide(),);
      // }),
    );
  }

  void _changePage(index) {
    _pageController.jumpToPage(index);
    setState(() {
      _pageIndex = index;
    });
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required int index,
    required String text,
  }) {
    final width = MediaQuery.of(context).size.width - 20;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width / 5 - 4,
      height: 55,
      child: FittedBox(
        fit: BoxFit.contain,
        child: IconButton(
          padding: EdgeInsets.zero,
            icon: _pageIndex == index
                ? Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffe1e8f8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 4),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.25)
                      )
                    ]
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(children: [
                      CustomImageView(imagePath: iconPath, width: 23, height: 23),
                      // const SizedBox(width: 4),
                      // Text(text),
                    ]),
                )
                : CustomImageView(imagePath: iconPath, width: 23, height: 23, color: isDarkMode? Colors.white : null),
          // icon: Icon(icon, color: _pageIndex == index? Colors.white : null),
          onPressed: () => _changePage(index),
          visualDensity: const VisualDensity(vertical: -1)
        ),
      ),
    );
  }
}
