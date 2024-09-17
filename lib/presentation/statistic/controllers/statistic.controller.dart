import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/chart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/models/invoice_sales_model.dart';
import '../../../infrastructure/models/operating_cost_model.dart';

class StatisticController extends GetxController {
  late final AuthService _authService = Get.find();
  final InvoiceService _invoiceService = Get.find();
  final InvoiceSalesService _invoiceSalesService = Get.find();
  final OperatingCostService _operatingCostService = Get.find();

  late final invoices = _invoiceService.invoices;
  late final salesInvoices = _invoiceSalesService.invoices;
  late final operatingCosts = _operatingCostService.operatingCosts;
  late final foundOperatingCosts = _operatingCostService.foundOperatingCost;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;

  final isDaily = true.obs;
  final selectedSection = 'daily'.obs;

  late List<InvoiceModel> currentAndPrevFilteredInvoices = <InvoiceModel>[].obs;
  late List<InvoiceSalesModel> currentAndPrevFilteredSalesInvoices =
      <InvoiceSalesModel>[].obs;
  late List<OperatingCostModel> currentAndPrevFilteredOperatingCosts =
      <OperatingCostModel>[].obs;
  late List<Chart> invoiceChart = <Chart>[].obs;
  late List<Chart> currentWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> prevWeekInvoiceChart = <Chart>[].obs;
  late List<Chart> currentMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> prevMonthInvoiceChart = <Chart>[].obs;
  late List<Chart> currentYearInvoiceChart = <Chart>[].obs;
  late List<Chart> prevYearInvoiceChart = <Chart>[].obs;
  Rx<Chart?> selectedChart = Rx<Chart?>(
    Chart(
      date: DateTime.now(),
      dateString: '',
      totalSellPrice: 0,
      totalReturn: 0,
      totalChargeReturn: 0,
      totalDiscount: 0,
      cash: 0,
      transfer: 0,
      salesCash: 0,
      salesTransfer: 0,
      totalCostPrice: 0,
      operatingCost: 0,
      totalInvoice: 0,
    ),
  );
  Rx<Chart?> prevSelectedChart = Rx<Chart?>(
    Chart(
      date: DateTime.now(),
      dateString: '',
      totalSellPrice: 0,
      totalReturn: 0,
      totalChargeReturn: 0,
      totalDiscount: 0,
      cash: 0,
      transfer: 0,
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
  final groupDate = ''.obs;
  final dailyData = true;
  final isLastIndex = false.obs;
  final isLoading = true.obs;
  final initDate = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  DateTime today = DateTime.now();

  final touchedGroupIndex = (-1).obs;
  final touchedDataIndex = (-1).obs;

  final accessOperational = true.obs;

  @override
  void onInit() async {
    print('--salesInvoices.length ${salesInvoices.length}');
    super.onInit();
    everAll([operatingCosts, invoices, salesInvoices], (_) {
      rangePickerHandle(DateTime.now());
      selectedSection.value = 'daily';
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   rangePickerHandle(DateTime.now());
      //   selectedSection.value = 'daily';
      // });
    });
    rangePickerHandle(DateTime.now());
    selectedSection.value = 'daily';
    await fetchData(DateTime.now(), 'weekly');
    accessOperational.value =
        await _authService.checkAccess('addOperationalCost');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    invoiceChart.clear();
    groupDate.value = section;

    switch (section) {
      case 'weekly':
        invoiceChart = await groupWeeklyInvoices(selectedDate);
        break;
      case 'monthly':
        invoiceChart = await groupMonthlyInvoices(selectedDate);
        break;
      case 'yearly':
        invoiceChart = await groupYearlyInvoices(selectedDate);
        break;
    }
    await compareData(selectedDate, selectedSection.value);
    isLoading.value = false;
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
    await fetchData(pickedDate, 'weekly');

    dailyOperatingCosts.value = operatingCosts.where((cost) {
      return cost.createdAt!.day == selectedDate.value.day &&
          cost.createdAt!.month == selectedDate.value.month &&
          cost.createdAt!.year == selectedDate.value.year;
    }).toList();
  }

  final selectedWeeklyRange = PickerDateRange(
          DateTime.now(), DateTime.now().subtract(const Duration(days: 6)))
      .obs;

  Future<List<Chart>> groupWeeklyInvoices(DateTime selectedDate) async {
    isLastIndex.value = selectedDate.weekday == DateTime.monday;

    DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

    DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
    DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

    currentAndPrevFilteredInvoices = invoices.where((invoice) {
      return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    }).toList();

    currentAndPrevFilteredSalesInvoices = salesInvoices.where((invoice) {
      return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    }).toList();

    currentAndPrevFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!.isAfter(prevStartOfWeek);
    }).toList();

    selectedWeeklyRange.value = PickerDateRange(
        currentStartOfWeek, currentStartOfWeek.add(const Duration(days: 6)));
    currentWeekInvoiceChart = await getChartData(currentStartOfWeek, 'current');
    prevWeekInvoiceChart = await getChartData(prevStartOfWeek, 'prev');

    return currentWeekInvoiceChart;
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

  Future<List<Chart>> groupMonthlyInvoices(DateTime selectedDate) async {
    final currentMonth = selectedDate.month;
    final prevMonth = currentMonth - 1;
    final currentYear = selectedDate.year;

    final startOfCurrentMonth = DateTime(currentYear, currentMonth, 1);
    final startOfPrevMonth = DateTime(currentYear, prevMonth, 1);
    final endOfMonth = DateTime(currentYear, currentMonth + 1, 0);

    currentAndPrevFilteredInvoices = invoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    currentAndPrevFilteredSalesInvoices = salesInvoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    currentAndPrevFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!
              .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
          invoice.createdAt!.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();

    currentMonthInvoiceChart =
        await getChartData(startOfCurrentMonth, 'current');
    prevMonthInvoiceChart = await getChartData(startOfPrevMonth, 'prev');
    return currentMonthInvoiceChart;
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

  Future<List<Chart>> groupYearlyInvoices(DateTime selectedDate) async {
    final currentYear = selectedDate.year;
    final prevYear = selectedDate.year - 1;

    final startOfCurrentYear = DateTime(currentYear, 1);
    final startOfPrevYear = DateTime(prevYear, 1);
    final endOfYear = DateTime(currentYear, 12);

    currentAndPrevFilteredInvoices = invoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    currentAndPrevFilteredSalesInvoices = salesInvoices.where((invoice) {
      return invoice.createdAt.value!
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          invoice.createdAt.value!
              .isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    currentAndPrevFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!
              .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
          invoice.createdAt!.isBefore(endOfYear.add(const Duration(days: 1)));
    }).toList();

    currentYearInvoiceChart = await getChartData(startOfCurrentYear, 'current');

    prevYearInvoiceChart = await getChartData(startOfPrevYear, '');

    return currentYearInvoiceChart;
  }

  Future<List<Chart>> getChartData(
      DateTime? selectedDate, String pastPresent) async {
    bool isCurrentSelected = pastPresent == 'current';
    final List<Chart> listChartData = [];

    final startingMonth = selectedDate!.month;
    final startingYear = selectedDate.year;

    final formatter = DateFormat('EEEE, dd/MM', 'id');

    void dayValueLooping(int i) {
      final currentDate = groupDate.value == 'weekly'
          ? selectedDate.add(Duration(days: i))
          : groupDate.value == 'monthly'
              ? DateTime(startingYear, startingMonth, i + 1)
              : DateTime(startingYear, startingMonth + i);

      final invoicesGroup = groupDate.value == 'yearly'
          ? currentAndPrevFilteredInvoices.where((invoice) {
              DateTime localDate = invoice.createdAt.value!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month;
            }).toList()
          : currentAndPrevFilteredInvoices.where((invoice) {
              DateTime localDate = invoice.createdAt.value!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month &&
                  localDate.day == currentDate.day;
            }).toList();

      final salesInvoicesGroup = groupDate.value == 'yearly'
          ? currentAndPrevFilteredSalesInvoices.where((invoice) {
              DateTime localDate = invoice.createdAt.value!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month;
            }).toList()
          : currentAndPrevFilteredSalesInvoices.where((invoice) {
              DateTime localDate = invoice.createdAt.value!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month &&
                  localDate.day == currentDate.day;
            }).toList();

      final operatingCostsGroup = groupDate.value == 'yearly'
          ? currentAndPrevFilteredOperatingCosts.where((invoice) {
              DateTime localDate = invoice.createdAt!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month;
            }).toList()
          : currentAndPrevFilteredOperatingCosts.where((invoice) {
              DateTime localDate = invoice.createdAt!;
              return localDate.year == currentDate.year &&
                  localDate.month == currentDate.month &&
                  localDate.day == currentDate.day;
            }).toList();

      DateTime date = currentDate;
      final dateString = formatter.format(date);

      double totalSellPrice = 0;
      double totalReturn = 0;
      double totalChargeReturn = 0;
      double totalDiscount = 0;

      double totalCash = 0;
      double totalTransfer = 0;

      double totalSalesCash = 0;
      double totalSalesTransfer = 0;

      double totalCostPrice = 0;

      double totalOperatingCost = 0;

      int totalInvoice = invoicesGroup.length;
      scale = 0;

      for (var inv in invoicesGroup) {
        double sellPrice = inv.subtotalBill;
        double returnPrice = inv.subtotalReturn + inv.subtotalAdditionalReturn;
        double reurnFee = inv.returnFee.value;
        double discount = inv.totalDiscount;

        double cashPay = inv.getTotalByMethod("cash");
        double transferPay = inv.getTotalByMethod("transfer");

        // int salesCash = invoice.getTotalByMethod("cash");
        // int salesTransfer = invoice.getTotalByMethod("transfer");

        double costPrice = inv.purchaseList.value.totalCost;

        totalSellPrice += sellPrice;
        totalReturn += returnPrice;
        totalChargeReturn += reurnFee;
        totalDiscount += discount;
        totalCash += cashPay;
        totalTransfer += transferPay;
        totalCostPrice += costPrice;
      }
      // print('-----salesInvoicesGroup lenght ${salesInvoicesGroup.length}');
      for (var inv in salesInvoicesGroup) {
        double salesCashPay = inv.getTotalByMethod("cash");
        double salesTransferPay = inv.getTotalByMethod("transfer");

        totalSalesCash += salesCashPay;
        totalSalesTransfer += salesTransferPay;
        // print('-----in sales pay transfer $totalSalesTransfer');
      }

      for (var op in operatingCostsGroup) {
        int operatingCost = op.amount!;

        totalOperatingCost += operatingCost;
      }
      // print('-----out sales pay transfer $totalSalesTransfer');
      final chartData = Chart(
        date: date,
        dateString: dateString,
        totalSellPrice: totalSellPrice,
        totalReturn: totalReturn,
        totalChargeReturn: totalChargeReturn,
        totalDiscount: totalDiscount,
        cash: totalCash,
        transfer: totalTransfer,
        salesCash: totalSalesCash,
        salesTransfer: totalSalesTransfer,
        totalCostPrice: totalCostPrice,
        operatingCost: totalOperatingCost,
        totalInvoice: totalInvoice,
      );

      listChartData.add(chartData);
    }

    if (isCurrentSelected) {
      maxTotalPurchase = 0;
      maxTotalProfit = 0;
      maxTotalInvoice = 0;
    }

    if (groupDate.value == 'weekly') {
      for (var day = 0; day < 7; day++) {
        dayValueLooping(day);
      }
    } else if (groupDate.value == 'monthly') {
      final totalDaysInMonth = DateTime(startingYear, startingMonth + 1, 0).day;
      for (var day = 0; day < totalDaysInMonth; day++) {
        dayValueLooping(day);
      }
    } else if (groupDate.value == 'yearly') {
      for (var day = 0; day < 12; day++) {
        dayValueLooping(day);
      }
    }

    return listChartData;
  }

  void deleteOperatingCost(OperatingCostModel operatingCost) async {
    await _operatingCostService.delete(operatingCost.id!);
    // await _operatingCostService.deleteOperatingCost(id);
    // await _operatingCostService.fetch();
    rangePickerHandle(DateTime.now());
    selectedSection.value = 'daily';
  }

  Future<void> compareData(DateTime selectedDate, String period) async {
    bool isSamePeriod(DateTime date1, DateTime date2, String period) {
      DateTime start1, end1, start2, end2;
      switch (period) {
        case 'daily':
          start1 = DateTime(date1.year, date1.month, date1.day);
          end1 = start1;
          start2 = DateTime(date2.year, date2.month, date2.day);
          end2 = start2;
          break;
        case 'weekly':
          start1 = date1.subtract(Duration(days: date1.weekday - 1));
          end1 = start1.add(const Duration(days: 6));
          start2 = date2.subtract(Duration(days: date2.weekday - 1));
          end2 = start2.add(const Duration(days: 6));
          break;
        case 'monthly':
          start1 = DateTime(date1.year, date1.month, 1);
          end1 = DateTime(date1.year, date1.month + 1, 0);
          start2 = DateTime(date2.year, date2.month, 1);
          end2 = DateTime(date2.year, date2.month + 1, 0);
          break;
        case 'yearly':
          start1 = DateTime(date1.year, 1, 1);
          end1 = DateTime(date1.year + 1, 1, 0);
          start2 = DateTime(date2.year, 1, 1);
          end2 = DateTime(date2.year + 1, 1, 0);
          break;
        default:
          return false;
      }

      return start1.isAtSameMomentAs(start2) && end1.isAtSameMomentAs(end2);
    }

    DateFormat formatter;
    switch (period) {
      case 'daily':
        formatter = DateFormat('EEEE, dd/MM', 'id');
        break;
      case 'weekly':
        formatter = DateFormat('dd/MM', 'id');
        break;
      case 'monthly':
        formatter = DateFormat('MMM y', 'id');
        break;
      default:
        formatter = DateFormat('y', 'id');
        break;
    }

    Future<Chart> reduceInvoiceList(
        List<Chart> dataInvoiceList, DateTime date) async {
      var chart = dataInvoiceList.reduce((value, element) {
        return Chart(
          date: date,
          dateString: selectedSection.value != 'weekly'
              ? formatter.format(date)
              : '${formatter.format(dataInvoiceList[0].date)} - ${formatter.format(dataInvoiceList[6].date)}',
          totalSellPrice: value.totalSellPrice + element.totalSellPrice,
          totalCostPrice: value.totalCostPrice + element.totalCostPrice,
          totalReturn: value.totalReturn + element.totalReturn,
          totalChargeReturn:
              value.totalChargeReturn + element.totalChargeReturn,
          totalDiscount: value.totalDiscount + element.totalDiscount,
          cash: value.totalCash + element.totalCash,
          transfer: value.totalTransfer + element.totalTransfer,
          salesCash: value.salesCash + element.salesCash,
          salesTransfer: value.salesTransfer + element.salesTransfer,
          operatingCost: value.operatingCost + element.operatingCost,
          totalInvoice: value.totalInvoice + element.totalInvoice,
        );
      });

      var cash = 0.0;
      var transfer = 0.0;
      var salesCash = 0.0;
      var salesTransfer = 0.0;
      for (var invoice in invoices) {
        cash += invoice.getTotalByMethod('cash', selectedDate: date);
        transfer += invoice.getTotalByMethod('transfer', selectedDate: date);
      }
      for (var invoice in salesInvoices) {
        salesCash += invoice.getTotalByMethod('cash', selectedDate: date);
        salesTransfer +=
            invoice.getTotalByMethod('transfer', selectedDate: date);
      }
      chart.cash = cash;
      chart.transfer = transfer;
      chart.salesCash = salesCash;
      chart.salesTransfer = salesTransfer;
      print('---- cash $cash');
      print('---- transfer $transfer');
      print('---- salesCash $salesCash');
      print('---- salesTransfer $salesTransfer');
      return chart;
    }

    final dataInvoiceList = invoiceChart
        .where((invoice) => isSamePeriod(invoice.date, selectedDate, period))
        .toList();

    selectedChart.value =
        await reduceInvoiceList(dataInvoiceList, selectedDate);

    List<Chart> prevList = isLastIndex.value
        ? groupDate.value == 'weekly'
            ? prevWeekInvoiceChart
            : prevMonthInvoiceChart
        : invoiceChart;

    if (dataInvoiceList.isNotEmpty) {
      DateTime prevPeriod;
      switch (period) {
        case 'daily':
          prevPeriod = selectedDate.subtract(const Duration(days: 1));
          final prevDayInvoiceList = prevList
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevDayInvoiceList, prevPeriod);
          break;
        case 'weekly':
          prevPeriod = selectedDate.subtract(const Duration(days: 7));
          final prevWeekInvoiceList = prevWeekInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevWeekInvoiceList, prevPeriod);
          break;
        case 'monthly':
          prevPeriod = DateTime(selectedDate.year, selectedDate.month - 1);
          final prevMonthInvoiceList = prevMonthInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevMonthInvoiceList, prevPeriod);
          break;
        case 'yearly':
          prevPeriod = DateTime(selectedDate.year - 1);
          final prevYearInvoiceList = prevYearInvoiceChart
              .where(
                  (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
              .toList();
          prevSelectedChart.value =
              await reduceInvoiceList(prevYearInvoiceList, prevPeriod);
          break;
        default:
          return;
      }
    }
  }

  Widget percentage(int value, int prevValue, BuildContext context) {
    double doubleValue = ((value - prevValue) / prevValue * 100);
    String formattedValue = doubleValue.toStringAsFixed(2);

    if (prevValue == 0 || doubleValue == 0) {
      return Text('(0%)',
          style: context.textTheme.bodySmall!.copyWith(
            fontSize: 10,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ));
    }
    // Hapus .00 jika ada
    if (formattedValue.endsWith('.00')) {
      formattedValue = formattedValue.substring(0, formattedValue.length - 3);
    }

    String sign = doubleValue >= 0 ? "+" : "";
    Color color = doubleValue >= 0 ? Colors.green : Colors.red;

    return Text('($sign$formattedValue%)',
        style: context.textTheme.bodySmall!.copyWith(
          fontSize: 10,
          color: color,
          fontStyle: FontStyle.italic,
        ));
  }

  //! dateTime
  final isDateTimeNow = false.obs;
  final selectedTime = TimeOfDay.now().obs;
  final displayDate = DateTime.now().toString().obs;
  final displayTime = TimeOfDay.now().toString().obs;
}
