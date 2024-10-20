import 'package:e_training_mate/common/widgets/custom_outlined_button.dart';
import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/constant/app_colors.dart';

class TitledContentList extends StatelessWidget {
  const TitledContentList({
    super.key,
    required this.title,
    this.children,
    this.content,
    this.direction = Axis.horizontal,
    this.showMore = true,
    this.onTapShowMore,
    this.listHeight,
    this.listWidth,
    this.titleStyle,
    this.showMoreStyle,
    this.useScrollWidget = true,
    this.contentBackColor,
    this.isLoading = false,
    this.margin,
    this.shimmerWidget,
    this.shimmerCount = 2,
    this.shimmerContainersColor,
  });

  final String title;
  final List<Widget>? children;
  final Widget? content;
  final Axis direction;
  final bool showMore;
  final void Function()? onTapShowMore;
  final double? listHeight;
  final double? listWidth;
  final TextStyle? titleStyle;
  final TextStyle? showMoreStyle;
  final bool useScrollWidget;
  final Color? contentBackColor;
  final bool isLoading;
  final EdgeInsets? margin;
  final Widget? shimmerWidget;
  final int shimmerCount;
  final Color? shimmerContainersColor;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // -- Title and show more button
        Skeletonizer(
          enabled: isLoading,
          child: Padding(
            padding: margin ?? const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.tr,
                  style: titleStyle ??
                      TextStyle(
                        color: isDarkMode? null : AppColors.textBlueBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                if (showMore)
                  CustomOutlinedButton(
                    onPressed: onTapShowMore,
                    text: "See more",
                    buttonStyle: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                    ),
                    buttonTextStyle: showMoreStyle ??
                        TextStyle(
                          fontSize: 14,
                          color: AppColors.button,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
              ],
            ),
          ),
        ),
        Skeletonizer(
          enabled: isLoading && shimmerWidget != null,
          containersColor: shimmerContainersColor,
          child: Container(
            margin: margin ?? const EdgeInsets.symmetric(horizontal: 10),
            color: contentBackColor,
            height: listHeight,
            width: listWidth,
            child: isLoading && shimmerWidget == null
                ? AppHelper.custumProgressIndecator()
                : _buildContentWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentWidget() {
    if (children != null) {
      return useScrollWidget
          ? _buildScrolledContent()
          : _buildUnScrolledContent();
    } else if (content != null) {
      return isLoading && shimmerWidget != null ? shimmerWidget! : content!;
    }
    return const SizedBox.shrink();
  }

  Widget _buildScrolledContent() {
    return ListView(
      primary: false,
      scrollDirection: direction,
      children: isLoading && shimmerWidget != null
          ? List.generate(shimmerCount, (i) => shimmerWidget!)
          : children!,
    );
  }

  Widget _buildUnScrolledContent() {
    if (direction == Axis.vertical) {
      return Column(
        children: isLoading && shimmerWidget != null
            ? List.generate(shimmerCount, (i) => shimmerWidget!)
            : children!,
      );
    } else {
      return Row(
        children: isLoading && shimmerWidget != null
            ? List.generate(shimmerCount, (i) => shimmerWidget!)
            : children!,
      );
    }
  }
}
