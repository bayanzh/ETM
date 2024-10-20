import 'package:e_training_mate/core/utils/helpers/app_helper.dart';
import 'package:e_training_mate/core/utils/logger.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constant/app_colors.dart';
import '../../student_courses/models/student_course_model.dart';

class ActivityPiechartWidget extends StatefulWidget {
  const ActivityPiechartWidget({super.key, required this.courses, this.isLoading = false});

  final List<StudentCourseModel> courses;
  final bool isLoading;

  @override
  State<StatefulWidget> createState() => ActivityPiechartWidgetState();
}

class ActivityPiechartWidgetState extends State<ActivityPiechartWidget> {
  int touchedIndex = -1;
  late bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    double height = 250;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity details".tr,
            style: TextStyle(
              color: isDarkMode? null : AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
      
          Row(
            children: [
              Flexible(
                child: SizedBox(
                  // color: Colors.grey[200],
                  height: 200,
                  width: Get.width * 0.5,
                  child: pieChartWidget,
                ),
              ),
              
              const SizedBox(width: 10),
      
              Flexible(
                child: SizedBox(
                  // color: Colors.grey[200],
                  height: 200,
                  width: Get.width * 0.5,
                  child: barChartWidget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get pieChartWidget {
    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              startDegreeOffset: 200,
              sectionsSpace: 3,
              centerSpaceRadius: 0,
              sections: showingPieChartSections(),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 170),
          decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            'Rate of accomplishment'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  List<PieChartSectionData> showingPieChartSections() {
    Logger.log("Count: ${widget.courses.length}");

    // مجموع نسب المشاهدة لجميع الكورسات
    final totalViewingRate =
        widget.courses.fold(0.0, (sum, course) => sum + course.viewingRate);

    final length = widget.courses.length;

    return List.generate(
      length,
      (i) {
        final isTouched = i == touchedIndex;

        double value = (widget.courses[i].viewingRate / totalViewingRate) * 100;
        value = value < 5 ? 3 : value;
        Logger.log("-- $i value: $value");

        double radius = (i == 0 ? 77 : 70) + (isTouched ? 10 : 0);

        return PieChartSectionData(
          color: AppHelper.generateLightColorFromId(
                  widget.courses[i].course.cDocId ?? 'aaddff').withOpacity(0.85),
          value: value,
          title: '',
          radius: radius,
        );
      },
    );
  }
  

  Widget get barChartWidget {
    return Column(
      children: [
        Expanded(
          child: BarChart(
            mainBarData(),
            swapAnimationDuration: const Duration(milliseconds: 250),
          ),
        ),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 170),
          decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            'Duration of use'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
          tooltipMargin: -10,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              (rod.toY - 1).toString(),
              const TextStyle(
                color: Colors.white, //widget.touchedBarColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) => SideTitleWidget(
              axisSide: meta.axisSide,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode? AppColors.primaryLight : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  List<BarChartGroupData> showingGroups() {
    Logger.log("Count: ${widget.courses.length}");

    // مجموع نسب المشاهدة لجميع الكورسات
    final totalViewingRate =
        widget.courses.fold(0.0, (sum, course) => sum + course.viewingRate);

    final length = widget.courses.length;

    return List.generate(length, (i) {
      double value = (widget.courses[i].viewingRate / totalViewingRate) * 100;
      value = value < 5 ? 3 : value;
      Logger.log("-- $i value: $value");

      return makeGroupData(
        i, value,
        isTouched: i == touchedIndex,
        // barColor: AppHelper.generateLightColorFromId(
        // widget.courses[i].course.cDocId ?? 'aaddff').withOpacity(0.85),
      );
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    List<int> showTooltips = const [],
  }) {
    barColor ??=  AppColors.primary;
    double width = isTouched? 22 : 20;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ? AppColors.bottomNavigationBar : barColor,
          width: width,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15))
          // backDrawRodData: BackgroundBarChartRodData(
          //   show: true,
          //   toY: 25,
          //   color: AppColors.bottomNavigationBar,
          // ),
        ),
      ],
      // showingTooltipIndicators: showTooltips,
    );
  }
}
