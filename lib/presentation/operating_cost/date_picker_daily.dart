import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'controllers/operating_cost.controller.dart';

class DatePickerDaily extends StatelessWidget {
  const DatePickerDaily({super.key, this.isPopUp = false});

  final bool isPopUp;

  @override
  Widget build(BuildContext context) {
    OperatingCostController controller = Get.find();
    return isPopUp
        ? InkWell(
            onTap: () async => showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  child: SizedBox(
                    width: 300,
                    height: 480,
                    child: SfDateRangePicker(
                      navigationDirection:
                          DateRangePickerNavigationDirection.vertical,
                      navigationMode: DateRangePickerNavigationMode.scroll,
                      headerStyle: DateRangePickerHeaderStyle(
                          backgroundColor: Colors.white,
                          textStyle: context.textTheme.bodyLarge),
                      backgroundColor: Colors.white,
                      enableMultiView: true,
                      initialSelectedDate: controller.selectedDate.value,
                      monthViewSettings: const DateRangePickerMonthViewSettings(
                        firstDayOfWeek: 1,
                      ),
                      selectionMode: DateRangePickerSelectionMode.single,
                      minDate: DateTime(2000),
                      maxDate: DateTime.now(),
                      showActionButtons: true,
                      cancelText: 'Batal',
                      onCancel: () => Get.back(),
                      onSubmit: (p0) async {
                        controller.rangePickerHandle(p0 as DateTime);
                        // controller.selectedDate.value = p0 as DateTime;
                        // displayDate.value =
                        //     DateFormat('dd MMMM y', 'id').format(p0);
                        Get.back();
                      },
                      // onSelectionChanged:
                      //     (DateRangePickerSelectionChangedArgs args) {
                      //   controller.rangePickerHandle(args.value);
                      // },
                    ),
                  ),
                );
              },
              // child: Text('Pilih Tanggal'),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Obx(
                () => Text(
                  DateFormat('dd MMMM y', 'id')
                      .format(controller.selectedDate.value),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          )

        //  ElevatedButton(
        //     onPressed: () {
        // Get.defaultDialog(
        //   title: 'Pilih Tanggal',
        //   backgroundColor: Colors.white,
        //   content: SizedBox(
        //     width: 400,
        //     height: 350,
        //     child: SfDateRangePicker(
        //       headerStyle: DateRangePickerHeaderStyle(
        //           backgroundColor: Colors.white,
        //           textStyle: context.textTheme.bodyLarge),
        //       showNavigationArrow: true,
        //       backgroundColor: Colors.white,
        //       monthViewSettings: const DateRangePickerMonthViewSettings(
        //         firstDayOfWeek: 1,
        //       ),
        //       initialSelectedDate: DateTime.now(),
        //       minDate: DateTime(2000),
        //       maxDate: DateTime.now(),
        //       showActionButtons: true,
        //       cancelText: 'Batal',
        //       onCancel: () => Get.back(),
        //       onSubmit: (p0) async {
        //         selectedDate.value = p0 as DateTime;
        //         displayDate.value =
        //             DateFormat('dd MMMM y', 'id').format(p0);
        //         Get.back();
        //       },
        //     ),
        //   ),
        // );

        //     showDialog(
        //       context: context,
        //       builder: (context) {
        //         return Dialog(
        //           child: SizedBox(
        //             width: 300,
        //             height: 480,
        //             child: SfDateRangePicker(
        //               navigationDirection:
        //                   DateRangePickerNavigationDirection.vertical,
        //               navigationMode: DateRangePickerNavigationMode.scroll,
        //               headerStyle: DateRangePickerHeaderStyle(
        //                   backgroundColor: Colors.white,
        //                   textStyle: context.textTheme.bodyLarge),
        //               backgroundColor: Colors.white,
        //               enableMultiView: true,
        //               initialSelectedDate: controller.selectedDate.value,
        //               monthViewSettings:
        //                   const DateRangePickerMonthViewSettings(
        //                 firstDayOfWeek: 1,
        //               ),
        //               selectionMode: DateRangePickerSelectionMode.single,
        //               minDate: DateTime(2000),
        //               maxDate: DateTime.now(),
        //               showActionButtons: true,
        //               cancelText: 'Batal',
        //               onCancel: () => Get.back(),
        //               onSubmit: (p0) async {
        //                 controller.rangePickerHandle(p0 as DateTime);
        //                 // controller.selectedDate.value = p0 as DateTime;
        //                 // displayDate.value =
        //                 //     DateFormat('dd MMMM y', 'id').format(p0);
        //                 Get.back();
        //               },
        //               // onSelectionChanged:
        //               //     (DateRangePickerSelectionChangedArgs args) {
        //               //   controller.rangePickerHandle(args.value);
        //               // },
        //             ),
        //           ),
        //         );
        //       },
        //       // child: Text('Pilih Tanggal'),
        //     );
        //   },
        //   child: Obx(() => Text(controller.displayDate.value)),
        // )
        : SizedBox(
            width: 300,
            height: 480,
            child: SfDateRangePicker(
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
                controller.rangePickerHandle(args.value);
              },
            ),
          );
  }
}
