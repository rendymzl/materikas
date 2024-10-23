import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/chart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/operating_cost_model.dart';
import '../../../infrastructure/models/payment_model.dart';

class StatisticController extends GetxController {
  late final AuthService authService = Get.find();
  late final BillingService billingService = Get.find();
  final InvoiceService invoiceService = Get.find();
  final InvoiceSalesService _invoiceSalesService = Get.find();
  final OperatingCostService _operatingCostService = Get.find();

  late final operatingCosts = _operatingCostService.operatingCosts;
  late final foundOperatingCosts = _operatingCostService.foundOperatingCost;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;
  late final invoices = <InvoiceModel>[].obs;
  // late final paymentsByDate = <PaymentMapModel>[].obs;
  // late final paymentsAll = <PaymentMapModel>[].obs;
  // late List<InvoiceModel> currentInvoices = <InvoiceModel>[].obs;
  late List<InvoiceModel> byPaymentDateInvoices = <InvoiceModel>[].obs;
  // late final selectedPayments = <PaymentMapModel>[].obs;

  final isDaily = true.obs;
  final selectedSection = 'daily'.obs;

  late List<InvoiceSalesModel> currentFilteredSalesInvoices =
      <InvoiceSalesModel>[].obs;
  late List<OperatingCostModel> currentFilteredOperatingCosts =
      <OperatingCostModel>[].obs;

  Rx<Chart?> selectedChart = Rx<Chart?>(
    Chart(
      date: DateTime.now(),
      dateString: '',
      totalSellPrice: 0,
      totalReturn: 0,
      totalChargeReturn: 0,
      totalDiscount: 0,
      totalOtherCost: 0,
      cash: 0,
      transfer: 0,
      debtCash: 0,
      debtTransfer: 0,
      salesCash: 0,
      salesTransfer: 0,
      totalCostPrice: 0,
      operatingCost: 0,
      totalInvoice: 0,
    ),
  );

  int maxTotalPurchase = 0;
  int maxTotalProfit = 0;
  int maxTotalInvoice = 0;
  int scale = 0;

  final dailyData = true;
  final isLastIndex = false.obs;
  final isLoading = false.obs;
  final initDate = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  DateTime today = DateTime.now();

  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  final accessOperational = true.obs;

  @override
  void onInit() async {
    print('--salesInvoices.length ${_invoiceSalesService.invoices.length}');
    super.onInit();
    billingService.getBillAmount();
    everAll([
      operatingCosts,
      // invoiceService.paidInv,
      // invoiceService.debtInv,
      _invoiceSalesService.invoices
    ], (_) {
      rangePickerHandle(DateTime.now());
      selectedSection.value = 'daily';
    });
    rangePickerHandle(DateTime.now());
    selectedSection.value = 'daily';
    await fetchData(DateTime.now(), selectedSection.value);
    accessOperational.value =
        await authService.checkAccess('addOperationalCost');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    // isLoading.value = true;

    switch (section) {
      case 'daily':
        selectedChart.value = await groupDailyInvoices(selectedDate);
        // isLoading.value = false;
        break;
      case 'weekly':
        selectedChart.value = await groupWeeklyInvoices(selectedDate);
        // isLoading.value = false;
        break;
      case 'monthly':
        selectedChart.value = await groupMonthlyInvoices(selectedDate);
        // isLoading.value = false;
        break;
      case 'yearly':
        selectedChart.value = await groupYearlyInvoices(selectedDate);
        // isLoading.value = false;
        break;
    }
    // isLoading.value = false;
  }

//! Daily & Weekly ======================================================
  final dailyRangeController = DateRangePickerController().obs;
  final weeklyRangeController = DateRangePickerController().obs;
  final args = DateTime.now().obs;

  void rangePickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    final DateTime startDate = await getStartofWeek(pickedDate);

    final DateTime endDate = startDate.add(const Duration(days: 6));
    final newSelectedPickerRange = PickerDateRange(startDate, endDate);

    selectedWeeklyRange.value = newSelectedPickerRange;
    weeklyRangeController.value.selectedRange = newSelectedPickerRange;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, selectedSection.value);

    dailyOperatingCosts.value = operatingCosts.where((cost) {
      return cost.createdAt!.day == selectedDate.value.day &&
          cost.createdAt!.month == selectedDate.value.month &&
          cost.createdAt!.year == selectedDate.value.year;
    }).toList();
  }

  final selectedWeeklyRange = PickerDateRange(
          DateTime.now(), DateTime.now().subtract(const Duration(days: 6)))
      .obs;

//! daily ======================================================
  Future<Chart> groupDailyInvoices(DateTime selectedDate) async {
    PickerDateRange pickerDateRange = PickerDateRange(
        selectedDate, selectedDate.add(const Duration(days: 1)));

    // paymentsAll.assignAll(await invoiceService.getAllPayment());
    // paymentsByDate
    //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));
    // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
    byPaymentDateInvoices = await invoiceService.getByPaymentDate(selectedDate);

    invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

    currentFilteredSalesInvoices =
        _invoiceSalesService.invoices.where((invoice) {
      return DateTime(invoice.createdAt.value!.year,
              invoice.createdAt.value!.month, invoice.createdAt.value!.day) ==
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }).toList();

    currentFilteredOperatingCosts = operatingCosts.where((invoice) {
      return DateTime(invoice.createdAt!.year, invoice.createdAt!.month,
              invoice.createdAt!.day) ==
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    }).toList();

    return await getChartData(pickerDateRange, selectedDate);
  }

//! Weekly ======================================================
  Future<Chart> groupWeeklyInvoices(DateTime selectedDate) async {
    isLastIndex.value = selectedDate.weekday == DateTime.monday;

    DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

    DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
    DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

    PickerDateRange pickerDateRange = PickerDateRange(
        currentStartOfWeek.subtract(const Duration(days: 1)),
        currentStartOfWeek.add(const Duration(days: 7)));
    // paymentsAll.assignAll(await invoiceService.getAllPayment());
    // paymentsByDate
    //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));

    // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);

    invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

    currentFilteredSalesInvoices =
        _invoiceSalesService.invoices.where((invoice) {
      return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    }).toList();

    currentFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!.isAfter(prevStartOfWeek);
    }).toList();

    selectedWeeklyRange.value = PickerDateRange(
        currentStartOfWeek, currentStartOfWeek.add(const Duration(days: 6)));

    return await getChartData(selectedWeeklyRange.value, selectedDate);
  }

  Future<DateTime> getStartofWeek(DateTime selectedDate) async {
    final selectedDay = selectedDate.weekday;
    final offset = selectedDay - DateTime.monday;
    final startOfWeek = selectedDate.subtract(Duration(days: offset));

    return startOfWeek;
  }

//! Monthly ======================================================
  final monthlyRangeController = DateRangePickerController().obs;

  void monthPickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, 'monthly');
  }

  Future<Chart> groupMonthlyInvoices(DateTime selectedDate) async {
    final currentMonth = selectedDate.month;
    final prevMonth = currentMonth - 1;
    final currentYear = selectedDate.year;

    final startOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final startOfPrevMonth = DateTime(currentYear, prevMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    PickerDateRange pickerDateRange = PickerDateRange(
        startOfCurrentMonth.subtract(const Duration(days: 1)),
        endOfMonth.add(const Duration(days: 1)));

    // paymentsAll.assignAll(await invoiceService.getAllPayment());
    // paymentsByDate
    //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));

    // currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
    invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

    currentFilteredSalesInvoices =
        _invoiceSalesService.invoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    currentFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          invoice.createdAt!.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    return await getChartData(pickerDateRange, selectedDate);
  }

//! Yearly ======================================================
  final yearlyRangeController = DateRangePickerController().obs;

  void yearPickerHandle(DateTime pickedDate) async {
    args.value = pickedDate;

    selectedDate.value = pickedDate;
    dailyRangeController.value.selectedDate = pickedDate;
    monthlyRangeController.value.selectedDate = pickedDate;
    yearlyRangeController.value.selectedDate = pickedDate;
    await fetchData(pickedDate, 'yearly');
  }

  Future<Chart> groupYearlyInvoices(DateTime selectedDate) async {
    final currentYear = selectedDate.year;
    final prevYear = selectedDate.year - 1;

    final startOfCurrentYear = DateTime(currentYear, 1);
    final startOfPrevYear = DateTime(prevYear, 1);
    final endOfYear = DateTime(currentYear, 12);

    PickerDateRange pickerDateRange = PickerDateRange(
        startOfCurrentYear.add(const Duration(milliseconds: 1)),
        endOfYear.add(const Duration(days: 1)));

    // paymentsAll.assignAll(await invoiceService.getAllPayment());
    // paymentsByDate
    //     .assignAll(await invoiceService.getPaymentByDate(pickerDateRange));
    invoices.value = await invoiceService.getByCreatedDate(pickerDateRange);

    currentFilteredSalesInvoices =
        _invoiceSalesService.invoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    currentFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          invoice.createdAt!.isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    return await getChartData(pickerDateRange, selectedDate);
  }

  Future<Chart> getChartData(
      PickerDateRange? pickerDateRange, DateTime selectedDate) async {
    final formatter = DateFormat('EEEE, dd/MM', 'id');

    double totalSellPrice = 0;
    double totalReturn = 0;
    double totalChargeReturn = 0;
    double totalDiscount = 0;
    double totalOtherCost = 0;
    double totalCostPrice = 0;

    double totalOperatingCost = 0;

    var cash = 0.0;
    var transfer = 0.0;
    var debtCash = 0.0;
    var debtTransfer = 0.0;
    var salesCash = 0.0;
    var salesTransfer = 0.0;

    var totalInvoice = invoices.length;

    for (var inv in invoices) {
      double sellPrice = inv.subTotalPurchase;
      double returnPrice = inv.totalReturn;
      double returnFee = inv.returnFee.value;
      double discount = inv.totalDiscount;
      double otherCost = inv.totalOtherCosts;
      double costPrice = inv.purchaseList.value.subtotalCost;

      totalSellPrice += sellPrice;
      totalReturn += returnPrice;
      totalChargeReturn += returnFee;
      totalDiscount += discount;
      totalOtherCost += otherCost;
      totalCostPrice += costPrice;
    }

    for (var op in currentFilteredOperatingCosts) {
      int operatingCost = op.amount!;
      totalOperatingCost += operatingCost;
    }

    for (var invoice in _invoiceSalesService.invoices) {
      salesCash += invoice.getTotalByMethod('cash', selectedDate: selectedDate);
      salesTransfer +=
          invoice.getTotalByMethod('transfer', selectedDate: selectedDate);
    }

    for (var invoice in invoices) {
      cash += invoice.getTotalPayByMethod('cash', selectedDate: selectedDate);
      transfer +=
          invoice.getTotalPayByMethod('transfer', selectedDate: selectedDate);
    }

    for (var invoice in byPaymentDateInvoices) {
      debtCash +=
          invoice.getTotalDebtByMethod('cash', selectedDate: selectedDate);
      debtTransfer +=
          invoice.getTotalDebtByMethod('transfer', selectedDate: selectedDate);
    }

    // for (var payment in paymentsAll) {
    //   double paymentDebtCash = 0;
    //   double paymentDebtTransfer = 0;
    //   var filteredPayment = payment.payments.where((transaksi) {
    //     final date = transaksi.date;
    //     return date!.isAfter(pickerDateRange!.startDate!) &&
    //         date.isBefore(pickerDateRange.endDate!);
    //   }).toList();

    //   for (var pay in filteredPayment) {
    //     DateTime paymentDate =
    //         DateTime(pay.date!.year, pay.date!.month, pay.date!.day);
    //     DateTime createdDate = DateTime(payment.createdAt.value!.year,
    //         payment.createdAt.value!.month, payment.createdAt.value!.day);
    //     if (!paymentDate.isAtSameMomentAs(createdDate)) {
    //       if (pay.method == 'cash') {
    //         paymentDebtCash = pay.finalAmountPaid;
    //       } else {
    //         paymentDebtTransfer = pay.finalAmountPaid;
    //       }
    //     }
    //   }

    //   debtCash += paymentDebtCash;
    //   debtTransfer += paymentDebtTransfer;
    // }
    // for (var payment in paymentsByDate) {
    //   double paymentCash = 0;
    //   double paymentTransfer = 0;
    //   double rdebtCash = 0;
    //   double rdebtTransfer = 0;
    //   for (var pay in payment.payments) {
    //     DateTime paymentDate =
    //         DateTime(pay.date!.year, pay.date!.month, pay.date!.day);
    //     DateTime createdDate = DateTime(payment.createdAt.value!.year,
    //         payment.createdAt.value!.month, payment.createdAt.value!.day);
    //     if (paymentDate.isAtSameMomentAs(createdDate)) {
    //       if (pay.method == 'cash') {
    //         rcash = pay.finalAmountPaid;
    //       } else {
    //         rtransfer = pay.finalAmountPaid;
    //       }
    //     } else if (pay.method == 'cash') {
    //       rdebtCash = pay.finalAmountPaid;
    //     } else {
    //       rdebtTransfer = pay.finalAmountPaid;
    //     }
    //   }

    //   cash += rcash;
    //   transfer += rtransfer;
    //   debtCash += rdebtCash;
    //   debtTransfer += rdebtTransfer;
    // }

    final chartData = Chart(
      date: selectedDate,
      dateString: selectedSection.value != 'daily' ||
              selectedSection.value != 'weekly'
          ? formatter.format(selectedDate)
          : '${formatter.format(pickerDateRange!.startDate!)} - ${formatter.format(pickerDateRange.endDate!)}',
      totalSellPrice: totalSellPrice,
      totalReturn: totalReturn,
      totalChargeReturn: totalChargeReturn,
      totalDiscount: totalDiscount,
      totalOtherCost: totalOtherCost,
      cash: cash,
      transfer: transfer,
      debtCash: debtCash,
      debtTransfer: debtTransfer,
      salesCash: salesCash,
      salesTransfer: salesTransfer,
      totalCostPrice: totalCostPrice,
      operatingCost: totalOperatingCost,
      totalInvoice: totalInvoice,
    );

    return chartData;
  }

  void deleteOperatingCost(OperatingCostModel operatingCost) async {
    await _operatingCostService.delete(operatingCost.id!);
    // await _operatingCostService.deleteOperatingCost(id);
    // await _operatingCostService.fetch();
    rangePickerHandle(DateTime.now());
    selectedSection.value = 'daily';
  }
}
