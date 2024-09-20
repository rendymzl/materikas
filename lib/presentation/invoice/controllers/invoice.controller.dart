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
  late final InvoiceService _invoiceService = Get.find();

  // late final foundInvoices = _invoiceService.foundInvoices;

  late final debtInv = _invoiceService.debtInv;
  late InvoiceModel initInvoice;

  // Observable untuk pencarian dan filter
  var searchQuery = ''.obs;
  var dateRangePicked = PickerDateRange(
          DateTime.now(), DateTime.now().add(const Duration(days: 1)))
      .obs;
  late final invoices = <InvoiceModel>[].obs;
  late final filteredInvoices = <InvoiceModel>[].obs;
  var displayedItems = <InvoiceModel>[].obs; // Data yang ditampilkan saat ini

  var isLoading = false.obs; // Untuk memantau status loading
  var hasMore = true.obs; // Memantau apakah masih ada data lagi
  var page = 1; // Halaman data saat ini

  final int limit = 20; // Batas data per halaman

  final editInvoice = true.obs;
  final returnInvoice = true.obs;
  final paymentInvoice = true.obs;
  final destroyInvoice = true.obs;

  @override
  void onInit() async {
    super.onInit();
    // Listen ke stream dan update produk
    _invoiceService.stream.listen((inv) {
      invoices.clear();
      invoices.value = inv.where((i) {
        return i.totalPaid >= i.totalBill;
      }).map((purchased) {
        InvoiceModel invPurchase = InvoiceModel.fromJson(purchased.toJson());
        return invPurchase;
      }).toList();
      applyFilters();
      print('invoices.length: ${invoices.length}');
    });
    // Listen perubahan searchQuery atau selectedCategory
    ever(searchQuery, (_) => applyFilters());
    ever(dateRangePicked, (_) => applyFilters());

    editInvoice.value = await _authService.checkAccess('editInvoice');
    returnInvoice.value = await _authService.checkAccess('returnInvoice');
    paymentInvoice.value = await _authService.checkAccess('paymentInvoice');
    destroyInvoice.value = await _authService.checkAccess('destroyInvoice');
  }

  // @override
  // void onClose() {
  //   // Berhenti mendengarkan stream saat controller dihapus dari memori
  //   _invoiceService.stream.cancel();
  //   super.onClose();
  // }

  // Fungsi untuk menerapkan filter dan pencarian
  void applyFilters() {
    var result = invoices;

    // Filter berdasarkan kategori jika ada yang dipilih

    // result = result
    //     .where((inv) {
    //       if (inv.createdAt.value != null) {
    //         DateTime invoiceDate = inv.createdAt.value!;
    //         return invoiceDate.isAfter(dateRangePicked.value.startDate!) &&
    //             invoiceDate.isBefore(dateRangePicked.value.endDate!);
    //       }
    //       return false;
    //     })
    //     .toList()
    //     .obs;

    // Filter berdasarkan pencarian (misal mencari berdasarkan nama produk)
    if (searchQuery.value.isNotEmpty) {
      result = result
          .where((inv) {
            return inv.customer.value!.name
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase()) ||
                inv.invoiceId
                    .toString()
                    .toLowerCase()
                    .contains(searchQuery.value.toLowerCase());
          })
          .toList()
          .obs;
    }

    // Update produk yang sudah difilter
    filteredInvoices.value = result;
    print('filteredInvoices.length ${filteredInvoices.length}');
    hasMore.value = true;
    page = 1;
    displayedItems.clear();
    loadMore();
  }

  void loadMore() {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    // Ambil data dari list yang ada berdasarkan pagination
    int startIndex = (page - 1) * limit;
    int endIndex = startIndex + limit;

    List<InvoiceModel> newData = [];
    if (startIndex < filteredInvoices.length) {
      newData = filteredInvoices.sublist(
          startIndex,
          endIndex > filteredInvoices.length
              ? filteredInvoices.length
              : endIndex);
    }

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

  Timer? debounceTimer;
  void filterInvoices(dynamic searchValue) {
    if (searchValue is String) {
      if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
      debounceTimer = Timer(const Duration(milliseconds: 500), () {
        searchQuery.value = searchValue;
      });
    } else if (searchValue is PickerDateRange) {
      _invoiceService.searchInvoicesByPickerDateRange(searchValue);
    }
    // if (searchValue is String) {
    //   if (debounceTimer?.isActive ?? false) debounceTimer?.cancel();
    //   debounceTimer = Timer(const Duration(milliseconds: 500), () {
    //     _invoiceService.searchInvoicesByName(searchValue);
    //   });
    // } else if (searchValue is PickerDateRange) {
    //   _invoiceService.searchInvoicesByPickerDateRange(searchValue);
    // }
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
    filterInvoices('');
  }

  destroyHandle(InvoiceModel invoice) async {
    await _invoiceService.delete(invoice.id!);
  }
}
