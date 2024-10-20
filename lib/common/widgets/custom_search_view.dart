import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/app_colors.dart';


class CustomSearchView extends StatelessWidget {
  CustomSearchView({
    super.key,
    this.alignment,
    this.width,
    this.scrollPadding,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.textStyle,
    this.textInputType = TextInputType.text,
    this.maxLines,
    this.hintText,
    this.hintStyle,
    this.labelText,
    this.labelStyle,
    this.prefix,
    this.prefixConstraints,
    this.suffix,
    this.suffixConstraints,
    this.contentPadding,
    this.borderDecoration,
    this.fillColor,
    this.filled = true,
    this.validator,
    this.onTap,
    this.onChanged,
    this.onSaved,
    this.isSearchForm = true,
    this.showClearIcon = true,
    this.alwaysShowClearIcon = false,
    this.readOnly = false,
    this.textCapitalization,
    this.removeFocusOnTapOutside = true,
    this.margin,
    this.secureText = false,
    this.textInputAction,
    this.onSubmitted,
  });

  final Alignment? alignment;

  final double? width;

  final TextEditingController? scrollPadding;

  final TextEditingController? controller;

  final FocusNode? focusNode;

  final bool? autofocus;

  final TextStyle? textStyle;

  final TextInputType? textInputType;

  final int? maxLines;

  final String? hintText;

  final TextStyle? hintStyle;
  
  final String? labelText;

  final TextStyle? labelStyle;

  final Widget? prefix;

  final BoxConstraints? prefixConstraints;

  final Widget? suffix;

  final BoxConstraints? suffixConstraints;

  final EdgeInsets? contentPadding;

  final InputBorder? borderDecoration;

  final Color? fillColor;

  final bool? filled;

  final FormFieldValidator<String>? validator;

  final void Function()? onTap;

  final Function(String)? onChanged;
  
  final void Function(String?)? onSaved;

  final bool isSearchForm;
  
  final bool showClearIcon;
  
  final bool alwaysShowClearIcon;

  final bool readOnly;

  final TextCapitalization? textCapitalization;

  final bool removeFocusOnTapOutside;

  final EdgeInsets? margin;

  final bool secureText;

  final TextInputAction? textInputAction;

  final void Function(String value)? onSubmitted;


  /// variable to show clear icon when the value is not empty,
  /// gave it an initial value of 'false' so that if there is no controller,
  /// the cleaning icon will be displayed permanently
  final RxBool isValueEmpty = false.obs;

  @override
  Widget build(BuildContext context) {
    isValueEmpty.value = controller?.text.isEmpty ?? false;

    controller?.addListener(() {
      isValueEmpty.value = controller?.text.isEmpty ?? false;
    });
    
    return alignment != null
        ? Align(alignment: alignment!, child: buildSearchViewWidget(context))
        : buildSearchViewWidget(context);
  }

  Widget buildSearchViewWidget(BuildContext context) {
    return Container(
        width: width ?? double.maxFinite,
        margin: margin,
        child: TextFormField(
          scrollPadding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
          controller: controller,
          readOnly: readOnly,
          focusNode: focusNode,
          onTap: onTap,
          onFieldSubmitted: onSubmitted,
          obscureText: secureText ,
          onTapOutside: removeFocusOnTapOutside? (event) {
            if (focusNode != null) {
              focusNode?.unfocus();
            } else {
              FocusManager.instance.primaryFocus?.unfocus();
            }
          } : null,
          textCapitalization: textCapitalization ?? TextCapitalization .none,
          keyboardType: textInputType,
          textInputAction: textInputAction ?? (isSearchForm? TextInputAction.search : null),
          autofocus: autofocus!,
          style: textStyle ?? Theme.of(Get.context!).textTheme.bodyMedium,
          maxLines: maxLines ?? 1,
          decoration: buildDecoration(context),
          validator: validator,
          onChanged: onChanged,
          onSaved: onSaved,
        ),
      );
  }


  InputDecoration buildDecoration(BuildContext context) {
    final defaultBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.border, width: 2.2),
    );
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InputDecoration(
      hintText: hintText?.tr ?? "Write here".tr,
      hintStyle: hintStyle ??
          Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey1,
              ),
      labelText: labelText?.tr,
      labelStyle: labelStyle ?? Theme.of(Get.context!).textTheme.bodyLarge,
      prefixIcon: prefix ??
          (isSearchForm
              ? Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  child: const Icon(
                    Icons.search_rounded,
                  ),
                )
              : null),
      prefixIconConstraints: prefixConstraints ?? const BoxConstraints(maxHeight: 56),
      suffixIcon: suffix ??
          (showClearIcon
              ? Obx(() => Container(
                    height: 30,
                    margin: const EdgeInsets.only(right: 8),
                    child: isValueEmpty.value && !alwaysShowClearIcon
                        ? null
                        : IconButton(
                            style: IconButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () {
                              controller?.clear();
                              onChanged?.call(controller?.text ?? "");
                            },
                            icon: Icon(Icons.clear, color: Colors.grey.shade600),
                          ),
                  ))
              : null),
      suffixIconConstraints: suffixConstraints ?? const BoxConstraints(maxHeight: 50, maxWidth: 35),
      isDense: true,
      contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(16, 13, 16, 13),
      fillColor: fillColor,
      filled: filled,
      border: borderDecoration ?? defaultBorder,
      enabledBorder: borderDecoration ?? defaultBorder,
      focusedBorder: borderDecoration ?? defaultBorder
        .copyWith(borderSide: BorderSide(color: isDarkMode? AppColors.primaryLight : AppColors.primary, width: 2)),
    );
  }
}
