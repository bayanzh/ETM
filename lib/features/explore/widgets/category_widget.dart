import 'package:e_training_mate/core/models/category_model.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:flutter/material.dart';

import '../../../common/widgets/custom_image_view.dart';
import '../../../core/constant/image_constant.dart';

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final void Function()? onTap;

  const CategoryWidget({
    super.key,
    required this.category,
    this.width,
    this.height = 170,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      height: height,
      padding: const EdgeInsets.all(2),
      constraints: const BoxConstraints(minWidth: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0XFF23408F).withOpacity(0.14),
            offset: const Offset(-4, 5),
            blurRadius: 16,
          ),
        ],
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        splashColor: Colors.red,
        highlightColor: Colors.amber,
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: CustomImageView(
                imagePath: category.imageUrl  ?? 'https://via.placeholder.com/150',
                radius: const BorderRadius.vertical(top: Radius.circular(15)),
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: double.maxFinite,
                onTap: onTap,
              ),
              
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                category.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textGrey2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildTrainerRow(String name, [String? photoUrl]) {
  Logger.log(photoUrl == null);
  return Row(
    children: [
      CircleAvatar(
        radius: 16,
        child: CustomImageView(
          imagePath:  photoUrl ?? ImageConstant.personIcon,
          placeHolder: ImageConstant.personIcon,
          radius: BorderRadius.circular(16),
          width: 32,
          height: 32,
          fit: photoUrl != null ? BoxFit.cover : null,
          padding: photoUrl != null ? null : const EdgeInsets.all(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
      )
    ],
  );
}
