import 'dart:async';

// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:powersync/sqlite3.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';

// Future<List<InvoiceModel>> convertToInvoiceModel(
//     List<Map<String, dynamic>> maps) async {
//   return maps.map((e) => InvoiceModel.fromJson(e)).toList();
// }

class InvoiceController extends GetxController {
  late final AuthService _authService = Get.find();
  late final InvoiceService invoiceService = Get.find();
  late InvoiceModel displayInvoice;
  // late InvoiceModel editedInvoice;
  final formKey = GlobalKey<FormState>();

  final isDebt = false.obs;

  final editInvoice = true.obs;
  final returnInvoice = true.obs;
  final paymentInvoice = true.obs;
  final destroyInvoice = true.obs;

  int updatedPaidCount = 0;
  int updatedDebtCount = 0;

  @override
  void onInit() async {
    // displayedItemsPaid.value = invoiceService.itemsPaid;
    // displayedItemsDebt.value = invoiceService.itemsDebt;
    displayedItemsPaid.assignAll(invoiceService.itemsPaid);
    displayedItemsDebt.assignAll(invoiceService.itemsDebt);
    // await fetch(isClean: true);
    // updatedPaidCount = invoiceService.updatedPaidCount.value;
    // updatedDebtCount = invoiceService.updatedDebtCount.value;
    // offsetPaid = 15;
    // offsetDebt = 15;
    // Listen perubahan searchQuery atau selectedCategory
    everAll([
      invoiceService.itemsPaid,
      invoiceService.itemsDebt,
      searchQuery,
      searchDateQuery,
      methodPayment
    ], (_) async {
      if (isFiltered()) {
        print('isFiltered');
        var paid = await fetchPaid(isClean: true);
        var debt = await fetchDebt(isClean: true);
        // displayedItemsPaid.value = paid;
        // displayedItemsDebt.value = debt;
        displayedItemsPaid.assignAll(paid);
        displayedItemsDebt.assignAll(debt);
      } else {
        print('noFilter');
        displayedItemsPaid.assignAll(invoiceService.itemsPaid);
        displayedItemsDebt.assignAll(invoiceService.itemsDebt);
        // displayedItemsPaid.value = invoiceService.itemsPaid;
        // displayedItemsDebt.value = invoiceService.itemsDebt;
      }
    });
    editInvoice.value = await _authService.checkAccess('editInvoice');
    returnInvoice.value = await _authService.checkAccess('returnInvoice');
    paymentInvoice.value = await _authService.checkAccess('paymentInvoice');
    destroyInvoice.value = await _authService.checkAccess('destroyInvoice');
    super.onInit();
  }

  //!PAID
  final displayedItemsPaid = <InvoiceModel>[].obs;
  // final initItemsPaid = <InvoiceModel>[].obs;
  final isLoadingPaid = false.obs;
  final hasMorePaid = true.obs;
  int offsetPaid = 0;

  //!DEBT
  final displayedItemsDebt = <InvoiceModel>[].obs;
  // final initItemsDebt = <InvoiceModel>[].obs;
  final isLoadingDebt = false.obs;
  final hasMoreDebt = true.obs;
  int offsetDebt = 0;

  final int limit = 15;

  final searchQuery = ''.obs;
  final searchDateQuery = Rx<PickerDateRange?>(null);
  final methodPayment = ''.obs;

  Future<List<InvoiceModel>> fetchPaid({bool isClean = false}) async {
    if (isClean) {
      hasMorePaid.value = true;
      offsetPaid = 0;
    }

    if (hasMorePaid.value) {
      final results = await invoiceService.fetch(
        isPaid: true,
        limit: limit,
        offset: offsetPaid,
        search: searchQuery.value,
        pickerDateRange: searchDateQuery.value,
        methodPayment: methodPayment.value,
      );
      if (results.isEmpty || offsetPaid > 200) {
        hasMorePaid.value = false;
        return <InvoiceModel>[];
      } else {
        offsetPaid += limit;
        return results;
      }
    } else {
      return <InvoiceModel>[];
    }
  }

  Future<List<InvoiceModel>> fetchDebt({bool isClean = false}) async {
    if (isClean) {
      hasMoreDebt.value = true;
      offsetDebt = 0;
    }
    if (hasMoreDebt.value) {
      final results = await invoiceService.fetch(
        isPaid: false,
        limit: limit,
        offset: offsetDebt,
        search: searchQuery.value,
        pickerDateRange: searchDateQuery.value,
        methodPayment: methodPayment.value,
      );
      if (results.isEmpty || offsetDebt > 200) {
        hasMoreDebt.value = false;
        return <InvoiceModel>[];
      } else {
        offsetDebt += limit;
        return results;
      }
    } else {
      return <InvoiceModel>[];
    }
  }

  void loadPaid() async {
    displayedItemsPaid.addAll(await fetchPaid());
  }

  void loadDebt() async {
    displayedItemsDebt.addAll(await fetchDebt());
  }

  bool isFiltered() {
    return (searchQuery.isNotEmpty ||
        searchDateQuery.value != null ||
        methodPayment.isNotEmpty);
  }

  Timer? debounceTimer;
  void filterInvoices(dynamic searchValue) async {
    if (searchValue is String) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        if (formKey.currentState!.validate()) {
          searchQuery.value = searchValue;
        }
      });
    } else if (searchValue is PickerDateRange) {
      searchDateQuery.value = searchValue;
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
  }

  handleFilteredDate(BuildContext context) {
    startFilteredDate.value = '';
    endFilteredDate.value = '';
    // displayFilteredDate.value = '';
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
                    DateFormat('dd MMM y', 'id').format(args.value.startDate!);
                if (args.value.endDate != null) {
                  endFilteredDate.value =
                      DateFormat('dd MMM y', 'id').format(args.value.endDate!);
                }
              },
              onCancel: () => Get.back(),
              onSubmit: (value) {
                if (value is PickerDateRange) {
                  final newSelectedPickerRange = PickerDateRange(
                      value.startDate,
                      value.endDate != null
                          ? value.endDate!.add(const Duration(days: 1))
                          : value.startDate!.add(const Duration(days: 1)));

                  selectedFilteredDate.value =
                      newSelectedPickerRange.startDate!;
                  displayFilteredDate.value = value.endDate != null
                      ? '$startFilteredDate s/d $endFilteredDate'
                      : '$startFilteredDate';
                  filterInvoices(newSelectedPickerRange);
                  dateIsSelected.value = true;
                  Get.back();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  final selectedMode = false.obs;
  void selectedModeHandle() {
    selectedMode.value = !selectedMode.value;
    if (!selectedMode.value) selectedInvoices.clear();
  }

  final selectedInvoices = <InvoiceModel>[].obs;
  void selectedHandle(InvoiceModel invoice) async {
    if (checkExisting(invoice)) {
      selectedInvoices.remove(invoice);
      if (selectedInvoices.isEmpty) selectedModeHandle();
    } else {
      selectedInvoices.add(invoice);
    }
    print('selectedMode ${selectedMode.value}');
    print('selectedMode selectedInvoices ${selectedInvoices.length}');
  }

  bool checkExisting(InvoiceModel invoice) {
    return selectedInvoices.any((inv) => inv.id == invoice.id);
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
