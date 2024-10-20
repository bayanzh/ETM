import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/utils/dialog_util.dart';
import '../../core/constant/app_colors.dart';
import 'custom_image_view.dart';

class CircleAvatarWidget extends StatelessWidget {
  final RxString imagePath;
  final String placeHolder;
  final Color? placeHolderColor;
  final Color? borderColor;
  final double size;
  final void Function()? onComplete;

  const CircleAvatarWidget({
    super.key,
    required this.imagePath,
    required this.placeHolder,
    this.placeHolderColor,
    this.borderColor,
    this.size = 130,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => Container(
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor ?? AppColors.textGrey1, width: 3),
          ),
          child: InkWell(
            onTap: imagePath.isNotEmpty? optionDialog : pickImage,
            borderRadius: BorderRadius.circular(size),
            child: imagePath.isEmpty
                ? CustomImageView(imagePath: placeHolder, color: placeHolderColor, width: size - 40, height: size - 40)
                : CustomImageView(
                    imagePath: imagePath.value,
                    radius: BorderRadius.circular(size),
                    width: size - 3,
                    height: size - 3,
                    fit: BoxFit.cover,
                  ),
          ),
        )),

        // -- camera icon widget
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size,
              width: size,
              alignment: AlignmentDirectional.bottomEnd,
              child: Container(
                width: 35,
                height: 35,
                margin: EdgeInsets.only(bottom: size * 0.1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary2,
                ),
                child: InkWell(
                    onTap: pickImage,
                    child: const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 22),

                  ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) imagePath.value = image.path;
    onComplete?.call();
  }

  void deleteImage() {
    imagePath.value = "";
    onComplete?.call();
  }

  Future optionDialog() async {
    return DialogUtil.showOptionsDialog([
      DialogOptionItem(text: "Change", onTap: pickImage),
      DialogOptionItem(
        text: "Delete",
        onTap: () async {
          final isConfirm= await DialogUtil.showDeleteDialog(message: "Are you sure you want to delete this photo?");
          if (isConfirm == true) deleteImage();
        },
        isDeleteOption: true,
      ),
    ]);
  }
}
