import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'date_picker_widget_controller.dart';

class DatePickerWidget extends GetView<DatePickerController> {
  const DatePickerWidget({super.key, required this.dateTime});
  final Rx<DateTime?> dateTime;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DatePickerController());
    controller.asignDateTime(dateTime.value!);
    // dateTime = controller.selectedDate;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () async {
            await controller.handleDate(context, dateTime);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Obx(
              () => Text(
                DateFormat('dd MMM y', 'id')
                    .format(controller.selectedDate.value),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () async {
            await controller.handleTime(context, dateTime);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Obx(
              () => Text(
                controller.displayTime.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
