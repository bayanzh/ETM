import 'dart:math';

import 'package:e_training_mate/common/widgets/custom_image_view.dart';
import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/app_primary_button.dart';
import '../../../../common/widgets/custom_dropdownbutton.dart';
import '../../../../common/widgets/custom_search_view.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/utils/helpers/validation_helper.dart';
import '../controllers/ta_add_course_controller.dart';

class TaAddCourseScreen extends StatelessWidget {
  const TaAddCourseScreen({super.key});

  TaAddCourseController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode? null : AppColors.scaffold,
      appBar: AppBar(
        title: Text('Add Course'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        forceMaterialTransparency: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        children: [
          Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const
                Text(' ${"Category".tr}'),
                Obx(
                  () => controller.categoriesLoading.value
                      ? AppHelper.custumProgressIndecator()
                      : CustomDropDownButton(
                          hintText: "Select course category",
                          // fillColor: Colors.white,
                          margin: const EdgeInsets.only(top: 8, bottom: 20),
                          initialValue: controller.selectedCategory.value,
                          validator: ValidationHelper.emptyValidator,
                          items: List.generate(
                            controller.categories.length,
                            (index) => DropDownItemModel(
                              value: controller.categories[index].docId ??
                                  Random().nextInt(1000),
                              text: controller.categories[index].name,
                            ),
                          ),
                          onChange: (value) => controller
                              .selectedCategory.value = value.toString(),
                        ),
                ),

                Text(' ${"Name".tr}'),
                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter course name",
                  controller: controller.nameCon,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                  validator: ValidationHelper.emptyValidator,
                ),

                Text(' ${"Description (optional)".tr}'),
                CustomSearchView(
                  isSearchForm: false,
                  hintText: "Enter course description",
                  controller: controller.descriptionCon,
                  maxLines: 3,
                  margin: const EdgeInsets.only(top: 8, bottom: 20),
                ),

                Text(' ${"Icon (optional)".tr}'),
                _buildIconWidget(isDarkMode: isDarkMode),
                const SizedBox(height: 20),

                Obx(
                  () => controller.categoriesLoading.value
                      ? const SizedBox.shrink()
                      : AppPrimaryButton(
                          
                          text: 'Save',
                          width: double.maxFinite,
                          isLoading: controller.isLoading.value,
                          onTap: controller.submitSaveButton,
                          
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final heightOfImages = 150.0;

  Widget _buildIconWidget({required bool isDarkMode}) {
    return SizedBox(
      height: heightOfImages,
      child: Obx(
        () {
          if (controller.iconPath.value.isEmpty) {
            return _buildAddMultiMediaButtonAsImage(isDarkMode:  isDarkMode);
          }

          final iconUrl = controller.iconPath.value;
          print("<<<<<<<<<<$iconUrl>>>>>>>>>>");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => controller.pickImage(),
                  child: CustomImageView(
                    alignment: Alignment.center,
                    imagePath: iconUrl,
                    radius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  alignment: AlignmentDirectional.topEnd,
                  child: InkWell(
                    onTap: () => controller.iconPath.value = '',
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddMultiMediaButtonAsImage({required bool isDarkMode, double? width}) {
    final hintColor =
        Theme.of(Get.context!).inputDecorationTheme.hintStyle?.color;
    return GestureDetector(
      onTap: () => controller.pickImage(),
      child: Container(
        height: heightOfImages,
        alignment: AlignmentDirectional.topStart,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode? AppDarkColors.fillInputs : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: width ?? Get.width - 20,
        child: CustomOutlinedButton(
          text: 'Add course icon',
          buttonTextStyle: TextStyle(color: hintColor),
          buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
          onPressed: () => controller.pickImage(),
          leftIcon: Padding(
            padding: AppHelper.startEndPadding(end: 8.0),
            child: Icon(Icons.add_photo_alternate, color: hintColor),
          ),
        ),
      ),
    );
  }
}
