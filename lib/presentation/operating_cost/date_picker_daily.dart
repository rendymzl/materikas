import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'controllers/operating_cost.controller.dart';

class DatePickerDaily extends StatelessWidget {
  const DatePickerDaily({super.key});

  @override
  Widget build(BuildContext context) {
    OperatingCostController controller = Get.find();
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
