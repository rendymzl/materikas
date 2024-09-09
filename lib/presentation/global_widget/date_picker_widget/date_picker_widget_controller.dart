//! controller
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePickerController extends GetxController {
  final selectedDate = DateTime.now().obs;
  final displayDate = DateFormat('dd MMMM y', 'id').format(DateTime.now()).obs;

  void asignDateTime(DateTime dateTime) {
    selectedDate.value = dateTime;
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
            displayDate.value = p0.toString();
            // invoiceId.value = await generateInvoice(selectedCustomer.value);
            Get.back();
          },
        ),
      ),
    );
  }
}
