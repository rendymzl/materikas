import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'date_picker_widget_controller.dart';

//! view
class DatePickerWidget extends GetView<DatePickerController> {
  const DatePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DatePickerController());
    return InkWell(
      onTap: () async => controller.handleDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Obx(
          () => Text(
            DateFormat('dd MMMM y', 'id').format(controller.selectedDate.value),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
