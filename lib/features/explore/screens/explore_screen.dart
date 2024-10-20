import 'package:e_training_mate/common/widgets/custom_search_view.dart';
import 'package:e_training_mate/common/widgets/user_tile_widget.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/features/explore/controllers/explore_controller.dart';
import 'package:e_training_mate/features/explore/widgets/popular_course_tile.dart';
import 'package:e_training_mate/common/widgets/course_widget.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:faker/faker.dart' as faker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../common/widgets/filter_buttons_widget.dart';
import '../../../common/widgets/titled_content_list.dart';
import '../../../core/utils/logger.dart';
import 'preview_course_screen.dart';

class Explorecreen extends StatelessWidget {
  const Explorecreen({super.key});

  ExploreController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDarkMode? AppDarkColors.scaffold : AppColors.scaffold,
      statusBarIconBrightness: isDarkMode? Brightness.light : Brightness.dark,
    ));

    return RefreshIndicator(
      onRefresh: () async { controller.refreshPage();  },
      child: Scaffold(
        backgroundColor: isDarkMode? null : AppColors.scaffold,
        body: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: UserTileWidget(
                  name: controller.currentUser.value?.displayName ?? "",
                  photo: controller.currentUser.value?.photoURL,
                  borderColor: const Color(0xFFBCC5DB),
                  textColor: isDarkMode? null : AppColors.textBlueBlack,
                ),
              ),
            ),
      
            // -- Search Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDarkMode? AppDarkColors.fillInputs : Colors.white,
                borderRadius: BorderRadius.circular(30)
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.border,
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                  Flexible(
                    child: CustomSearchView(
                      isSearchForm: false,
                      controller: controller.searchCon,
                      showClearIcon: true,
                      alwaysShowClearIcon: true,
                      focusNode: controller.searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: (p0) => controller.searchText.value = p0,
                      onSubmitted: (value) {
                        controller.searchForCourses();
                        Logger.log(controller.searchText.value);
                      },
                      borderDecoration: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),            

            Obx(() => controller.isSearching.value || controller.searchText.isNotEmpty
              // -- Search Results widgets
              ? Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: TitledContentList(
                  title: 'Search Result Courses',
                  showMore: false,
                  direction: Axis.vertical,
                  useScrollWidget: false, 
                  isLoading: controller.recentlyCoursesLoading.value,
                  shimmerWidget: Skeleton.leaf(child: CourseWidget(
                    course: CourseModel.faker().first,
                    margin: AppHelper.startEndPadding(bottom: 10),
                    height: 120,
                    width: double.maxFinite,
                  )),
                  children: controller.resultSearchCourses.isEmpty
                  ? [
                      Container(
                        margin: const EdgeInsets.only(top: 40),
                        child: Text('No data found'.tr),
                      )
                    ]
                  : List.generate(
                    controller.resultSearchCourses.length,
                    (index) => CourseWidget(
                      onTap: () => Get.to(() => PreviewCourseScreen(course: controller.resultSearchCourses[index])),
                      height: 120,
                      width: double.maxFinite,
                      course: controller.resultSearchCourses[index],
                      margin: AppHelper.startEndPadding(bottom: 10),
                    ),
                  ),
                ),
              )
              : 
              // -- Explore widgets
              Column(
                children: [
                  // -- categories widget
                  TitledContentList(
                    title: 'Categories',
                    isLoading: controller.categoriesLoading.value,
                    showMore: false,
                    shimmerWidget: FilterButtonsWidget(
                      alignment: AlignmentDirectional.centerStart,
                      buttonModels: [
                        FilterButtonModel(value: '0', text: 'All'),
                        for (int i =0; i  < 6; i++) ...[
                          FilterButtonModel(value: '${i + 1}', text: faker.Faker().person.firstName()),
                        ]
                      ],
                    ),
                    content: Obx(() => FilterButtonsWidget(
                      margin: EdgeInsets.zero,
                      alignment: AlignmentDirectional.centerStart,
                      initialSelected: controller.selectedCategory.value,
                      buttonModels: <FilterButtonModel>[
                        FilterButtonModel(value: '0', text: 'All'), 
                        
                        for  (var i = 0; i < controller.categories.length; i++)
                          FilterButtonModel(
                            value: controller.categories[i].docId,
                            text: controller.categories[i].name,
                          ),              
                      ],
                      height: 35,
                      onChanged: controller.changeCategory,
                    )),
                  ),
                  const SizedBox(height: 15),
                  
                  // -- Recently added courses Widget
                  Obx(() => TitledContentList(
                    title: 'Recently Added Courses',
                    showMore: false,
                    direction: Axis.horizontal,
                    useScrollWidget: true,
                    listHeight: 125,
                    isLoading: controller.recentlyCoursesLoading.value,
                    shimmerWidget: Skeleton.leaf(child: CourseWidget(
                      course: CourseModel.faker().first,
                      margin: AppHelper.startEndPadding(end: 12),
                      maxWidth: 300,
                    )),
                    children: List.generate(
                      controller.recentlyAddedCourses.length,
                      (index) => CourseWidget(
                        onTap: () => Get.to(() => PreviewCourseScreen(course: controller.recentlyAddedCourses[index])),
                        course: controller.recentlyAddedCourses[index],
                        margin: AppHelper.startEndPadding(end: 10),
                        maxWidth: 300,
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                  
                  // -- Popular Course widget
                  Obx(() => TitledContentList(
                    title: 'Popular Courses',
                    showMore: false,
                    direction: Axis.vertical,
                    useScrollWidget: false,
                    isLoading: controller.popularCoursesLoading.value,
                    shimmerWidget: Skeleton.leaf(child: PopularCourseTile(
                      course: CourseModel.faker().first,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                    )),
                    children: List.generate(
                      controller.popularCourses.length,
                      (index) => PopularCourseTile(
                        course: controller.popularCourses[index],
                        margin: const EdgeInsets.symmetric(vertical: 5),
                      ),
                    ),
                  )),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}