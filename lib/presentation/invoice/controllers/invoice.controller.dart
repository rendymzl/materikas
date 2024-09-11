import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';

class InvoiceController extends GetxController {
  late final InvoiceService _invoiceService = Get.find();
  late final invoices = _invoiceService.invoices;
  late final foundInvoices = _invoiceService.foundInvoices;
  late InvoiceModel initInvoice;

  void filterInvoices(dynamic searchValue) {
    if (searchValue is String) {
      _invoiceService.searchInvoicesByName(searchValue);
    } else if (searchValue is PickerDateRange) {
      _invoiceService.searchInvoicesByPickerDateRange(searchValue);
    }
  }

  final startFilteredDate = ''.obs;
  final endFilteredDate = ''.obs;
  final displayFilteredDate = ''.obs;
  final dateIsSelected = false.obs;
  final selectedFilteredDate = DateTime.now().obs;

  handleFilteredDate(BuildContext context) {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: Column(
        children: [
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$startFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Text('sampai',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  '$endFilteredDate',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold),
                ),
              ],
            );
          }),
          SizedBox(
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
              initialSelectedDate: selectedFilteredDate.value,
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: DateTime(2000),
              maxDate: DateTime.now(),
              showActionButtons: true,
              cancelText: 'Batal',
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                startFilteredDate.value =
                    DateFormat('dd MMMM y', 'id').format(args.value.startDate!);
                if (args.value.endDate != null) {
                  endFilteredDate.value =
                      DateFormat('dd MMMM y', 'id').format(args.value.endDate!);
                }
              },
              onCancel: () => Get.back(),
              onSubmit: (value) {
                if (value is PickerDateRange) {
                  if (value.endDate != null) {
                    final newSelectedPickerRange = PickerDateRange(
                        value.startDate,
                        value.endDate!.add(const Duration(days: 1)));

                    selectedFilteredDate.value =
                        newSelectedPickerRange.startDate!;
                    displayFilteredDate.value =
                        '$startFilteredDate sampai $endFilteredDate';
                    filterInvoices(newSelectedPickerRange);
                    dateIsSelected.value = true;
                    Get.back();
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void clearHandle() async {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    displayFilteredDate.value = '';
    dateIsSelected.value = false;
    filterInvoices('');
  }
}
