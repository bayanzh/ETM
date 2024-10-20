import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../common/header/app_header_with_profile.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constant/app_colors.dart';
import '../controllers/home_controller.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  HomeController get controller => Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderWithProfile(
        name: controller.currentUser.value?.displayName ?? "",
        photo: controller.currentUser.value?.photoURL,
      ),
      body: ListView(
        shrinkWrap: true,
        // padding: const EdgeInsets.symmetric(horizontal: 20),
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Obx(() =>
          // Positioned(top: 10, child: SizedBox.shrink()),
          Transform.translate(
            offset: const Offset(0, -15),
            child: WeakCalenderWidget(
              focusedDay: controller.focusedDay.value,
            ),
          ),
        ],
      ),
    );
  }
}

class WeakCalenderWidget extends StatefulWidget {
  final DateTime focusedDay;
  final bool headerVisible;
  final void Function(DateTime, DateTime)? onDaySelected;
  const WeakCalenderWidget({
    super.key,
    required this.focusedDay,
    this.headerVisible = false,
    this.onDaySelected,
  });

  @override
  State<WeakCalenderWidget> createState() => _WeakCalenderWidgetState();
}

class _WeakCalenderWidgetState extends State<WeakCalenderWidget> {
  HomeController get controller => Get.find();
  late DateTime focusedDay;

  @override
  void initState() {
    focusedDay = widget.focusedDay;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final monthString = DateFormat('MMM').format(focusedDay).toUpperCase();
    
    final nowDate =  DateTime.now();
    String selectedDayString;
    if (focusedDay.day == nowDate.day){
      selectedDayString = "Today";
    } else if (focusedDay.difference(nowDate).inDays == 1){
      selectedDayString = "Tomorrow";
    } else if (focusedDay.difference(nowDate).inDays == -1){
      selectedDayString = "Yesterday";
    } else {
      selectedDayString = DateFormat('EEEE').format(focusedDay);
    }

    DateTime startOfWeek = _getFirstDayOfWeek(DateTime.now());
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    Logger.log(startOfWeek);

    return Column(
      children: [
        // -- day, month, year and day name row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // -- day, month and year row
              Row(
                children: [
                  Text(
                    focusedDay.day.toString(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    textScaler: const TextScaler.linear(1.25),
                  ),

                  const SizedBox(width: 4),
                  Column(
                    children: [
                      Text(monthString,
                        style: const TextStyle(height: 1.25),
                      ),
                      Text(focusedDay.year.toString()),
                    ],
                  ),
                ],
              ),
              
              // const Spacer(),
              // -- day name
              Container(
                margin: const EdgeInsets.only(top: 5),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.lightGreen,
                ),
                child: Text(selectedDayString,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
        const SizedBox(height: 15),
        
        // -- weak calender widget
        TableCalendar(
          firstDay: startOfWeek,
          lastDay: endOfWeek,
          startingDayOfWeek: StartingDayOfWeek.saturday,
          focusedDay: focusedDay,
          calendarFormat: CalendarFormat.week,
          headerVisible: widget.headerVisible,
          selectedDayPredicate: (day) {
            return isSameDay(controller.selectedDay.value, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            controller.selectedDay.value = selectedDay;
            setState(() {
              this.focusedDay = focusedDay;
            });
            widget.onDaySelected?.call(selectedDay, focusedDay);
          },
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: true,
            selectedDecoration: BoxDecoration(
              color: Color(0xfffe8d8d),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
        
      
    );
  }

  DateTime _getFirstDayOfWeek(DateTime date) {
    // Adjust to start the week on Saturday
    final daysToSubtract = (date.weekday - DateTime.saturday + 7) % 7;
    // final daysToSubtract = date.weekday + 4;
    Logger.log("Weekend: ${date.weekday}");
    Logger.log(daysToSubtract);
    return date.subtract(Duration(days: daysToSubtract));
  }
}
