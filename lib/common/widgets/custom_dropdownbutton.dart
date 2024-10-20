import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constant/app_colors.dart';

class CustomDropDownButton extends StatelessWidget {
  const CustomDropDownButton({
    super.key,
    required this.items,
    this.initialValue,
    this.onChange,
    this.hintText,
    this.hintStyle,
    this.textStyle,
    this.labelText,
    this.padding,
    this.margin = const EdgeInsets.only(top: 4),
    this.height = 48,
    this.validator,
    this.border,
    this.fillColor,
  });

  /// the item in items list must contain a map containing two fields: id and name
  final List<DropDownItemModel> items;

  // final TextEditingController controller;
  final void Function(Object? selectedValue)? onChange;

  final Object? initialValue;

  final String? hintText;

  final TextStyle? hintStyle;

  final TextStyle? textStyle;

  final String? labelText;

  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;

  final double? height;

  final FormFieldValidator<Object>? validator;

  final OutlineInputBorder? border;

  final Color? fillColor;


  @override
  Widget build(BuildContext context) {
    final defaultBorder = border ?? OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.border, width: 2.2),
    );
    
    return Container(
      padding: padding,
      margin: margin,
      child: Column(
        children: [
          DropdownButtonFormField(
            borderRadius: BorderRadius.circular(15),
            style: textStyle ?? Theme.of(Get.context!).textTheme.bodyMedium,
 
            isDense: true,
            isExpanded: true,
            value: initialValue,
            
            items: [
              ...items.map((e) {
                return DropdownMenuItem(
                  value: e.value,
                  child: Text(
                    e.text,
                    textAlign: TextAlign.center,
                  ),
                );
              })
            ],
            hint: Text(
              hintText?.tr ?? '',
              style: hintStyle ??
                  Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGrey1),
            ),
          
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ?? Colors.transparent,
 
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              labelText: labelText?.tr,
              labelStyle: Get.textTheme.labelSmall,
              enabledBorder: defaultBorder,
              focusedBorder: defaultBorder,
              border: defaultBorder,
              suffixIconConstraints: const BoxConstraints(
                  maxWidth: 32, maxHeight: 30),
            
            ),
            validator: validator,
            onChanged: (value) {
 
              onChange?.call(value);
            },
          ),
        ],
      ),
    );
  }
}

class DropDownItemModel {
  Object value;
  String text;
  DropDownItemModel({
    required this.value,
    required this.text,
  });
}
