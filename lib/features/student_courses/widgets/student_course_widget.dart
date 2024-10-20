import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_training_mate/features/student_courses/models/student_course_model.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../core/constant/app_dark_colors.dart';

class StudentCourseWidget extends StatelessWidget {
  final StudentCourseModel studentCourse;
  final double? width;
  final EdgeInsets? margin;
  final void Function()? onTap;

  const StudentCourseWidget({
    super.key,
    required this.studentCourse,
    this.width,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDarkMode
        ? AppDarkColors.container 
        : AppHelper.generateLightColorFromId(studentCourse.course.cDocId ?? 'aaddff')
            .withOpacity(0.85);
            
    return Container(
      padding: const EdgeInsets.all(10),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: containerColor,
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF23408F).withOpacity(0.14),
            offset: const Offset(-4, 5),
            blurRadius: 16,
          ),
        ],
        // color: Colors.white,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -- course name
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      studentCourse.course.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
              
                  Text(
                    "${'Joining date:'.tr} ${AppHelper.formatDate(studentCourse.joiningDate)}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
              
                  Skeleton.leaf(
                    child: FractionallySizedBox(
                      widthFactor: 0.9,
                      child: LinearProgressIndicator(
                        minHeight: 15,
                        borderRadius: BorderRadius.circular(15),
                        value: studentCourse.viewingRate,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // -- course icon
            if (studentCourse.course.iconUrl != null)
              Container(
                constraints: const BoxConstraints(maxWidth: 80, maxHeight: 80),
                child: Opacity(
                  opacity: 0.7,
                  child: CachedNetworkImage(imageUrl: studentCourse.course.iconUrl!, fit: BoxFit.fill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
