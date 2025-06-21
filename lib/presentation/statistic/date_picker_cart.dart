import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'controllers/statistic.controller.dart';

class DatePickerCard extends StatelessWidget {
  const DatePickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticController>();

    return Obx(() {
      if (controller.selectedSection.value == 'daily') {
        return DatePickerDaily();
      } else if (controller.selectedSection.value == 'weekly') {
        return DatePickerWeekly(controller: controller);
      } else if (controller.selectedSection.value == 'monthly') {
        return DatePickerMonthly(controller: controller);
      } else if (controller.selectedSection.value == 'yearly') {
        return DatePickerYearly(controller: controller);
      } else {
        return Container();
      }
    });
  }
}

class DatePickerDaily extends StatelessWidget {
  const DatePickerDaily({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return SizedBox(
      width: 300,
      height: 280,
      child: SfDateRangePicker(
        controller: controller.dailyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedDate: DateTime.now(),
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.single,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.dailyPickerHandle(args.value);
        },
      ),
    );
  }
}

class DatePickerWeekly extends StatelessWidget {
  const DatePickerWeekly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    DateTime endDate =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime startDate = endDate.subtract(const Duration(days: 7));
    return SizedBox(
      width: 300,
      height: 200,
      child: SfDateRangePicker(
        controller: controller.weeklyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedRange: PickerDateRange(startDate, endDate),
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.range,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          PickerDateRange value = args.value;
          if (value.endDate == null) {
            controller.weeklyPickerHandle(value.startDate!);
          }
        },
      ),
    );
  }
}

class DatePickerMonthly extends StatelessWidget {
  const DatePickerMonthly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: SfDateRangePicker(
        controller: controller.monthlyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        // enableMultiView: true,
        view: DateRangePickerView.year,
        allowViewNavigation: false,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.monthlyPickerHandle(args.value);
        },
      ),
    );
  }
}

class DatePickerYearly extends StatelessWidget {
  const DatePickerYearly({
    super.key,
    required this.controller,
  });

  final StatisticController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: SfDateRangePicker(
        controller: controller.yearlyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        view: DateRangePickerView.decade,
        allowViewNavigation: false,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.yearlyPickerHandle(args.value);
        },
      ),
    );
  }
}

class DisplayDataListTile extends StatelessWidget {
  const DisplayDataListTile({
    super.key,
    required this.controller,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.subtitle3,
  });

  final StatisticController controller;
  final String title;
  final String subtitle1;
  final String subtitle2;
  final Widget subtitle3;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(title, style: context.textTheme.bodySmall),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(subtitle1,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 2),
          Text(subtitle2, style: context.textTheme.bodySmall),
          const SizedBox(height: 2),
          subtitle3,
        ],
      ),
    );
  }
}
