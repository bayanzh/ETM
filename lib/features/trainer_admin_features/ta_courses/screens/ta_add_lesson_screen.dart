import 'package:e_training_mate/common/screens/video_player_screen.dart';
import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/constant/app_dark_colors.dart';
import 'package:e_training_mate/core/models/quiz_question_model.dart';
import 'package:e_training_mate/features/trainer_admin_features/ta_courses/controllers/ta_course_details_controller.dart';
import 'package:e_training_mate/core/utils/dialog_util.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/enums/lesson_type_enum.dart';
import '../../../../common/widgets/app_primary_button.dart';
import '../../../../common/widgets/custom_dropdownbutton.dart';
import '../../../../common/widgets/custom_search_view.dart';
import '../../../../core/constant/app_colors.dart';
import '../../../../core/utils/helpers/validation_helper.dart';

class TaAddLessonScreen extends StatelessWidget {
  const TaAddLessonScreen({
    super.key,
    required this.courseDocId,
  });

  final String courseDocId;

  TaCourseDetailsController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode? null : AppColors.scaffold,
      appBar: AppBar(
        title: Text(
          'Add Lesson'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        forceMaterialTransparency: true,
      ),
      body: Obx(() => ListView(
            padding: const EdgeInsets.only(top: 0, bottom: 20),
            children: [
              // -- lesson type
              Form(
                key: controller.globalLessonFormKey,
                child: _buildGroupWidget(
                  isDarkMode: isDarkMode,
                  children: [
                    Text(' ${"Type".tr}'),
                    CustomDropDownButton(
                      hintText: "Please choose the type of lesson",
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      initialValue: controller.lessonType.value,
                      validator: ValidationHelper.emptyValidator,
                      items: List.generate(
                        LessonTypeEnum.values.length,
                        (index) => DropDownItemModel(
                          value: LessonTypeEnum.values[index],
                          text: LessonTypeEnum.values[index].name.tr,
                        ),
                      ),
                      onChange: (value) => controller.lessonType.value = value as LessonTypeEnum,
                    ),
                
                    // -- Lesson number Text widget with icon to show hint
                    _buildLabelWithTooltipIcon(
                      isDarkMode: isDarkMode,
                      title: "Lesson number",
                      tooltip: 'Important for lessons presentation sequence.',
                      hPadding: 0,
                      iconEndPadding: 15,
                    ),
                
                    CustomSearchView(
                      isSearchForm: false,
                      hintText: "Enter lesson number",
                      controller: controller.lessonOrderNumCon,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: ValidationHelper.emptyValidator,
                      textInputType: TextInputType.number,
                      onChanged: (value) {
                        controller.lessonOrderNumCon.text = ValidationHelper.getNumricOnly(value);
                      },
                    ),
                
                    // -- lesson title
                    Text(' ${"Title".tr}'),
                    CustomSearchView(
                      isSearchForm: false,
                      hintText: "Enter lesson title",
                      controller: controller.lessonTitleCon,
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      validator: ValidationHelper.emptyValidator,
                    ),
                
                    // -- lesson description
                    Text(' ${"Description (optional)".tr}'),
                    CustomSearchView(
                      isSearchForm: false,
                      hintText: "Enter lesson description",
                      controller: controller.lessonDescriptionCon,
                      maxLines: 3,
                      margin: const EdgeInsets.only(top: 8, bottom: 10),
                    ),
                  ],
                ),
              ),

              if (controller.lessonType.value != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Container(
                    key: ValueKey(controller.lessonType.value),
                    child: controller.lessonType.value == LessonTypeEnum.lesson
                        ? _buildLessonForm(isDarkMode: isDarkMode)
                        : _buildQuizForm(isDarkMode: isDarkMode),
                  ),
                ),
             
              
              const SizedBox(height: 15),

              if (controller.lessonType.value != null)
                Obx(() => AppPrimaryButton(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  text: 'Save',
                  width: double.maxFinite,
                  isLoading: controller.isLoading.value,
                  onTap: () {
                    if (controller.lessonType.value == LessonTypeEnum.lesson) {
                      controller.uploadNewLessonData(courseDocId);
                    } else {
                      controller.uploadNewQuizData(courseDocId);
                    }
                  },
                )),
            ],
          )),
    );
  }
  

  /// Function to build the widgets when the the lesson type is lesson
  Widget _buildLessonForm({required bool isDarkMode}) {
    const border = BorderSide(color: Colors.grey, width: 1.5);
    return Form(
      key: controller.lessonFormKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // -- lesson question group
        _buildGroupWidget(
          isDarkMode: isDarkMode,
          children: [
            // -- lesson question
            Text(' ${"Lesson Question".tr}'),
            CustomSearchView(
              isSearchForm: false,
              hintText: "Enter lesson question",
              controller: controller.questionCon,
              maxLines: 2,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              validator: ValidationHelper.emptyValidator,
            ),

            // -- Question Answer Text widget with icon to show hint
            _buildLabelWithTooltipIcon(
              isDarkMode: isDarkMode,
              title: "Question Answers",
              tooltip: 'Enter the possible answers and choose the correct answer.',
              hPadding: 0,
              iconEndPadding: 15,
            ),

            // -- Question Answer widgets
            Container(
              margin: AppHelper.startEndPadding(vertical: 10, start: 5),
              padding: AppHelper.startEndPadding(start: 10),
              decoration: BoxDecoration(
                border: Border(
                  left: Get.locale?.languageCode == 'en'? border : BorderSide.none,
                  right: Get.locale?.languageCode == 'ar'? border : BorderSide.none,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.answerControllers.length,
                    itemBuilder: (context, index) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // -- answer fiels
                          Expanded(
                            child: CustomSearchView(
                              isSearchForm: false,
                              showClearIcon: false,
                              fillColor: Colors.transparent,
                              borderDecoration: const UnderlineInputBorder(),
                              hintText: '${"Enter Answer".tr} ${index + 1}',
                              controller: controller.answerControllers[index],
                              margin: const EdgeInsets.only(bottom: 5),
                              validator: ValidationHelper.emptyValidator,
                            ),
                          ),

                          Obx(() => Radio(
                            value: index,
                            groupValue: controller.correctAnswerIndex.value,
                            onChanged: (value) {
                              controller.correctAnswerIndex.value = value ?? -1;
                            },
                          )),
                        ],
                      );
                    },
                  ),

                  // -- Add Answer Field
                  CustomOutlinedButton(
                    margin: const EdgeInsets.only(top: 10),
                    onPressed: () => controller.answerControllers.add(TextEditingController()),
                    text: 'Add Answer',
                    buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // -- video widget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(' ${"Video".tr}'),
        ),
        _buildAddVideoWidget(isDarkMode: isDarkMode),
        // const SizedBox(height: 20),
      ]),
    );
  }


  /// Function to build the widgets when the the lesson type is lesson
  Widget _buildQuizForm({required bool isDarkMode}) { 
    const border = BorderSide(color: Colors.grey, width: 1.5);

    return Form(
      key: controller.quizFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() => ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: controller.quizQuestions.length,
            itemBuilder: (context, i) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isDarkMode? AppDarkColors.container : const Color(0xFFF6F9FF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  initiallyExpanded: i == 0? true : false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  maintainState: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -- question
                      _buildLabelWithTooltipIcon(
                        isDarkMode: isDarkMode,
                        title: "${"Question".tr} ${i +1}",
                        tooltip: 'Click to delete this question',
                        icon: Icon(i > 0? Icons.delete : null, size: 20, color: Colors.grey),
                        hPadding: 0,
                        iconEndPadding: 0,
                        onTap: () async {
                          final confirmResult = await DialogUtil.showDeleteDialog(message: 'Are you sure you want to delete the question?');
                          if (confirmResult == true)  controller.quizQuestions.removeAt(i);
                        },
                      ),
                      CustomSearchView(
                        isSearchForm: false,
                        hintText: "Enter the question",
                        margin: const EdgeInsets.only(top: 8, bottom: 10),
                        showClearIcon: false,
                        validator: ValidationHelper.emptyValidator,
                        onSaved: (value) {
                          controller.quizQuestions[i].question = value ?? '';
                        },
                      ),
                    ],
                  ),
                  children: [
                    // -- question answers
                    _buildLabelWithTooltipIcon(
                      isDarkMode: isDarkMode,
                      title: "Question Answers",
                      tooltip: 'Enter the possible answers and choose the correct answer.',
                    ),
                    
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      padding: AppHelper.startEndPadding(start: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          left: Get.locale?.languageCode == 'en'? border : BorderSide.none,
                          right: Get.locale?.languageCode == 'ar'? border : BorderSide.none,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.quizQuestions[i].answers.length,
                            itemBuilder: (context, j) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // -- answer fiels
                                  Expanded(
                                    child: CustomSearchView(
                                      isSearchForm: false,
                                      showClearIcon: false,
                                      fillColor: Colors.transparent,
                                      borderDecoration: const UnderlineInputBorder(),
                                      hintText: '${"Enter Answer".tr} ${j + 1}',
                                      margin: const EdgeInsets.only(bottom: 5),
                                      validator: ValidationHelper.emptyValidator,
                                      onSaved: (value) {
                                        controller.quizQuestions[i].answers[j] = value ?? '';
                                        if (j == (controller.quizQuestions[i].answers.length -1)) {
                                          var correctAnswerIndex = int.tryParse(controller.quizQuestions[i].correctAnswer) ?? 0;
                                          controller.quizQuestions[i].correctAnswer = controller.quizQuestions[i].answers[correctAnswerIndex];
                                        }
                                      },
                                    ),
                                  ),
          
                                  Obx(() => Radio(
                                    value: j.toString(),
                                    groupValue: controller.quizQuestions[i].correctAnswer,
                                    onChanged: (value) {
                                      if (value != null) {
                                        controller.quizQuestions[i].correctAnswer = value;
                                        controller.quizQuestions.refresh();
                                      }
                                    },
                                  )),
                                ],
                              );
                            },
                          ),
          
                          // -- Add Answer Field
                          CustomOutlinedButton(
                            margin: const EdgeInsets.only(top: 10),
                            onPressed: () {
                              controller.quizQuestions[i].answers.add('');
                              controller.quizQuestions.refresh();
                            },
                            text: 'Add Answer',
                            buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
      
          // -- Add Question
          CustomOutlinedButton(
            margin: AppHelper.startEndPadding(top: 5, end: 15),
            decoration: BoxDecoration(
              color: isDarkMode? AppDarkColors.container : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: () {
              int questionNumber = controller.quizQuestions.length + 1;
              controller.quizQuestions.add(QuizQuestionModel(
                questionNumber: questionNumber,
                question: '',
                answers: ['', ''],
                correctAnswer: '0',
                questionDegree: 1,
              ));
            },
            text: 'Add Question',
            buttonTextStyle: TextStyle(color: isDarkMode? AppColors.primaryLight : AppColors.primary),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }


  Widget _buildLabelWithTooltipIcon({
    required String title,
    required bool isDarkMode,
    TextStyle? titleStye,
    String? tooltip,
    Widget? icon = const Icon(Icons.info_outline, size: 20, color: Colors.grey),
    void Function()? onTap,
    double hPadding = 15,
    double iconEndPadding = 20,
    double tooltipHMargin = 15,
  }) {
    return ListTile(
      title: Text(' ${title.tr}'),
      titleTextStyle: titleStye ?? Theme.of(Get.context!).textTheme.bodyMedium,
      minTileHeight: 0,
      minVerticalPadding: 0,
      contentPadding: AppHelper.startEndPadding(start: hPadding, end: hPadding + iconEndPadding),
      trailing: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip?.tr ?? '',
          margin: EdgeInsets.symmetric(horizontal: tooltipHMargin),
          triggerMode: onTap == null? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
          showDuration: const Duration(seconds: 4),
          textStyle: TextStyle(color: isDarkMode? Colors.white : null),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.grey[isDarkMode? 700 : 600],
          ),
          child: icon,
        ),
      ),
    );
  }

  Widget _buildGroupWidget({required bool isDarkMode,required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isDarkMode? AppDarkColors.container : const Color(0xFFF6F9FF),
          boxShadow: const [
            BoxShadow(color: Color(0x22191616), blurRadius: 9)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  final heightOfImages = 150.0;

  Widget _buildAddVideoWidget({required bool isDarkMode}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () {
          if (controller.videoPath.value.isEmpty) {
            return _buildAddMultiMediaButtonAsImage(isDarkMode: isDarkMode);
          }

          final iconUrl = controller.videoPath.value;
          print("<<<<<<<<<<$iconUrl>>>>>>>>>>");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => controller.pickVideo(),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: VideoPlayerScreen(
                        videoUrl: controller.videoPath.value,
                        buildAsScreen: false,
                        allowFullScreen: false,
                        autoPlay: false,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: InkWell(
                    onTap: () => controller.videoPath.value = '',
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.scaffold.withOpacity(0.7),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 25,
                      ),
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
      onTap: () => controller.pickVideo(),
      child: Container(
        height: heightOfImages,
        alignment: AlignmentDirectional.topStart,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isDarkMode? AppDarkColors.fillInputs : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        width: width ?? Get.width - 10,
        child: CustomOutlinedButton(
          text: 'Add lesson video',
          buttonTextStyle: TextStyle(color: hintColor),
          buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
          onPressed: () => controller.pickVideo(),
          leftIcon: Padding(
            padding: AppHelper.startEndPadding(end: 8.0),
            child: Icon(Icons.add_photo_alternate, color: hintColor),
          ),
        ),
      ),
    );
  }
}
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}