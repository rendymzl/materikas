import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';

class InvoiceController extends GetxController {
  late final AuthService _authService = Get.find();
  late final InvoiceService invoiceService = Get.find();
  late InvoiceModel initInvoice;

  final formKey = GlobalKey<FormState>();

  final editInvoice = true.obs;
  final returnInvoice = true.obs;
  final paymentInvoice = true.obs;
  final destroyInvoice = true.obs;

  @override
  void onInit() async {
    await fetch();

    // Listen perubahan searchQuery atau selectedCategory
    everAll([invoiceService.updatedCount], (_) async {
      await fetch();
    });
    editInvoice.value = await _authService.checkAccess('editInvoice');
    returnInvoice.value = await _authService.checkAccess('returnInvoice');
    paymentInvoice.value = await _authService.checkAccess('paymentInvoice');
    destroyInvoice.value = await _authService.checkAccess('destroyInvoice');
    super.onInit();
  }

  Future<void> fetch() async {
    if (isLoadingPaid.value) return;

    hasMorePaid.value = true;
    hasMoreDebt.value = true;
    displayedItemsPaid.clear();
    displayedItemsDebt.clear();

    final startTime = DateTime.now();

    await invoiceService.fetch(
      listPaid: displayedItemsPaid,
      listDebt: displayedItemsDebt,
      search: searchQuery.value,
      pickerDateRange: searchDateQuery.value,
      methodPayment: methodPayment.value,
    );
    offsetPaid = displayedItemsPaid.length;
    offsetDebt = displayedItemsDebt.length;
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print('Waktu pengambilan data $offsetPaid: ${duration.inMilliseconds} ms');
  }

  //!PAID
  var displayedItemsPaid = <InvoiceModel>[].obs;
  var isLoadingPaid = false.obs;
  var hasMorePaid = true.obs;
  int offsetPaid = 0;

  //!DEBT
  var displayedItemsDebt = <InvoiceModel>[].obs;
  var isLoadingDebt = false.obs;
  var hasMoreDebt = true.obs;
  int offsetDebt = 0;

  final int limit = 15;

  var searchQuery = ''.obs;
  var searchDateQuery = Rx<PickerDateRange?>(null);
  var methodPayment = ''.obs;

  Future<void> fetchPaid({bool isClean = false}) async {
    if (isLoadingPaid.value) return;
    // isLoadingPaid.value = true;

    if (isClean) {
      hasMorePaid.value = true;
      offsetPaid = 0;
      displayedItemsPaid.clear();
    }

    if (!hasMorePaid.value) return;
    final startTime = DateTime.now();

    List<InvoiceModel> results = await invoiceService.loadMore(
      isPaid: true,
      limit: limit,
      offset: offsetPaid,
      search: searchQuery.value,
      pickerDateRange: searchDateQuery.value,
      methodPayment: methodPayment.value,
    );

    // if (invoiceService.isFiltered()) {
    //   hasMorePaid.value = false;
    //   displayedItemsPaid.assignAll(invoiceService.filteredPaidInv.length > 50
    //       ? invoiceService.filteredPaidInv.sublist(0, 50)
    //       : invoiceService.filteredPaidInv);
    // } else {
    if (results.isEmpty || offsetPaid > 200) {
      hasMorePaid.value = false;
    } else {
      displayedItemsPaid.addAll(results);
      offsetPaid += limit;
    }
    // }

    isLoadingPaid.value = false;
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print('Waktu pengambilan data $offsetPaid: ${duration.inMilliseconds} ms');
  }

  Future<void> fetchDebt({bool isClean = false}) async {
    if (isLoadingDebt.value) return;
    // isLoadingDebt.value = true;

    if (isClean) {
      hasMoreDebt.value = true;
      offsetDebt = 0;
      displayedItemsDebt.clear();
    }

    if (!hasMoreDebt.value) return;
    final startTime = DateTime.now();

    List<InvoiceModel> results = await invoiceService.loadMore(
      isPaid: false,
      limit: limit,
      offset: offsetDebt,
      search: searchQuery.value,
      pickerDateRange: searchDateQuery.value,
      methodPayment: methodPayment.value,
    );

    // if (invoiceService.isFiltered()) {
    //   hasMoreDebt.value = false;
    //   displayedItemsDebt.assignAll(invoiceService.filteredDebtInv.length > 50
    //       ? invoiceService.filteredDebtInv.sublist(0, 50)
    //       : invoiceService.filteredDebtInv);
    // } else {
    if (results.isEmpty) {
      hasMoreDebt.value = false;
    } else {
      displayedItemsDebt.addAll(results);
      offsetDebt += limit;
    }
    // }

    isLoadingDebt.value = false;
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    print('Waktu pengambilan data $offsetDebt: ${duration.inMilliseconds} ms');
  }

  bool isFiltered() {
    return (searchQuery.isNotEmpty ||
        searchDateQuery.value != null ||
        methodPayment.isNotEmpty);
  }
  // Future<void> resetScroll() async {
  //   offsetPaid = 0;
  //   offsetDebt = 0;
  //   hasMorePaid.value = true;
  //   hasMoreDebt.value = true;
  //   displayedItemsPaid.clear();
  //   displayedItemsDebt.clear();

  //   await fetchPaid();
  //   await fetchDebt();
  // }

  Timer? debounceTimer;
  void filterInvoices(dynamic searchValue) async {
    if (searchValue is String) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        if (formKey.currentState!.validate()) {
          searchQuery.value = searchValue;
          await fetchPaid(isClean: true);
          await fetchDebt(isClean: true);
        }
      });
    } else if (searchValue is PickerDateRange) {
      searchDateQuery.value = searchValue;
      await fetchPaid(isClean: true);
      await fetchDebt(isClean: true);
    }
  }

  final startFilteredDate = ''.obs;
  final endFilteredDate = ''.obs;
  final displayFilteredDate = ''.obs;
  final dateIsSelected = false.obs;
  final selectedFilteredDate = DateTime.now().obs;

  void paymentMethodHandleCheckBox(String method) async {
    methodPayment.value == method
        ? methodPayment.value = ''
        : methodPayment.value = method;
    await fetchPaid(isClean: true);
    await fetchDebt(isClean: true);
  }

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
                  // if (value.endDate != null) {
                  final newSelectedPickerRange = PickerDateRange(
                      value.startDate,
                      value.endDate != null
                          ? value.endDate!.add(const Duration(days: 1))
                          : value.startDate!.add(const Duration(days: 1)));

                  selectedFilteredDate.value =
                      newSelectedPickerRange.startDate!;
                  displayFilteredDate.value = value.endDate != null
                      ? '$startFilteredDate sampai $endFilteredDate'
                      : '$startFilteredDate';
                  filterInvoices(newSelectedPickerRange);
                  dateIsSelected.value = true;
                  Get.back();
                  // }
                }
                // if (value is PickerDateRange) {
                //   if (value.endDate != null) {
                //     final newSelectedPickerRange = PickerDateRange(
                //         value.startDate,
                //         value.endDate!.add(const Duration(days: 1)));

                //     selectedFilteredDate.value =
                //         newSelectedPickerRange.startDate!;
                //     displayFilteredDate.value =
                //         '$startFilteredDate sampai $endFilteredDate';
                //     filterInvoices(newSelectedPickerRange);
                //     dateIsSelected.value = true;
                //     Get.back();
                //   }
                // }
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
    searchDateQuery.value = null;
    // filterInvoices('');
  }

  destroyHandle(InvoiceModel invoice) async {
    invoice.removeAt.value = DateTime.now();

    if (DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        .isAtSameMomentAs(DateTime(invoice.initAt.value!.year,
            invoice.initAt.value!.month, invoice.initAt.value!.day))) {
      invoice.appBillAmount.value = 0;
    }
    await invoiceService.update(invoice);
  }
}
