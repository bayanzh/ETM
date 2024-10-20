
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/extensions/num_extension.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';

import '../../core/constant/app_dark_colors.dart';
import '../../core/utils/helpers/pref_helper.dart';
import 'custom_image_view.dart';
import '../../core/constant/image_constant.dart';


class CourseWidget extends StatelessWidget {
  final CourseModel course;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final bool showAllData;
  final bool showBackgroundColor;
  final void Function()? onTap;
  final double maxWidth;

  const CourseWidget({
    super.key,
    required this.course,
    this.width,
    this.height,
    this.margin,
    this.showAllData = false,
    this.showBackgroundColor = true,
    this.onTap,
    this.maxWidth = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode
        ? AppDarkColors.container // const Color(0xff404040)
        : AppHelper.generateLightColorFromId(course.cDocId ?? 'aaddff')
            .withOpacity(0.85);
    final textColor = showBackgroundColor ? Colors.white : isDarkMode? Colors.white : AppColors.textBlueBlack;
            
    return Container(
      
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      height: height,
      constraints: BoxConstraints(minWidth: 200, minHeight: 100, maxWidth: maxWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: course.iconUrl != null? DecorationImage(
          image: CachedNetworkImageProvider(course.iconUrl!, maxWidth: 85, maxHeight: 85),
          alignment: AlignmentDirectional.bottomEnd,
          opacity: 0.7,
          onError: (exception, stackTrace) {
            Logger.logError("::::::::::::::::: Invalid icon url: $course.iconUrl");
          },
        ) : null,
        color: showBackgroundColor ? containerColor : null,
        boxShadow: [
          if (showBackgroundColor)
            BoxShadow(
              color: const Color(0XFF23408F).withOpacity(0.14),
              offset: const Offset(-4, 5),
              blurRadius: 16,
            ),
        ],
       
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Stack(
          children: [
           
            // -- top icon
            Visibility(
              visible: isDarkMode,
              child: Positioned(
                top: 10,
                right: PrefHelper.getLangCode() == 'en'? 10 : null,
                left: PrefHelper.getLangCode() == 'ar'? 10 : null,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppHelper.generateLightColorFromId(course.cDocId ?? 'aaddff')
                    .withOpacity(0.85),
                ),
              ),
            ),

            // -- course name
            if (showAllData == false) _courseNameWidget(textColor),

            // -- trainer name and photo
            if (showAllData == false && course.trainer != null)
              Positioned(
                bottom: 5,
                right: PrefHelper.getLangCode() == 'ar'? 5 : null,
                left: PrefHelper.getLangCode() == 'en'? 5 : null,
                child: _buildTrainerRow(
                  context,
                  name: course.trainer!.name,
                  textColor: textColor,
                  photoUrl: course.trainer!.photoUrl,
                ),
              ),              

            Visibility(
              visible: showAllData,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: showAllData ? 0 : 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // -- course name
                    _courseNameWidget(textColor),
                    const SizedBox(height: 3),

                    // -- course description
                    _courseShowMoreDescriptionWidget(textColor),

                    if (course.trainer != null) ...[
                      const SizedBox(height: 15),
                      _buildTextWithShadaw('The Trainer'.tr,
                          style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(color: textColor)
                      ),
                      const SizedBox(height: 6),
                      _buildTrainerRow(
                        context,
                        name: course.trainer!.name,
                        textColor: textColor,
                        photoUrl: course.trainer!.photoUrl,
                      ),
                    ],

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Container(
                          padding: AppHelper.startEndPadding(start: 5, end: 8),
                          decoration: BoxDecoration(
                            boxShadow: [
                              if (showBackgroundColor)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(1, 1),
                                )
                            ],
                          ),
                          child: Icon(
                            Icons.people_alt_rounded,
                            size: 22,
                            color: textColor,
                          ),
                        ),
                       
                        _buildTextWithShadaw(
                          '${course.registrationsCount.makeToString()}  ${'Registerations'.tr}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                      ],
                    ),

                    if (showBackgroundColor) const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextWithShadaw(String text,
      {TextStyle? style, TextAlign? textAlign}) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: (style ?? Theme.of(Get.context!).textTheme.bodyMedium)?.copyWith(
        shadows: [
          if (showBackgroundColor)
            const BoxShadow(
              color: Color(0xAA000000),
              blurRadius: 30,
              spreadRadius: 1,
              offset: Offset(1, 1),
            )
        ],
      ),
    );
  }

  Widget _courseNameWidget(Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showAllData ? 0 : 10,
        vertical: showAllData ? 0 : 5,
      ),
      margin: EdgeInsets.only(top: showBackgroundColor ? 30 : 10),
      child: _buildTextWithShadaw(
        course.name,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: showBackgroundColor ? 18 : 20,
          color: textColor,
        ),
      ),
    );
  }

  Widget _courseShowMoreDescriptionWidget(Color textColor) {
    final lessMoreStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.primary2,
      shadows: [
        if (showBackgroundColor)
          BoxShadow(
            color: const Color(0xAAF5F3F3).withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 1,
            offset: const Offset(1, 1),
          )
      ],
    );

    return Flexible(
      fit: FlexFit.loose,
      child: ReadMoreText(
        course.description != null && course.description!.isNotEmpty? course.description! : 'No description'.tr,
        trimMode: TrimMode.Line,
        trimLines: 2,
        style: TextStyle(
          // fontSize: 15,
          color: textColor,
          shadows: [
            if (showBackgroundColor)
              const BoxShadow(
                color: Color(0xAA000000),
                blurRadius: 30,
                spreadRadius: 1,
                offset: Offset(1, 1),
              )
          ],
        ),
        colorClickableText: AppColors.primary2,
        trimCollapsedText: 'Show more'.tr,
        trimExpandedText: 'Show less'.tr,
        lessStyle: lessMoreStyle,
        moreStyle: lessMoreStyle,
      ),
    );
  }

  Widget _buildTrainerRow(
    BuildContext context, {
    required String name,
    required Color textColor,
    String? photoUrl,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Logger.log(photoUrl == null);
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          child: CustomImageView(
            imagePath: photoUrl ?? ImageConstant.personIcon,
            placeHolder: ImageConstant.personIcon,
            radius: BorderRadius.circular(16),
            width: 32,
            height: 32,
            fit: photoUrl != null ? BoxFit.cover : null,
            padding: photoUrl != null ? null : const EdgeInsets.all(2),
            color: photoUrl == null && isDarkMode? const Color(0xff8c8c8c) : null,
          ),
        ),
        const SizedBox(width: 5),
        _buildTextWithShadaw(
          name,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        )
      ],
    );
  }
}
