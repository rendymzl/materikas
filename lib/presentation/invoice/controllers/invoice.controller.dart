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
  late final paidInv = _invoiceService.paidInv;
  late final debtInv = _invoiceService.debtInv;
  late InvoiceModel initInvoice;

  // var searchQuery = ''.obs;
  var displayedItems = <InvoiceModel>[].obs; // Data yang ditampilkan saat ini
  var isLoading = false.obs; // Untuk memantau status loading
  var hasMore = true.obs; // Memantau apakah masih ada data lagi
  var page = 1; // Halaman data saat ini

  final int limit = 20; // Batas data per halaman

  @override
  void onInit() {
    super.onInit();
    loadMore(); // Memuat data awal
    // ever(
    //     searchQuery,
    //     (value) => debounce(searchQuery, (value) {
    //           filterInvoices(value);
    //           print(value);
    //         }, time: const Duration(seconds: 1)));
  }

  void loadMore() {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Ambil data dari list yang ada berdasarkan pagination
    int startIndex = (page - 1) * limit;
    int endIndex = startIndex + limit;

    List<InvoiceModel> newData = paidInv.sublist(
        startIndex, endIndex > paidInv.length ? paidInv.length : endIndex);

    if (newData.isEmpty) {
      hasMore.value = false; // Tidak ada data lagi
    } else {
      displayedItems
          .addAll(newData); // Tambahkan data baru ke list yang ditampilkan
      page++; // Naikkan halaman
    }
    print(displayedItems.length);
    isLoading.value = false;
  }

  void filterInvoices(dynamic searchValue) {
    if (searchValue is String) {
      _invoiceService.searchInvoicesByName(searchValue);
    } else if (searchValue is PickerDateRange) {
      _invoiceService.searchInvoicesByPickerDateRange(searchValue);
    }
    hasMore.value = true;
    page = 1;

    debounce(searchValue, (value) {
      if (value == '') {
        displayedItems.clear();
        loadMore();
      } else {
        displayedItems.assignAll(foundInvoices);
      }
      print(value);
    }, time: const Duration(seconds: 1));
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

  destroyHandle(InvoiceModel invoice) async {
    await _invoiceService.delete(invoice.id!);
  }
}
