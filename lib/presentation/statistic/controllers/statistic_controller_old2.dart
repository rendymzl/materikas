// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// import '../../../infrastructure/dal/services/auth_service.dart';
// import '../../../infrastructure/dal/services/billing_service.dart';
// import '../../../infrastructure/dal/services/invoice_sales_service.dart';
// import '../../../infrastructure/dal/services/invoice_service.dart';
// import '../../../infrastructure/dal/services/operating_cost_service.dart';
// import '../../../infrastructure/models/chart_model.dart';
// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/models/invoice_sales_model.dart';

// class StatisticController extends GetxController {
//   late final AuthService authService = Get.find();
//   late final BillingService billingService = Get.find();
//   late final InvoiceService invoiceService = Get.find();
//   late final InvoiceSalesService invoiceSalesService = Get.find();
//   late final OperatingCostService operatingCostService = Get.find();

//   // late final invoices = <InvoiceModel>[].obs;
//   late final invoicesSalesByPaymentDate = <InvoiceSalesModel>[].obs;
//   late final invoicesByPaymentDate = <InvoiceModel>[].obs;
//   // late final operatingCosts = <OperatingCostModel>[].obs;
//   // late final byPaymentDateInvoices = <PaymentMapModel>[].obs;

//   final displaySection = ['transaction', 'payment'].obs;
//   final selectedPaymentMethod = 'transaction'.obs;
//   final selectedDate = DateTime.now().obs;
//   final selectedSection = 'daily'.obs;
//   final isFetching = false.obs;
//   final isLoading = false.obs;

//   // Rx<Chart?> selectedChart = Rx<Chart?>(null);
//   late final chartList = <Chart>[].obs;

//   final accessOperational = true.obs;

//   @override
//   void onInit() async {
//     billingService.getBillAmount();
//     selectedSection.value = 'daily';

//     // dailyPickerHandle(DateTime.now());
//     weeklyPickerHandle(DateTime.now());

//     accessOperational.value =
//         await authService.checkAccess('addOperationalCost');
//     super.onInit();
//   }

//   // Future<void> fetchData(PickerDateRange selectedDate, String section) async {
//   //   // isLoading.value = true;

//   //   switch (section) {
//   //     case 'daily':
//   //       selectedChart.value = await getChartData(selectedDate);
//   //       // isLoading.value = false;
//   //       break;
//   //     case 'weekly':
//   //       selectedChart.value = await getChartData(selectedDate);
//   //       // isLoading.value = false;
//   //       break;
//   //     case 'monthly':
//   //       selectedChart.value = await getChartData(selectedDate);
//   //       // isLoading.value = false;
//   //       break;
//   //     case 'yearly':
//   //       selectedChart.value = await getChartData(selectedDate);
//   //       // isLoading.value = false;
//   //       break;
//   //   }
//   //   // isLoading.value = false;
//   // }

// //! Daily & Weekly ======================================================
//   final dailyRangeController = DateRangePickerController().obs;
//   final weeklyRangeController = DateRangePickerController().obs;
//   final monthlyRangeController = DateRangePickerController().obs;
//   final yearlyRangeController = DateRangePickerController().obs;

//   // void dailyPickerHandle(DateTime pickedDate) async {
//   //   dailyRangeController.value.selectedDate = pickedDate;
//   //   final startDate =
//   //       DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
//   //   final endDate = startDate.add(Duration(days: 1));
//   //   final pickerDateRange = PickerDateRange(startDate, endDate);
//   //   print(pickerDateRange);

//   //   selectedChart.value = await getChartData(pickerDateRange);
//   //   // final startDate =
//   //   //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
//   //   // final endDate = startDate.add(Duration(days: 1));
//   //   // final selectedDateRange = PickerDateRange(startDate, endDate);
//   // }

//   void weeklyPickerHandle(DateTime pickedDate) async {
//     dailyRangeController.value.selectedDate = pickedDate;
//     final endDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
//     final startDate = endDate.subtract(Duration(days: 6));
//     final pickerDateRange = PickerDateRange(startDate, endDate);
//     weeklyRangeController.value.selectedRange = pickerDateRange;
//     selectedChart.value = await getChartData(pickerDateRange);
//     print(pickerDateRange);
//   }

//   void monthlyPickerHandle(DateTime pickedDate) async {
//     final startDate = DateTime(pickedDate.year, pickedDate.month, 1);

//     DateTime endDate;
//     if (pickedDate.month == 12) {
//       endDate = DateTime(pickedDate.year + 1, 1, 1).subtract(Duration(days: 1));
//     } else {
//       endDate = DateTime(pickedDate.year, pickedDate.month + 1, 1)
//           .subtract(Duration(days: 1));
//     }

//     final pickerDateRange = PickerDateRange(startDate, endDate);
//     monthlyRangeController.value.selectedDate = pickedDate;
//     selectedChart.value = await getChartData(pickerDateRange);
//     print(pickerDateRange);
//   }

//   void yearlyPickerHandle(DateTime pickedDate) async {
//     final startDate = DateTime(pickedDate.year, 1, 1);
//     final endDate =
//         DateTime(pickedDate.year + 1, 1, 1).subtract(Duration(days: 1));

//     final pickerDateRange = PickerDateRange(startDate, endDate);
//     yearlyRangeController.value.selectedDate = pickedDate;
//     selectedChart.value = await getChartData(pickerDateRange);
//     print(pickerDateRange);
//   }

//   Future<Chart> getChartData(PickerDateRange pickerDateRange) async {
//     isLoading.value = true;
//     isFetching.value = true;
//     selectedDate.value = pickerDateRange.startDate!;
//     final start = DateTime.now();
//     final invoices = await invoiceService.getByCreatedDate(pickerDateRange);
//     final invoicesSales =
//         await invoiceSalesService.getByCreatedDate(pickerDateRange);
//     final operatingCosts =
//         await operatingCostService.getByDate(pickerDateRange);
//     invoicesByPaymentDate.value =
//         await invoiceService.getPaymentByDate(pickerDateRange);
//     invoicesSalesByPaymentDate.value =
//         await invoiceSalesService.getPaymentByDate(pickerDateRange);
//     final finish = DateTime.now();
//     print(
//         'invoices statistic Waktu proses: ${finish.difference(start).inMilliseconds} ms');

//     final formatter = DateFormat('EEEE, dd/MM', 'id');

//     double totalSellPrice = 0;
//     double totalSellPriceSales = 0;
//     double totalReturn = 0;
//     double totalChargeReturn = 0;
//     double totalDiscount = 0;
//     double totalDiscountSales = 0;
//     double totalOtherCost = 0;
//     double totalCostPrice = 0;

//     double totalOperatingCost = 0;

//     var cash = 0.0;
//     var transfer = 0.0;
//     var deposit = 0.0;
//     var debtCash = 0.0;
//     var debtTransfer = 0.0;
//     var salesCash = 0.0;
//     var salesTransfer = 0.0;

//     var totalInvoice = invoices.length;
//     var totalInvoiceSales = invoicesSales.length;

//     for (var inv in invoices) {
//       totalSellPrice += inv.subTotalPurchase;
//       totalReturn += inv.totalReturn;
//       totalChargeReturn += inv.returnFee.value;
//       totalDiscount += inv.totalDiscount;
//       totalOtherCost += inv.totalOtherCosts;
//       totalCostPrice += inv.purchaseList.value.subtotalCost;
//     }

//     for (var op in operatingCosts) {
//       int operatingCost = op.amount!;
//       totalOperatingCost += operatingCost;
//     }

//     for (var invoice in invoicesSales) {
//       totalSellPriceSales += invoice.subtotalCost;
//       totalDiscountSales += invoice.discount.value;
//       print('invoicesSales statistic ${salesTransfer}');
//     }

//     for (var invoice in invoicesSalesByPaymentDate) {
//       salesCash += invoice.getTotalByMethod('cash',
//           selectedDate: invoice.createdAt.value);
//       salesTransfer += invoice.getTotalByMethod('transfer',
//           selectedDate: invoice.createdAt.value);
//       print('invoicesSales statistic ${salesTransfer}');
//     }

//     for (var invoice in invoicesByPaymentDate) {
//       cash += invoice.getTotalPayByMethod('cash',
//           selectedDate: invoice.createdAt.value);
//       transfer += invoice.getTotalPayByMethod('transfer',
//           selectedDate: invoice.createdAt.value);
//       deposit += invoice.getTotalPayByMethod('deposit',
//           selectedDate: invoice.createdAt.value);
//     }
//     print('depositdepositdeposit $deposit');

//     for (var invoice in invoicesByPaymentDate) {
//       debtCash += invoice.getTotalDebtByMethod('cash',
//           selectedDate: invoice.createdAt.value);
//       debtTransfer += invoice.getTotalDebtByMethod('transfer',
//           selectedDate: invoice.createdAt.value);
//     }

//     final chartData = Chart(
//       date: pickerDateRange.startDate!,
//       dateString: selectedSection.value != 'daily' ||
//               selectedSection.value != 'weekly'
//           ? formatter.format(pickerDateRange.startDate!)
//           : '${formatter.format(pickerDateRange.startDate!)} - ${formatter.format(pickerDateRange.endDate!)}',
//       totalSellPrice: totalSellPrice,
//       totalSellPriceSales: totalSellPriceSales,
//       totalReturn: totalReturn,
//       totalChargeReturn: totalChargeReturn,
//       totalDiscount: totalDiscount,
//       totalDiscountSales: totalDiscountSales,
//       totalOtherCost: totalOtherCost,
//       cash: cash,
//       transfer: transfer,
//       deposit: deposit,
//       debtCash: debtCash,
//       debtTransfer: debtTransfer,
//       salesCash: salesCash,
//       salesTransfer: salesTransfer,
//       totalCostPrice: totalCostPrice,
//       operatingCost: totalOperatingCost,
//       totalInvoice: totalInvoice,
//       totalInvoiceSales: totalInvoiceSales,
//     );
//     isFetching.value = false;
//     isLoading.value = false;
//     return chartData;
//   }
//   // Future<Chart> getChartData(PickerDateRange pickerDateRange) async {
//   //   isLoading.value = true;
//   //   isFetching.value = true;
//   //   selectedDate.value = pickerDateRange.startDate!;
//   //   final start = DateTime.now();
//   //   final invoices = await invoiceService.getByCreatedDate(pickerDateRange);
//   //   final invoicesSales =
//   //       await invoiceSalesService.getByCreatedDate(pickerDateRange);
//   //   final operatingCosts =
//   //       await operatingCostService.getByDate(pickerDateRange);
//   //   invoicesByPaymentDate.value =
//   //       await invoiceService.getPaymentByDate(pickerDateRange);
//   //   invoicesSalesByPaymentDate.value =
//   //       await invoiceSalesService.getPaymentByDate(pickerDateRange);
//   //   final finish = DateTime.now();
//   //   print(
//   //       'invoices statistic Waktu proses: ${finish.difference(start).inMilliseconds} ms');

//   //   final formatter = DateFormat('EEEE, dd/MM', 'id');

//   //   double totalSellPrice = 0;
//   //   double totalSellPriceSales = 0;
//   //   double totalReturn = 0;
//   //   double totalChargeReturn = 0;
//   //   double totalDiscount = 0;
//   //   double totalDiscountSales = 0;
//   //   double totalOtherCost = 0;
//   //   double totalCostPrice = 0;

//   //   double totalOperatingCost = 0;

//   //   var cash = 0.0;
//   //   var transfer = 0.0;
//   //   var deposit = 0.0;
//   //   var debtCash = 0.0;
//   //   var debtTransfer = 0.0;
//   //   var salesCash = 0.0;
//   //   var salesTransfer = 0.0;

//   //   var totalInvoice = invoices.length;
//   //   var totalInvoiceSales = invoicesSales.length;

//   //   for (var inv in invoices) {
//   //     totalSellPrice += inv.subTotalPurchase;
//   //     totalReturn += inv.totalReturn;
//   //     totalChargeReturn += inv.returnFee.value;
//   //     totalDiscount += inv.totalDiscount;
//   //     totalOtherCost += inv.totalOtherCosts;
//   //     totalCostPrice += inv.purchaseList.value.subtotalCost;
//   //   }

//   //   for (var op in operatingCosts) {
//   //     int operatingCost = op.amount!;
//   //     totalOperatingCost += operatingCost;
//   //   }

//   //   for (var invoice in invoicesSales) {
//   //     totalSellPriceSales += invoice.subtotalCost;
//   //     totalDiscountSales += invoice.discount.value;
//   //     print('invoicesSales statistic ${salesTransfer}');
//   //   }

//   //   for (var invoice in invoicesSalesByPaymentDate) {
//   //     salesCash += invoice.getTotalByMethod('cash',
//   //         selectedDate: invoice.createdAt.value);
//   //     salesTransfer += invoice.getTotalByMethod('transfer',
//   //         selectedDate: invoice.createdAt.value);
//   //     print('invoicesSales statistic ${salesTransfer}');
//   //   }

//   //   for (var invoice in invoicesByPaymentDate) {
//   //     cash += invoice.getTotalPayByMethod('cash',
//   //         selectedDate: invoice.createdAt.value);
//   //     transfer += invoice.getTotalPayByMethod('transfer',
//   //         selectedDate: invoice.createdAt.value);
//   //     deposit += invoice.getTotalPayByMethod('deposit',
//   //         selectedDate: invoice.createdAt.value);
//   //   }
//   //   print('depositdepositdeposit $deposit');

//   //   for (var invoice in invoicesByPaymentDate) {
//   //     debtCash += invoice.getTotalDebtByMethod('cash',
//   //         selectedDate: invoice.createdAt.value);
//   //     debtTransfer += invoice.getTotalDebtByMethod('transfer',
//   //         selectedDate: invoice.createdAt.value);
//   //   }

//   //   final chartData = Chart(
//   //     date: pickerDateRange.startDate!,
//   //     dateString: selectedSection.value != 'daily' ||
//   //             selectedSection.value != 'weekly'
//   //         ? formatter.format(pickerDateRange.startDate!)
//   //         : '${formatter.format(pickerDateRange.startDate!)} - ${formatter.format(pickerDateRange.endDate!)}',
//   //     totalSellPrice: totalSellPrice,
//   //     totalSellPriceSales: totalSellPriceSales,
//   //     totalReturn: totalReturn,
//   //     totalChargeReturn: totalChargeReturn,
//   //     totalDiscount: totalDiscount,
//   //     totalDiscountSales: totalDiscountSales,
//   //     totalOtherCost: totalOtherCost,
//   //     cash: cash,
//   //     transfer: transfer,
//   //     deposit: deposit,
//   //     debtCash: debtCash,
//   //     debtTransfer: debtTransfer,
//   //     salesCash: salesCash,
//   //     salesTransfer: salesTransfer,
//   //     totalCostPrice: totalCostPrice,
//   //     operatingCost: totalOperatingCost,
//   //     totalInvoice: totalInvoice,
//   //     totalInvoiceSales: totalInvoiceSales,
//   //   );
//   //   isFetching.value = false;
//   //   isLoading.value = false;
//   //   return chartData;
//   // }
// }
