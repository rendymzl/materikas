import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/chart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class StatisticController extends GetxController {
  late final AuthService authService = Get.find();
  late final BillingService billingService = Get.find();
  late final InvoiceService invoiceService = Get.find();
  late final InvoiceSalesService invoiceSalesService = Get.find();
  late final OperatingCostService operatingCostService = Get.find();

  // late final invoices = <InvoiceModel>[].obs;
  late final invoicesSalesByPaymentDate = <InvoiceSalesModel>[].obs;
  late final invoicesByPaymentDate = <InvoiceModel>[].obs;
  // late final operatingCosts = <OperatingCostModel>[].obs;
  // late final byPaymentDateInvoices = <PaymentMapModel>[].obs;

  final displaySection = ['transaction', 'payment'].obs;
  final selectedPaymentMethod = 'transaction'.obs;
  final selectedDate = DateTime.now().obs;
  final selectedSection = 'daily'.obs;
  final isFetching = false.obs;
  final isLoading = false.obs;

  Rx<Chart?> selectedChart = Rx<Chart?>(null);

  final accessOperational = true.obs;

  @override
  void onInit() async {
    billingService.getBillAmount();
    selectedSection.value = 'daily';

    dailyPickerHandle(DateTime.now());

    accessOperational.value =
        await authService.checkAccess('addOperationalCost');
    super.onInit();
  }

  // Future<void> fetchData(PickerDateRange selectedDate, String section) async {
  //   // isLoading.value = true;

  //   switch (section) {
  //     case 'daily':
  //       selectedChart.value = await getChartData(selectedDate);
  //       // isLoading.value = false;
  //       break;
  //     case 'weekly':
  //       selectedChart.value = await getChartData(selectedDate);
  //       // isLoading.value = false;
  //       break;
  //     case 'monthly':
  //       selectedChart.value = await getChartData(selectedDate);
  //       // isLoading.value = false;
  //       break;
  //     case 'yearly':
  //       selectedChart.value = await getChartData(selectedDate);
  //       // isLoading.value = false;
  //       break;
  //   }
  //   // isLoading.value = false;
  // }

//! Daily & Weekly ======================================================
  final dailyRangeController = DateRangePickerController().obs;
  final weeklyRangeController = DateRangePickerController().obs;
  final monthlyRangeController = DateRangePickerController().obs;
  final yearlyRangeController = DateRangePickerController().obs;

  final chartList = <Chart>[].obs;

  void dailyPickerHandle(DateTime pickedDate) async {
    final endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    final startDate = endDate.subtract(Duration(days: 6));
    final pickerDateRange = PickerDateRange(startDate, endDate);
    dailyRangeController.value.selectedDate = pickedDate;
    final chartDatas = await getChartList(pickerDateRange);
    chartList.assignAll(chartDatas);
    chartList.sort((a, b) => a.date.compareTo(b.date));
    if (chartList.isNotEmpty) {
      selectedChart.value = chartList.last;
    }

    // dailyRangeController.value.selectedDate = pickedDate;
    // final startDate =
    //     DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    // final endDate = startDate.add(Duration(days: 1));
    // final pickerDateRange = PickerDateRange(startDate, endDate);
    // print(pickerDateRange);

    // selectedChart.value = await getChartData(pickerDateRange);
  }

  void weeklyPickerHandle(DateTime pickedDate) async {
    final endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
    final startDate = endDate.subtract(Duration(days: 6));
    final pickerDateRange = PickerDateRange(startDate, endDate);
    weeklyRangeController.value.selectedRange = pickerDateRange;
    final chartDatas = await getChartList(pickerDateRange);
    chartList.assignAll(chartDatas);
    chartList.sort((a, b) => a.date.compareTo(b.date));

    final totalInvoice =
        chartList.fold(0, (prev, chart) => prev + chart.totalInvoice);
    final totalBill =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalBill);
    final totalCost =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalCost);
    final totalDiscount =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDiscount);
    final totalCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalCash);
    final totalTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalTransfer);
    final totalDebtCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDebtCash);
    final totalDebtTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDebtTransfer);
    final purchaseReturn =
        chartList.fold(0.0, (prev, chart) => prev + chart.purchaseReturn);
    final additionalReturn =
        chartList.fold(0.0, (prev, chart) => prev + chart.additionalReturn);
    final returnFee =
        chartList.fold(0.0, (prev, chart) => prev + chart.returnFee);
    final operatingCostCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.operatingCostCash);
    final operatingCostTransfer = chartList.fold(
        0.0, (prev, chart) => prev + chart.operatingCostTransfer);
    final totalSalesCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalSalesCash);
    final totalSalesTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalSalesTransfer);

    selectedChart.value = Chart(
      date: startDate,
      dateDisplay:
          '${dateWihtoutTime.format(startDate)} - ${dateWihtoutTime.format(endDate)}',
      totalInvoice: totalInvoice,
      totalBill: totalBill,
      totalCost: totalCost,
      totalDiscount: totalDiscount,
      totalCash: totalCash,
      totalTransfer: totalTransfer,
      totalDebtCash: totalDebtCash,
      totalDebtTransfer: totalDebtTransfer,
      purchaseReturn: purchaseReturn,
      additionalReturn: additionalReturn,
      returnFee: returnFee,
      operatingCostCash: operatingCostCash,
      operatingCostTransfer: operatingCostTransfer,
      totalSalesCash: totalSalesCash,
      totalSalesTransfer: totalSalesTransfer,
    );
  }

  void monthlyPickerHandle(DateTime pickedDate) async {
    final startDate = DateTime(pickedDate.year, pickedDate.month, 1);

    DateTime endDate;
    if (pickedDate.month == 12) {
      endDate = DateTime(pickedDate.year + 1, 1, 1).subtract(Duration(days: 1));
    } else {
      endDate = DateTime(pickedDate.year, pickedDate.month + 1, 1)
          .subtract(Duration(days: 1));
    }

    final pickerDateRange = PickerDateRange(startDate, endDate);
    monthlyRangeController.value.selectedDate = pickedDate;
    final chartDatas = await getChartList(pickerDateRange);
    chartList.assignAll(chartDatas);
    chartList.sort((a, b) => a.date.compareTo(b.date));

    final totalInvoice =
        chartList.fold(0, (prev, chart) => prev + chart.totalInvoice);
    final totalBill =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalBill);
    final totalCost =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalCost);
    final totalDiscount =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDiscount);
    final totalCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalCash);
    final totalTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalTransfer);
    final totalDebtCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDebtCash);
    final totalDebtTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalDebtTransfer);
    final purchaseReturn =
        chartList.fold(0.0, (prev, chart) => prev + chart.purchaseReturn);
    final additionalReturn =
        chartList.fold(0.0, (prev, chart) => prev + chart.additionalReturn);
    final returnFee =
        chartList.fold(0.0, (prev, chart) => prev + chart.returnFee);
    final operatingCostCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.operatingCostCash);
    final operatingCostTransfer = chartList.fold(
        0.0, (prev, chart) => prev + chart.operatingCostTransfer);
    final totalSalesCash =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalSalesCash);
    final totalSalesTransfer =
        chartList.fold(0.0, (prev, chart) => prev + chart.totalSalesTransfer);

    selectedChart.value = Chart(
      date: startDate,
      dateDisplay:
          '${dateWihtoutTime.format(startDate)} - ${dateWihtoutTime.format(endDate)}',
      totalInvoice: totalInvoice,
      totalBill: totalBill,
      totalCost: totalCost,
      totalDiscount: totalDiscount,
      totalCash: totalCash,
      totalTransfer: totalTransfer,
      totalDebtCash: totalDebtCash,
      totalDebtTransfer: totalDebtTransfer,
      purchaseReturn: purchaseReturn,
      additionalReturn: additionalReturn,
      returnFee: returnFee,
      operatingCostCash: operatingCostCash,
      operatingCostTransfer: operatingCostTransfer,
      totalSalesCash: totalSalesCash,
      totalSalesTransfer: totalSalesTransfer,
    );
  }

  Future<List<Chart>> getChartList(PickerDateRange pickerDateRange) async {
    isLoading.value = true;
    isFetching.value = true;
    selectedDate.value = pickerDateRange.startDate!;

    final chartdatas = await invoiceService.getChartList(pickerDateRange);
    isLoading.value = false;
    isFetching.value = false;
    return chartdatas;
  }

  Future<List<InvoiceSalesModel>> getPaymentSalesByDate(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate =
        startDate.add(Duration(days: 1));
    print('lenght debug ${startDate}');
    print('lenght debug ${endDate}');

    final data = await invoiceSalesService
        .getPaymentByDate(PickerDateRange(startDate, endDate));
    print('lenght debug ${data}');
    return data;
  }

  // void weeklyPickerHandle(DateTime pickedDate) async {
  //   final endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
  //   final startDate = endDate.subtract(Duration(days: 6));
  //   final pickerDateRange = PickerDateRange(startDate, endDate);
  //   weeklyRangeController.value.selectedRange = pickerDateRange;
  //   // selectedChart.value = await getChartData(pickerDateRange);
  //   print(pickerDateRange);
  // }

  // void monthlyPickerHandle(DateTime pickedDate) async {
  //   final startDate = DateTime(pickedDate.year, pickedDate.month, 1);

  //   DateTime endDate;
  //   if (pickedDate.month == 12) {
  //     endDate = DateTime(pickedDate.year + 1, 1, 1).subtract(Duration(days: 1));
  //   } else {
  //     endDate = DateTime(pickedDate.year, pickedDate.month + 1, 1)
  //         .subtract(Duration(days: 1));
  //   }

  //   final pickerDateRange = PickerDateRange(startDate, endDate);
  //   monthlyRangeController.value.selectedDate = pickedDate;
  //   // selectedChart.value = await getChartData(pickerDateRange);
  //   print(pickerDateRange);
  // }

  void yearlyPickerHandle(DateTime pickedDate) async {
    final startDate = DateTime(pickedDate.year, 1, 1);
    final endDate =
        DateTime(pickedDate.year + 1, 1, 1).subtract(Duration(days: 1));

    final pickerDateRange = PickerDateRange(startDate, endDate);
    yearlyRangeController.value.selectedDate = pickedDate;
    // selectedChart.value = await getChartData(pickerDateRange);
    print(pickerDateRange);
  }

  // Future<Chart> getChartData(PickerDateRange pickerDateRange) async {
  //   isLoading.value = true;
  //   isFetching.value = true;
  //   selectedDate.value = pickerDateRange.startDate!;
  //   final start = DateTime.now();
  //   final invoices = await invoiceService.getByCreatedDate(pickerDateRange);
  //   final invoicesSales =
  //       await invoiceSalesService.getByCreatedDate(pickerDateRange);
  //   final operatingCosts =
  //       await operatingCostService.getByDate(pickerDateRange);
  //   invoicesByPaymentDate.value =
  //       await invoiceService.getPaymentByDate(pickerDateRange);
  //   invoicesSalesByPaymentDate.value =
  //       await invoiceSalesService.getPaymentByDate(pickerDateRange);
  //   final finish = DateTime.now();
  //   print(
  //       'invoices statistic Waktu proses: ${finish.difference(start).inMilliseconds} ms');

  //   final formatter = DateFormat('EEEE, dd/MM', 'id');

  //   double totalSellPrice = 0;
  //   double totalSellPriceSales = 0;
  //   double totalReturn = 0;
  //   double totalChargeReturn = 0;
  //   double totalDiscount = 0;
  //   double totalDiscountSales = 0;
  //   double totalOtherCost = 0;
  //   double totalCostPrice = 0;

  //   double totalOperatingCost = 0;

  //   var cash = 0.0;
  //   var transfer = 0.0;
  //   var deposit = 0.0;
  //   var debtCash = 0.0;
  //   var debtTransfer = 0.0;
  //   var salesCash = 0.0;
  //   var salesTransfer = 0.0;

  //   var totalInvoice = invoices.length;
  //   var totalInvoiceSales = invoicesSales.length;

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

  //   for (var invoice in invoicesSales) {
  //     totalSellPriceSales += invoice.subtotalCost;
  //     totalDiscountSales += invoice.discount.value;
  //     print('invoicesSales statistic ${salesTransfer}');
  //   }

  //   for (var invoice in invoicesSalesByPaymentDate) {
  //     salesCash += invoice.getTotalByMethod('cash',
  //         selectedDate: invoice.createdAt.value);
  //     salesTransfer += invoice.getTotalByMethod('transfer',
  //         selectedDate: invoice.createdAt.value);
  //     print('invoicesSales statistic ${salesTransfer}');
  //   }

  //   for (var invoice in invoicesByPaymentDate) {
  //     cash += invoice.getTotalPayByMethod('cash',
  //         selectedDate: invoice.createdAt.value);
  //     transfer += invoice.getTotalPayByMethod('transfer',
  //         selectedDate: invoice.createdAt.value);
  //     deposit += invoice.getTotalPayByMethod('deposit',
  //         selectedDate: invoice.createdAt.value);
  //   }
  //   print('depositdepositdeposit $deposit');

  //   for (var invoice in invoicesByPaymentDate) {
  //     debtCash += invoice.getTotalDebtByMethod('cash',
  //         selectedDate: invoice.createdAt.value);
  //     debtTransfer += invoice.getTotalDebtByMethod('transfer',
  //         selectedDate: invoice.createdAt.value);
  //   }

  //   final chartData = Chart(
  //     date: pickerDateRange.startDate!,
  //     dateString: selectedSection.value != 'daily' ||
  //             selectedSection.value != 'weekly'
  //         ? formatter.format(pickerDateRange.startDate!)
  //         : '${formatter.format(pickerDateRange.startDate!)} - ${formatter.format(pickerDateRange.endDate!)}',
  //     totalSellPrice: totalSellPrice,
  //     totalSellPriceSales: totalSellPriceSales,
  //     totalReturn: totalReturn,
  //     totalChargeReturn: totalChargeReturn,
  //     totalDiscount: totalDiscount,
  //     totalDiscountSales: totalDiscountSales,
  //     totalOtherCost: totalOtherCost,
  //     cash: cash,
  //     transfer: transfer,
  //     deposit: deposit,
  //     debtCash: debtCash,
  //     debtTransfer: debtTransfer,
  //     salesCash: salesCash,
  //     salesTransfer: salesTransfer,
  //     totalCostPrice: totalCostPrice,
  //     operatingCost: totalOperatingCost,
  //     totalInvoice: totalInvoice,
  //     totalInvoiceSales: totalInvoiceSales,
  //   );
  //   // paymentsAll.assignAll(await invoiceService.getAllPayment());
  //   // paymentsByDate
  //   //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));
  //   // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
  //   // byPaymentDateInvoices = await invoiceService.getByPaymentDate(selectedDate);

  //   // invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

  //   // currentFilteredSalesInvoices = _invoiceSalesService.invoices.where((invoice) {
  //   //   return DateTime(invoice.createdAt.value!.year,
  //   //           invoice.createdAt.value!.month, invoice.createdAt.value!.day) ==
  //   //       DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  //   // }).toList();

  //   // currentFilteredOperatingCosts = operatingCosts.where((invoice) {
  //   //   return DateTime(invoice.createdAt!.year, invoice.createdAt!.month,
  //   //           invoice.createdAt!.day) ==
  //   //       DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  //   // }).toList();
  //   isFetching.value = false;
  //   isLoading.value = false;
  //   return chartData;
  // }

  // void rangePickerHandle(DateTime pickedDate) async {
  //   final DateTime startDate = await getStartofWeek(pickedDate);

  //   final DateTime endDate = startDate.add(const Duration(days: 6));
  //   final newSelectedPickerRange = PickerDateRange(startDate, endDate);

  //   selectedWeeklyRange.value = newSelectedPickerRange;
  //   weeklyRangeController.value.selectedRange = newSelectedPickerRange;

  //   selectedDate.value = pickedDate;
  //   dailyRangeController.value.selectedDate = pickedDate;
  //   monthlyRangeController.value.selectedDate = pickedDate;
  //   yearlyRangeController.value.selectedDate = pickedDate;
  //   await fetchData(pickedDate, selectedSection.value);

  //   dailyOperatingCosts.value = operatingCosts.where((cost) {
  //     return cost.createdAt!.day == selectedDate.value.day &&
  //         cost.createdAt!.month == selectedDate.value.month &&
  //         cost.createdAt!.year == selectedDate.value.year;
  //   }).toList();
  // }

//   final selectedWeeklyRange = PickerDateRange(
//           DateTime.now(), DateTime.now().subtract(const Duration(days: 6)))
//       .obs;

// //! daily ======================================================
//   Future<Chart> groupDailyInvoices(DateTime selectedDate) async {
//     PickerDateRange pickerDateRange = PickerDateRange(
//         selectedDate, selectedDate.add(const Duration(days: 1)));

//     // paymentsAll.assignAll(await invoiceService.getAllPayment());
//     // paymentsByDate
//     //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));
//     // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
//     byPaymentDateInvoices = await invoiceService.getByPaymentDate(selectedDate);

//     invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

//     currentFilteredSalesInvoices =
//         _invoiceSalesService.invoices.where((invoice) {
//       return DateTime(invoice.createdAt.value!.year,
//               invoice.createdAt.value!.month, invoice.createdAt.value!.day) ==
//           DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//     }).toList();

//     currentFilteredOperatingCosts = operatingCosts.where((invoice) {
//       return DateTime(invoice.createdAt!.year, invoice.createdAt!.month,
//               invoice.createdAt!.day) ==
//           DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
//     }).toList();

//     return await getChartData(pickerDateRange, selectedDate);
//   }

// //! Weekly ======================================================
//   Future<Chart> groupWeeklyInvoices(DateTime selectedDate) async {
//     isLastIndex.value = selectedDate.weekday == DateTime.monday;

//     DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

//     DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
//     DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

//     PickerDateRange pickerDateRange = PickerDateRange(
//         currentStartOfWeek.subtract(const Duration(days: 1)),
//         currentStartOfWeek.add(const Duration(days: 7)));
//     // paymentsAll.assignAll(await invoiceService.getAllPayment());
//     // paymentsByDate
//     //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));

//     // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);

//     invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

//     currentFilteredSalesInvoices =
//         _invoiceSalesService.invoices.where((invoice) {
//       return invoice.createdAt.value!.isAfter(prevStartOfWeek);
//     }).toList();

//     currentFilteredOperatingCosts = operatingCosts.where((invoice) {
//       return invoice.createdAt!.isAfter(prevStartOfWeek);
//     }).toList();

//     selectedWeeklyRange.value = PickerDateRange(
//         currentStartOfWeek, currentStartOfWeek.add(const Duration(days: 6)));

//     return await getChartData(selectedWeeklyRange.value, selectedDate);
//   }

//   Future<DateTime> getStartofWeek(DateTime selectedDate) async {
//     final selectedDay = selectedDate.weekday;
//     final offset = selectedDay - DateTime.monday;
//     final startOfWeek = selectedDate.subtract(Duration(days: offset));

//     return startOfWeek;
//   }

// //! Monthly ======================================================
//   void monthPickerHandle(DateTime pickedDate) async {
//     selectedDate.value = pickedDate;
//     dailyRangeController.value.selectedDate = pickedDate;
//     monthlyRangeController.value.selectedDate = pickedDate;
//     yearlyRangeController.value.selectedDate = pickedDate;
//     await fetchData(pickedDate, 'monthly');
//   }

//   Future<Chart> groupMonthlyInvoices(DateTime selectedDate) async {
//     final currentMonth = selectedDate.month;
//     final prevMonth = currentMonth - 1;
//     final currentYear = selectedDate.year;

//     final startOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
//     final startOfPrevMonth = DateTime(currentYear, prevMonth, 1);
//     final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

//     PickerDateRange pickerDateRange = PickerDateRange(
//         startOfCurrentMonth.subtract(const Duration(days: 1)),
//         endOfMonth.add(const Duration(days: 1)));

//     // paymentsAll.assignAll(await invoiceService.getAllPayment());
//     // paymentsByDate
//     //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));

//     // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
//     invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

//     currentFilteredSalesInvoices =
//         _invoiceSalesService.invoices.where((invoice) {
//       return invoice.createdAt.value!
//               .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
//           invoice.createdAt.value!
//               .isBefore(endOfMonth.add(const Duration(days: 1)));
//     }).toList();

//     currentFilteredOperatingCosts = operatingCosts.where((invoice) {
//       return invoice.createdAt!
//               .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
//           invoice.createdAt!.isBefore(endOfMonth.add(const Duration(days: 1)));
//     }).toList();

//     return await getChartData(pickerDateRange, selectedDate);
//   }

// //! Yearly ======================================================

//   void yearPickerHandle(DateTime pickedDate) async {
//     selectedDate.value = pickedDate;
//     dailyRangeController.value.selectedDate = pickedDate;
//     monthlyRangeController.value.selectedDate = pickedDate;
//     yearlyRangeController.value.selectedDate = pickedDate;
//     await fetchData(pickedDate, 'yearly');
//   }

//   Future<Chart> groupYearlyInvoices(DateTime selectedDate) async {
//     final currentYear = selectedDate.year;
//     final prevYear = selectedDate.year - 1;

//     final startOfCurrentYear = DateTime(currentYear, 1);
//     final startOfPrevYear = DateTime(prevYear, 1);
//     final endOfYear = DateTime(currentYear, 12);

//     PickerDateRange pickerDateRange = PickerDateRange(
//         startOfCurrentYear.add(const Duration(milliseconds: 1)),
//         endOfYear.add(const Duration(days: 1)));

//     // paymentsAll.assignAll(await invoiceService.getAllPayment());
//     // paymentsByDate
//     //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));
//     invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

//     currentFilteredSalesInvoices =
//         _invoiceSalesService.invoices.where((invoice) {
//       return invoice.createdAt.value!
//               .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
//           invoice.createdAt.value!
//               .isBefore(endOfYear.add(const Duration(days: 1)));
//     }).toList();

//     currentFilteredOperatingCosts = operatingCosts.where((invoice) {
//       return invoice.createdAt!
//               .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
//           invoice.createdAt!.isBefore(endOfYear.add(const Duration(days: 1)));
//     }).toList();

//     return await getChartData(pickerDateRange, selectedDate);
//   }

  // Future<Chart> getChartData(
  //     PickerDateRange? pickerDateRange, DateTime selectedDate) async {
  //   final formatter = DateFormat('EEEE, dd/MM', 'id');

  //   double totalSellPrice = 0;
  //   double totalReturn = 0;
  //   double totalChargeReturn = 0;
  //   double totalDiscount = 0;
  //   double totalOtherCost = 0;
  //   double totalCostPrice = 0;

  //   double totalOperatingCost = 0;

  //   var cash = 0.0;
  //   var transfer = 0.0;
  //   var debtCash = 0.0;
  //   var debtTransfer = 0.0;
  //   var salesCash = 0.0;
  //   var salesTransfer = 0.0;

  //   var totalInvoice = invoices.length;

  //   for (var inv in invoices) {
  //     double sellPrice = inv.subTotalPurchase;
  //     double returnPrice = inv.totalReturn;
  //     double returnFee = inv.returnFee.value;
  //     double discount = inv.totalDiscount;
  //     double otherCost = inv.totalOtherCosts;
  //     double costPrice = inv.purchaseList.value.subtotalCost;

  //     totalSellPrice += sellPrice;
  //     totalReturn += returnPrice;
  //     totalChargeReturn += returnFee;
  //     totalDiscount += discount;
  //     totalOtherCost += otherCost;
  //     totalCostPrice += costPrice;
  //   }

  //   for (var op in currentFilteredOperatingCosts) {
  //     int operatingCost = op.amount!;
  //     totalOperatingCost += operatingCost;
  //   }

  //   for (var invoice in _invoiceSalesService.invoices) {
  //     salesCash += invoice.getTotalByMethod('cash', selectedDate: selectedDate);
  //     salesTransfer +=
  //         invoice.getTotalByMethod('transfer', selectedDate: selectedDate);
  //   }

  //   for (var invoice in invoices) {
  //     cash += invoice.getTotalPayByMethod('cash', selectedDate: selectedDate);
  //     transfer +=
  //         invoice.getTotalPayByMethod('transfer', selectedDate: selectedDate);
  //   }

  //   for (var invoice in byPaymentDateInvoices) {
  //     debtCash +=
  //         invoice.getTotalDebtByMethod('cash', selectedDate: selectedDate);
  //     debtTransfer +=
  //         invoice.getTotalDebtByMethod('transfer', selectedDate: selectedDate);
  //   }

  //   final chartData = Chart(
  //     date: selectedDate,
  //     dateString: selectedSection.value != 'daily' ||
  //             selectedSection.value != 'weekly'
  //         ? formatter.format(selectedDate)
  //         : '${formatter.format(pickerDateRange!.startDate!)} - ${formatter.format(pickerDateRange.endDate!)}',
  //     totalSellPrice: totalSellPrice,
  //     totalReturn: totalReturn,
  //     totalChargeReturn: totalChargeReturn,
  //     totalDiscount: totalDiscount,
  //     totalOtherCost: totalOtherCost,
  //     cash: cash,
  //     transfer: transfer,
  //     debtCash: debtCash,
  //     debtTransfer: debtTransfer,
  //     salesCash: salesCash,
  //     salesTransfer: salesTransfer,
  //     totalCostPrice: totalCostPrice,
  //     operatingCost: totalOperatingCost,
  //     totalInvoice: totalInvoice,
  //   );

  //   return chartData;
  // }

  // void deleteOperatingCost(OperatingCostModel operatingCost) async {
  //   await _operatingCostService.delete(operatingCost.id!);
  //   // await _operatingCostService.deleteOperatingCost(id);
  //   // await _operatingCostService.fetch();
  //   rangePickerHandle(DateTime.now());
  //   selectedSection.value = 'daily';
  // }
}
