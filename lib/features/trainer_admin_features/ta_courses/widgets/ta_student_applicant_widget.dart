import 'package:e_training_mate/common/enums/applicant_status_enum.dart';
import 'package:e_training_mate/core/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/custom_image_view.dart';
import '../../../../common/widgets/custom_outlined_button.dart';
import '../../../../core/constant/app_dark_colors.dart';
import '../../../../core/constant/image_constant.dart';

class TaStudnetApplicantWidget extends StatelessWidget {
  TaStudnetApplicantWidget({
    super.key,
    required this.studentName,
    required this.status,
    this.photo,
    this.width,
    this.margin,
    this.onTap,
    this.onAccept,
  });

  final String studentName;
  final ApplicantStatusEnum status;
  final String? photo;
  final double? width;
  final EdgeInsets? margin;
  final void Function()? onTap;
  final Future<void> Function()? onAccept;

  RxBool loadingChangeStatus = false.obs;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 7),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        onTap: onTap ?? () {},
        title: Container(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text(
            studentName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1,
            ),
          ),
        ),
        subtitle: Text(
          "${'Status'.tr}: ${status.name.tr}",
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: status == ApplicantStatusEnum.accepted
                ? Colors.green
                : status == ApplicantStatusEnum.rejected
                    ? Colors.red
                    : AppColors.primary2,
          ),
        ),
        leading: CircleAvatar(
          radius: 22,
          child: CustomImageView(
            imagePath: photo ?? ImageConstant.personIcon,
            placeHolder: ImageConstant.personIcon,
            border: Border.all(
                width: 0.5, color: isDarkMode? Colors.white : Colors.black),
            radius: BorderRadius.circular(26),
            width: 104,
            height: 104,
            fit: photo != null ? BoxFit.cover : null,
            padding: photo != null ? null : const EdgeInsets.all(2),
            color: isDarkMode && photo == null? AppDarkColors.iconColor : null,
          ),
        ),
        trailing: status != ApplicantStatusEnum.accepted
            ? Obx(() => CustomOutlinedButton(
                onPressed: () async {
                  loadingChangeStatus.value = true;
                  await onAccept?.call();
                  loadingChangeStatus.value = false;
                },
                isLoading: loadingChangeStatus.value,
                loadingIndicatorSize: 15,
                text: 'Accept',
                buttonTextStyle: TextStyle(color: isDarkMode? null : Colors.black),
              ))
            : null,
      ),
    );
  }
}
