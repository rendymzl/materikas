import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'controllers/statistic.controller.dart';

class DatePickerCard extends StatelessWidget {
  const DatePickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();

    return Obx(
      () {
        return Card(
          child: Column(
            children: [
              if (controller.selectedSection.value == 'daily')
                const Expanded(child: DatePickerDaily()),
              if (controller.selectedSection.value == 'weekly')
                Expanded(child: DatePickerWeekly(controller: controller)),
              if (controller.selectedSection.value == 'monthly')
                Expanded(child: DatePickerMonthly(controller: controller)),
              if (controller.selectedSection.value == 'yearly')
                Expanded(child: DatePickerYearly(controller: controller)),
            ],
          ),
        );
      },
    );
  }
}

class DatePickerDaily extends StatelessWidget {
  const DatePickerDaily({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.dailyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedDate: controller.initDate.value,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.single,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          controller.rangePickerHandle(args.value);
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
    return SizedBox(
      width: 300,
      height: 480,
      child: SfDateRangePicker(
        controller: controller.weeklyRangeController.value,
        navigationDirection: DateRangePickerNavigationDirection.vertical,
        navigationMode: DateRangePickerNavigationMode.scroll,
        headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
            textStyle: context.textTheme.bodyLarge),
        backgroundColor: Colors.white,
        enableMultiView: true,
        initialSelectedRange: controller.selectedWeeklyRange.value,
        monthViewSettings: const DateRangePickerMonthViewSettings(
          firstDayOfWeek: 1,
        ),
        selectionMode: DateRangePickerSelectionMode.range,
        minDate: DateTime(2000),
        maxDate: DateTime.now(),
        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
          PickerDateRange value = args.value;
          if (value.endDate == null) {
            controller.rangePickerHandle(value.startDate!);
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
      height: 480,
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
          controller.monthPickerHandle(args.value);
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
      height: 480,
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
          controller.yearPickerHandle(args.value);
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
