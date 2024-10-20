import 'package:e_training_mate/common/widgets/custom_image_view.dart';

import 'package:e_training_mate/features/trainer_admin_features/ta_home/controllers/ta_main_controller.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constant/app_dark_colors.dart';


class TaMainScreen extends StatefulWidget {
  const TaMainScreen({super.key});

  @override
  State<TaMainScreen> createState() => _TaMainScreenState();
}

class _TaMainScreenState extends State<TaMainScreen> {
 
  final controller = Get.find<TaMainController>();

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Logger.log("::::::::: PAges: ${controller.pages.last}");
    return Scaffold(
      body: Obx(() => PageView.builder(
        itemCount: controller.pages.length,
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {
          controller.currentIndex.value = value;
          
        },
        itemBuilder: (context, index) => controller.pages[index],
      )),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(right: 10, left: 10, bottom: 7),
      
        constraints: const BoxConstraints(maxWidth: 450, minWidth: 300),
        decoration: BoxDecoration(
          color: isDarkMode? AppDarkColors.fillInputs : AppColors.bottomNavigationBar,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Obx(() => Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: List.generate(controller.bottomItems.length, (index) {
                return _buildNavItem(
                  context: context,
                  iconPath: controller.bottomItems[index].icon,
                  index: index,
                  text: controller.bottomItems[index].name,
                );
          })
        ),
      )),
      
    );
  }

  void _changePage(index) {
    Logger.log('::::::::Change Page to: $index');
    controller.pageController.jumpToPage(index);
    
    controller.currentIndex.value = index;
    
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required int index,
    required String text,
  }) {
    final width = MediaQuery.of(context).size.width - 20;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final itemsCount = controller.bottomItems.length;
    return SizedBox(
      width: width / itemsCount - 4,
      height: 55,
      child: FittedBox(
        fit: BoxFit.contain,
        child: IconButton(
          padding: EdgeInsets.zero,
            icon: controller.currentIndex.value == index
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
