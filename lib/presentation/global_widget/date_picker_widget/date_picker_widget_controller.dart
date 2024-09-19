//! controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePickerController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateFormat('dd MMMM y', 'id').format(DateTime.now()).obs;
  final displayTime = DateFormat('HH:mm', 'id').format(DateTime.now()).obs;

  void asignDateTime(DateTime date) {
    selectedDate.value = date;
    selectedTime.value = TimeOfDay(hour: date.hour, minute: date.minute);
    displayDate.value = DateFormat('dd MMMM y', 'id').format(date);
    displayTime.value = DateFormat('HH:mm', 'id').format(
        DateTime(date.year, date.month, date.day, date.hour, date.minute));
  }

  void handleDate(BuildContext context) async {
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 400,
        height: 350,
        child: SfDateRangePicker(
          headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: Colors.white,
              textStyle: context.textTheme.bodyLarge),
          showNavigationArrow: true,
          backgroundColor: Colors.white,
          monthViewSettings: const DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
          ),
          initialSelectedDate: selectedDate.value,
          minDate: DateTime(2000),
          maxDate: DateTime.now(),
          showActionButtons: true,
          cancelText: 'Batal',
          onCancel: () => Get.back(),
          onSubmit: (p0) async {
            selectedDate.value = p0 as DateTime;
            displayDate.value = DateFormat('dd MMMM y', 'id').format(p0);
            Get.back();
          },
        ),
      ),
    );
  }

  void handleTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (pickedTime != null) {
      selectedTime.value = pickedTime;
      selectedDate.value = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      displayTime.value = DateFormat('HH:mm', 'id').format(selectedDate.value);
    }
  }
}
