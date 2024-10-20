import 'package:e_training_mate/common/enums/user_type_enum.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/features/home/screens/main_screen.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_home/screens/ta_main_screen.dart';
import 'package:e_training_mate/core/utils/helpers/pref_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/header/app_header.dart';
import '../../../common/widgets/app_primary_button.dart';
import '../../../common/widgets/circle_avatar_widget.dart';
import '../../../common/widgets/custom_dropdownbutton.dart';
import '../../../common/widgets/custom_search_view.dart';
import '../../../common/widgets/main_drawer.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/constant/app_colors.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../../../core/utils/helpers/validation_helper.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({
    super.key,
    this.isEditProfile = false,
    this.isNameReadOnly = false,
    this.isEmailReadOnly = false,
  });

  final bool isEditProfile;
  final bool isNameReadOnly;
  final bool isEmailReadOnly;

  ProfileController get controller => Get.find();
  
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.closeDrawer();  // اغلاق الدرج اذا كان مفتوح
    } else {
      _scaffoldKey.currentState!.openDrawer();   // فتح الدرج اذا كان مغلق
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? Colors.grey[800] : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return RefreshIndicator(
      onRefresh: controller.getStudentInfo,
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const MainDrawer(),
        body: ListView(
          shrinkWrap: true,
          children: [
            AppHeader(
              height: 220,
              color: isDarkMode? Colors.grey[800] : AppColors.scaffold,
              curveRightSide: true,
              curveOutside: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    if (isEditProfile)
                      Positioned(
                        right: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: toggleDrawer,
                          iconSize: 27,
                          icon: Icon(Icons.menu, color: isDarkMode? AppDarkColors.iconColor : null),
                        ),
                      ),
      
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatarWidget(
                          imagePath: controller.photoPath,
                          placeHolder: ImageConstant.personIcon,
                          borderColor: isDarkMode? AppDarkColors.iconColor :Colors.white,
                          placeHolderColor: isDarkMode? AppDarkColors.iconColor :Colors.white,
                          size: 140,
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
      
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(' ${"Name".tr}'),
                     CustomSearchView(
                      isSearchForm: false,
                      hintText: "Enter Your Name",
                      controller: controller.nameCon,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: ValidationHelper.emptyValidator,
                      readOnly: isNameReadOnly,
                      showClearIcon: !isNameReadOnly,
                    ),
                    
                    
                    
                    Obx(() {
                      if (controller.isLoading.value && controller.student.value == null) {
                        return AppHelper.custumProgressIndecator();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(' ${"Age".tr}'),
                          CustomSearchView(
                            isSearchForm: false,
                            hintText: "Enter Your Age",
                            controller: controller.ageCon,
                            margin: const EdgeInsets.only(top: 8, bottom: 20),
                            validator: ValidationHelper.numberValidator,
                            textInputType: TextInputType.number,
                          ),
              
                          Text(' ${"Gender".tr}'),
                          CustomDropDownButton(
                            hintText: "Select Your Gender",
                            margin: const EdgeInsets.only(top: 8, bottom: 20),
                            initialValue: controller.gender.value,
                            items: [
                              DropDownItemModel(value: "Male", text: "Male".tr),
                              DropDownItemModel(value: "Female", text: "Female".tr),
                            ],
                            onChange: (value) {
                              controller.gender.value = value.toString();
                            },
                          ),
                        ],
                      );
                    }),
              
                    Text(' ${"Email".tr}'),
                    CustomSearchView(
                      isSearchForm: false,
                      hintText: "Enter Your Email",
                      controller: controller.emailCon,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: ValidationHelper.emailValidator,
                      readOnly: isEmailReadOnly,
                      showClearIcon: !isEmailReadOnly,
                    ),
                  ],
                ),
              ),
            ),
        
            Obx(() => controller.isLoading.value && controller.student.value == null
                ? const SizedBox.shrink()
                : AppPrimaryButton(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    text: isEditProfile? 'Save Edit' : 'Save',
                    isDisabled: !controller.isFieldsFill.value,
                    isLoading: controller.isLoading.value,
                    onTap: () async {
                      bool isSuccess = await controller.submitSaveEditButton();
                      if (isSuccess == true && isEditProfile == false) {
                        PrefHelper.setDisplayIntialSettings(false);

                        if (PrefHelper.getUserType() == UserTypeEnum.trainer) {
                          Get.offAll(() => const TaMainScreen());
                        } else {
                          Get.offAll(() => const MainScreen());
                        }
                      }
                    }
                  )),
          ]
        ),
      ),
    );
  }
}