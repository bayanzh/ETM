import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_training_mate/core/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_image_view.dart';
import '../../../common/widgets/custom_outlined_button.dart';
import '../../../core/constant/image_constant.dart';
import '../../../core/utils/helpers/app_helper.dart';
import '../screens/preview_course_screen.dart';

class PopularCourseTile extends StatelessWidget {
  const PopularCourseTile({super.key, required this.course, this.margin});

  final CourseModel course;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDarkMode? const Color(0xff404040) : Colors.white.withOpacity(0.5);
    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: () => Get.to(() => PreviewCourseScreen(course: course)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        tileColor: tileColor,
        title: Text(
          course.name,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        trailing: course.iconUrl != null? AnimatedOpacity(
          opacity: 0.5,
          duration: const Duration(milliseconds: 300),
          child: CachedNetworkImage(imageUrl: course.iconUrl!, width: 85, height: 85, fit: BoxFit.fill),
        ) : null,
        subtitle: Container(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              _buildTrainerRow(context, course.trainer?.name ?? ''),
              const SizedBox(width: 10),

              CustomOutlinedButton(
                text: course.registrationsCount.toString(),
                buttonTextStyle: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
                height: 30,
                buttonStyle: OutlinedButton.styleFrom(side: BorderSide.none),
                leftIcon: Padding(
                  padding: AppHelper.startEndPadding(end: 8.0),
                  child: const Icon(Icons.people_alt_rounded, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerRow(BuildContext context, String name, [String? photoUrl]) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        CircleAvatar(
          radius: 15,
          child: CustomImageView(
            imagePath: photoUrl ?? ImageConstant.personIcon,
            placeHolder: ImageConstant.personIcon,
            radius: BorderRadius.circular(15),
            width: 30,
            height: 30,
            fit: photoUrl != null ? BoxFit.cover : null,
            padding: photoUrl != null ? null : const EdgeInsets.all(2),
            color: isDarkMode? const Color(0xff8c8c8c) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          name,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
          ),
        )
      ],
    );
  }
}
