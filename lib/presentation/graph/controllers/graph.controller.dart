import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/chart_model.dart';
// import '../../statistic/controllers/statistic.controller.dart';

class GraphController extends GetxController {
  late final InvoiceService invoiceService = Get.find();
  late final OperatingCostService operatingCostService = Get.find();

  // final StatisticController statisticC = Get.find();

  final chartLists = <Chart>[].obs;
  final showingTooltip = (-1).obs;
  // final pickerDateRange = PickerDateRange(
  //         startDate,
  //         DateTime(
  //                 DateTime.now().year, DateTime.now().month, DateTime.now().day)
  //             .add(const Duration(seconds: 1)))
  //     .obs;

  final isLoading = false.obs;
  @override
  void onInit() async {
    isLoading(true);
    // await filterSalesByDayFor7Days(DateTime.now());
    isLoading(false);
    super.onInit();
  }

  // Future<void> filterSalesByDayFor7Days(DateTime selectedDate) async {
  //   List<Chart> dailySalesData = [];

  //   for (int i = 0; i < 7; i++) {
  //     // Tentukan rentang waktu setiap hari
  //     DateTime dayStart =
  //         DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
  //             .subtract(Duration(days: i));
  //     DateTime dayEnd = dayStart.add(Duration(days: 1));

  //     // Ambil data untuk hari tersebut
  //     var dailyData = await getChartData(PickerDateRange(dayStart, dayEnd));
  //     dailySalesData.add(dailyData);
  //   }

  //   dailySalesData.sort(
  //       (a, b) => a.date.compareTo(b.date)); // Mengurutkan berdasarkan tanggal
  //   chartLists.assignAll(dailySalesData);
  // }

  // Future<Chart> getChartData(PickerDateRange pickerDateRange) async {
  //   isLoading.value = true;
  //   // isFetching.value = true;
  //   // selectedDate.value = pickerDateRange.startDate!;
  //   // final start = DateTime.now();
  //   final invoices = await invoiceService.getByCreatedDate(pickerDateRange);
  //   // final invoicesSales =
  //   //     await invoiceSalesService.getByCreatedDate(pickerDateRange);
  //   final operatingCosts =
  //       await operatingCostService.getByDate(pickerDateRange);
  //   // invoicesByPaymentDate.value =
  //   //     await invoiceService.getPaymentByDate(pickerDateRange);
  //   // invoicesSalesByPaymentDate.value =
  //   //     await invoiceSalesService.getPaymentByDate(pickerDateRange);
  //   // final finish = DateTime.now();
  //   // print(
  //   //     'invoices statistic Waktu proses: ${finish.difference(start).inMilliseconds} ms');

  //   // final formatter = DateFormat('EEEE, dd/MM', 'id');

  //   double totalSellPrice = 0;
  //   double totalReturn = 0;
  //   double totalChargeReturn = 0;
  //   double totalDiscount = 0;
  //   double totalOtherCost = 0;
  //   double totalCostPrice = 0;

  //   double totalOperatingCost = 0;

  //   var totalInvoice = invoices.length;

  //   for (var inv in invoices) {
  //     totalSellPrice += inv.subTotalPurchase;
  //     totalReturn += inv.totalReturn;
  //     totalChargeReturn += inv.returnFee.value;
  //     totalDiscount += inv.totalDiscount;
  //     totalOtherCost += inv.totalOtherCosts;
  //     totalCostPrice += inv.purchaseList.value.subtotalCost;
  //   }

  //   for (var op in operatingCosts) {
  //     int operatingCost = op.amount!;
  //     totalOperatingCost += operatingCost;
  //   }

  //   final chartData = Chart(
  //     date: pickerDateRange.startDate!,
  //     dateString: '',
  //     totalSellPrice: totalSellPrice,
  //     totalSellPriceSales: 0,
  //     totalReturn: totalReturn,
  //     totalChargeReturn: totalChargeReturn,
  //     totalDiscount: totalDiscount,
  //     totalDiscountSales: 0,
  //     totalOtherCost: totalOtherCost,
  //     cash: 0,
  //     transfer: 0,
  //     deposit: 0,
  //     debtCash: 0,
  //     debtTransfer: 0,
  //     salesCash: 0,
  //     salesTransfer: 0,
  //     totalCostPrice: totalCostPrice,
  //     operatingCost: totalOperatingCost,
  //     totalInvoice: totalInvoice,
  //     totalInvoiceSales: 0,
  //   );

  //   // isFetching.value = false;
  //   isLoading.value = false;
  //   return chartData;
  // }

  // final startDate = DateTime.now().obs;
  final startDate = DateTime.now().subtract(const Duration(days: 6)).obs;
  final endDate = DateTime.now().obs;
  final weeklyRangeController = DateRangePickerController().obs;

  handleFilteredDate(BuildContext context) {
    Get.defaultDialog(
      title: 'Pilih Tanggal',
      backgroundColor: Colors.white,
      content: SizedBox(
        width: 400,
        height: 350,
        child: SfDateRangePicker(
          controller: weeklyRangeController.value,
          headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: Colors.white,
              textStyle: context.textTheme.bodyLarge),
          showNavigationArrow: true,
          backgroundColor: Colors.white,
          monthViewSettings: const DateRangePickerMonthViewSettings(
            firstDayOfWeek: 1,
          ),
          // initialSelectedDate: DateTime.now(),
          initialSelectedRange: PickerDateRange(startDate.value, endDate.value),
          selectionMode: DateRangePickerSelectionMode.range,
          minDate: DateTime(2000),
          maxDate: DateTime.now(),
          showActionButtons: true,
          cancelText: 'Batal',
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            PickerDateRange value = args.value;
            if (value.endDate == null) {
              endDate.value = DateTime(value.startDate!.year,
                  value.startDate!.month, value.startDate!.day);
              startDate.value = endDate.value.subtract(const Duration(days: 6));
              final pickerDateRange =
                  PickerDateRange(startDate.value, endDate.value);
              weeklyRangeController.value.selectedRange = pickerDateRange;
            }

            // var newDateRange = PickerDateRange(
            //     (args.value as PickerDateRange)
            //         .startDate!
            //         .subtract(const Duration(days: 7)),
            //     (args.value as PickerDateRange).startDate);
            // print('awdawdawdawdawd ${newDateRange}');
            // // weeklyRangeController.value.selectedRange = newDateRange;
            // startDate.value = newDateRange.startDate!;
            // endDate.value = newDateRange.endDate!;
            // endDate(args.value.startDate!);
            // args.value.endDate = args.value.startDate!;
            // if (args.value != null) {
            //   DateTime endDate = args.value;
            //   DateTime startDate = endDate.subtract(const Duration(days: 7));
            //   // filterSalesByDayFor7Days(endDate);
            // }
          },
          onCancel: () => Get.back(),
          onSubmit: (value) {
            if (value is PickerDateRange) {
              // filterSalesByDayFor7Days(endDate.value);
              Get.back();
              // final newSelectedPickerRange = PickerDateRange(
              //     value.startDate,
              //     value.endDate != null
              //         ? value.endDate!.add(const Duration(days: 1))
              //         : value.startDate!.add(const Duration(days: 1)));

              // selectedFilteredDate.value = newSelectedPickerRange.startDate!;
              // displayFilteredDate.value = value.endDate != null
              //     ? '$startFilteredDate s/d $endFilteredDate'
              //     : '$startFilteredDate';
              // filterInvoices(newSelectedPickerRange);
              // dateIsSelected.value = true;
            }
          },
        ),
      ),
    );
  }
}
