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
  late final AuthService authService = Get.find();
  final InvoiceService invoiceService = Get.find();
  final InvoiceSalesService _invoiceSalesService = Get.find();
  final OperatingCostService _operatingCostService = Get.find();

  // late final invoices = invoiceService.invoices;
  // late final salesInvoices = _invoiceSalesService.invoices;
  late final operatingCosts = _operatingCostService.operatingCosts;
  late final foundOperatingCosts = _operatingCostService.foundOperatingCost;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;

  final isDaily = true.obs;
  final selectedSection = 'daily'.obs;

  late List<InvoiceModel> currentInvoices = <InvoiceModel>[].obs;
  late List<InvoiceModel> byPaymentDateInvoices = <InvoiceModel>[].obs;
  late final monthlyInvoice = 0.0.obs;
  late List<InvoiceSalesModel> currentFilteredSalesInvoices =
      <InvoiceSalesModel>[].obs;
  late List<OperatingCostModel> currentFilteredOperatingCosts =
      <OperatingCostModel>[].obs;
  late List<Chart> invoiceChart = <Chart>[].obs;
  late List<Chart> dailyInvoiceChart = <Chart>[].obs;
  late List<Chart> weeklyInvoiceChart = <Chart>[].obs;
  late List<Chart> monthlyInvoiceChart = <Chart>[].obs;
  late List<Chart> yearlyInvoiceChart = <Chart>[].obs;
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
  // Rx<Chart?> prevSelectedChart = Rx<Chart?>(
  //   Chart(
  //     date: DateTime.now(),
  //     dateString: '',
  //     totalSellPrice: 0,
  //     totalReturn: 0,
  //     totalChargeReturn: 0,
  //     totalDiscount: 0,
  //     cash: 0,
  //     transfer: 0,
  //     debtCash: 0,
  //     debtTransfer: 0,
  //     salesCash: 0,
  //     salesTransfer: 0,
  //     totalCostPrice: 0,
  //     operatingCost: 0,
  //     totalInvoice: 0,
  //   ),
  // );
  int maxTotalPurchase = 0;
  int maxTotalProfit = 0;
  int maxTotalInvoice = 0;
  int scale = 0;

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
    print('--salesInvoices.length ${_invoiceSalesService.invoices.length}');
    super.onInit();
    monthlyInvoice.value =
        await invoiceService.getAppBill(DateTime.now().month);
    everAll([
      operatingCosts,
      invoiceService.paidInv,
      invoiceService.debtInv,
      _invoiceSalesService.invoices
    ], (_) {
      rangePickerHandle(DateTime.now());
      selectedSection.value = 'daily';
      // Future.delayed(const Duration(milliseconds: 500), () {
      //   rangePickerHandle(DateTime.now());
      //   selectedSection.value = 'daily';
      // });
    });
    rangePickerHandle(DateTime.now());
    selectedSection.value = 'daily';
    await fetchData(DateTime.now(), selectedSection.value);
    accessOperational.value =
        await authService.checkAccess('addOperationalCost');
  }

  Future<void> fetchData(DateTime selectedDate, String section) async {
    invoiceChart.clear();

    switch (section) {
      case 'daily':
        invoiceChart = await groupDailyInvoices(selectedDate);
        break;
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
  Future<List<Chart>> groupDailyInvoices(DateTime selectedDate) async {
    PickerDateRange pickerDateRange = PickerDateRange(
        selectedDate, selectedDate.add(const Duration(days: 1)));
    currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);

    byPaymentDateInvoices = await invoiceService.getByPaymentDate(selectedDate);

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

    dailyInvoiceChart = await getChartData(selectedDate);

    return dailyInvoiceChart;
  }

//! Weekly ======================================================
  Future<List<Chart>> groupWeeklyInvoices(DateTime selectedDate) async {
    isLastIndex.value = selectedDate.weekday == DateTime.monday;

    DateTime prevWeekPickedDay = selectedDate.subtract(const Duration(days: 7));

    DateTime currentStartOfWeek = await getStartofWeek(selectedDate);
    DateTime prevStartOfWeek = await getStartofWeek(prevWeekPickedDay);

    PickerDateRange pickerDateRange = PickerDateRange(
        currentStartOfWeek.subtract(const Duration(days: 1)),
        currentStartOfWeek.add(const Duration(days: 7)));

    currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);
    // await invoiceService.getByPaymentDate(selectedDate);
    //     invoiceService.paidInv.where((invoice) {
    //   return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    // }).toList();
    // currentAndPrevFilteredDebtInvoices =
    //     invoiceService.debtInv.where((invoice) {
    //   return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    // }).toList();

    currentFilteredSalesInvoices =
        _invoiceSalesService.invoices.where((invoice) {
      return invoice.createdAt.value!.isAfter(prevStartOfWeek);
    }).toList();

    currentFilteredOperatingCosts = operatingCosts.where((invoice) {
      return invoice.createdAt!.isAfter(prevStartOfWeek);
    }).toList();

    selectedWeeklyRange.value = PickerDateRange(
        currentStartOfWeek, currentStartOfWeek.add(const Duration(days: 6)));
    weeklyInvoiceChart = await getChartData(currentStartOfWeek);

    return weeklyInvoiceChart;
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

    PickerDateRange pickerDateRange = PickerDateRange(
        startOfCurrentMonth.subtract(const Duration(days: 1)),
        endOfMonth.add(const Duration(days: 1)));

    currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);

    // currentInvoices = invoiceService.paidInv.where((invoice) {
    //   return invoice.createdAt.value!
    //           .isAfter(startOfPrevMonth.subtract(const Duration(days: 1))) &&
    //       invoice.createdAt.value!
    //           .isBefore(endOfMonth.add(const Duration(days: 1)));
    // }).toList();

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

    monthlyInvoiceChart = await getChartData(startOfCurrentMonth);
    return monthlyInvoiceChart;
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

    PickerDateRange pickerDateRange = PickerDateRange(
        startOfCurrentYear.add(const Duration(milliseconds: 1)),
        endOfYear.add(const Duration(days: 1)));

    currentInvoices = await invoiceService.getByCreatedDate(pickerDateRange);

    // currentInvoices = invoiceService.paidInv.where((invoice) {
    //   return invoice.createdAt.value!
    //           .isAfter(startOfPrevYear.subtract(const Duration(days: 1))) &&
    //       invoice.createdAt.value!
    //           .isBefore(endOfYear.add(const Duration(days: 1)));
    // }).toList();

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

    yearlyInvoiceChart = await getChartData(startOfCurrentYear);

    return yearlyInvoiceChart;
  }

  Future<List<Chart>> getChartData(DateTime? selectedDate) async {
    final List<Chart> listChartData = [];

    var startingMonth = selectedDate!.month;
    final startingYear = selectedDate.year;

    final formatter = DateFormat('EEEE, dd/MM', 'id');

    void dayValueLooping(int i) {
      DateTime currentDate = selectedDate;
      switch (selectedSection.value) {
        case 'weekly':
          currentDate = selectedDate.add(Duration(days: i));
          break;
        case 'monthly':
          currentDate = DateTime(startingYear, startingMonth, i + 1);
          break;
        case 'yearly':
          currentDate = currentDate = DateTime(startingYear, startingMonth, i);
          break;
        // case 'yearly':
        //   currentDate = DateTime(startingYear, startingMonth + i);
        //   break;
      }

      var invoicesGroup =
          // selectedSection.value == 'yearly'
          //     ? currentInvoices.where((invoice) {
          //         DateTime localDate = invoice.createdAt.value!;
          //         return localDate.year == currentDate.year &&
          //             localDate.month == currentDate.month;
          //       }).toList()
          //     :
          currentInvoices.where((invoice) {
        DateTime localDate = invoice.createdAt.value!;
        return localDate.year == currentDate.year &&
            localDate.month == currentDate.month &&
            localDate.day == currentDate.day;
      }).toList();

      final operatingCostsGroup =
          // selectedSection.value == 'yearly'
          //     ? currentFilteredOperatingCosts.where((invoice) {
          //         DateTime localDate = invoice.createdAt!;
          //         return localDate.year == currentDate.year &&
          //             localDate.month == currentDate.month;
          //       }).toList()
          //     :
          currentFilteredOperatingCosts.where((invoice) {
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
      double totalOtherCost = 0;

      double totalCostPrice = 0;

      double totalOperatingCost = 0;

      int totalInvoice = invoicesGroup.length;
      scale = 0;

      for (var inv in invoicesGroup) {
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

      var cash = 0.0;
      var transfer = 0.0;
      var debtCash = 0.0;
      var debtTransfer = 0.0;
      var salesCash = 0.0;
      var salesTransfer = 0.0;
      for (var invoice in currentInvoices) {
        cash += invoice.getTotalPayByMethod('cash', selectedDate: date);
        transfer += invoice.getTotalPayByMethod('transfer', selectedDate: date);
      }

      Future.delayed(const Duration(seconds: 1), () {
        print(date);
      });

      for (var invoice in byPaymentDateInvoices) {
        debtCash += invoice.getTotalDebtByMethod('cash', selectedDate: date);
        debtTransfer +=
            invoice.getTotalDebtByMethod('transfer', selectedDate: date);
      }

      for (var invoice in _invoiceSalesService.invoices) {
        salesCash += invoice.getTotalByMethod('cash', selectedDate: date);
        salesTransfer +=
            invoice.getTotalByMethod('transfer', selectedDate: date);
      }

      for (var op in operatingCostsGroup) {
        int operatingCost = op.amount!;

        totalOperatingCost += operatingCost;
      }

      final chartData = Chart(
        date: date,
        dateString: dateString,
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

      listChartData.add(chartData);
    }

    maxTotalPurchase = 0;
    maxTotalProfit = 0;
    maxTotalInvoice = 0;

    int totalDays = 1;
    int totalMonth = 12;
    if (selectedSection.value == 'weekly') {
      totalDays = 7;
    } else if (selectedSection.value == 'monthly') {
      totalDays = DateTime(startingYear, startingMonth + 1, 0).day;
    }

    if (selectedSection.value == 'yearly') {
      for (var month = 1; month <= totalMonth; month++) {
        startingMonth = month;

        totalDays = DateTime(startingYear, startingMonth + 1, 0).day;

        for (var day = 0; day < totalDays; day++) {
          Future.delayed(const Duration(seconds: 1), () {
            print(startingYear);
            print(day);
          });
          dayValueLooping(day);
        }
      }
    } else {
      for (var day = 0; day < totalDays; day++) {
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
          dateString: selectedSection.value != 'daily' ||
                  selectedSection.value != 'weekly'
              ? formatter.format(date)
              : '${formatter.format(dataInvoiceList[0].date)} - ${formatter.format(dataInvoiceList[6].date)}',
          totalSellPrice: value.totalSellPrice + element.totalSellPrice,
          totalCostPrice: value.totalCostPrice + element.totalCostPrice,
          totalReturn: value.totalReturn + element.totalReturn,
          totalChargeReturn:
              value.totalChargeReturn + element.totalChargeReturn,
          totalDiscount: value.totalDiscount + element.totalDiscount,
          totalOtherCost: value.totalOtherCost + element.totalOtherCost,
          cash: value.cash + element.cash,
          transfer: value.transfer + element.transfer,
          debtCash: value.debtCash + element.debtCash,
          debtTransfer: value.debtTransfer + element.debtTransfer,
          salesCash: value.salesCash + element.salesCash,
          salesTransfer: value.salesTransfer + element.salesTransfer,
          operatingCost: value.operatingCost + element.operatingCost,
          totalInvoice: value.totalInvoice + element.totalInvoice,
        );
      });

      return chart;
    }

    final dataInvoiceList = invoiceChart
        .where((invoice) => isSamePeriod(invoice.date, selectedDate, period))
        .toList();

    selectedChart.value =
        await reduceInvoiceList(dataInvoiceList, selectedDate);

    // List<Chart> prevList = isLastIndex.value
    //     ? selectedSection.value == 'weekly'
    //         ? prevWeekInvoiceChart
    //         : prevMonthInvoiceChart
    //     : invoiceChart;

    // if (dataInvoiceList.isNotEmpty) {
    //   // DateTime prevPeriod;
    //   switch (period) {
    //     case 'daily':
    //       prevPeriod = selectedDate.subtract(const Duration(days: 1));
    //       final prevDayInvoiceList = prevList
    //           .where(
    //               (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
    //           .toList();
    //       prevSelectedChart.value =
    //           await reduceInvoiceList(prevDayInvoiceList, prevPeriod);
    //       break;
    //     case 'weekly':
    //       prevPeriod = selectedDate.subtract(const Duration(days: 7));
    //       final prevWeekInvoiceList = prevWeekInvoiceChart
    //           .where(
    //               (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
    //           .toList();
    //       prevSelectedChart.value =
    //           await reduceInvoiceList(prevWeekInvoiceList, prevPeriod);
    //       break;
    //     case 'monthly':
    //       prevPeriod = DateTime(selectedDate.year, selectedDate.month - 1);
    //       final prevMonthInvoiceList = prevMonthInvoiceChart
    //           .where(
    //               (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
    //           .toList();
    //       prevSelectedChart.value =
    //           await reduceInvoiceList(prevMonthInvoiceList, prevPeriod);
    //       break;
    //     case 'yearly':
    //       prevPeriod = DateTime(selectedDate.year - 1);
    //       final prevYearInvoiceList = prevYearInvoiceChart
    //           .where(
    //               (invoice) => isSamePeriod(invoice.date, prevPeriod, period))
    //           .toList();
    //       prevSelectedChart.value =
    //           await reduceInvoiceList(prevYearInvoiceList, prevPeriod);
    //       break;
    //     default:
    //       return;
    //   }
    // }
  }

  // Widget percentage(int value, int prevValue, BuildContext context) {
  //   double doubleValue = ((value - prevValue) / prevValue * 100);
  //   String formattedValue = doubleValue.toStringAsFixed(2);

  //   if (prevValue == 0 || doubleValue == 0) {
  //     return Text('(0%)',
  //         style: context.textTheme.bodySmall!.copyWith(
  //           fontSize: 10,
  //           color: Colors.grey,
  //           fontStyle: FontStyle.italic,
  //         ));
  //   }
  //   // Hapus .00 jika ada
  //   if (formattedValue.endsWith('.00')) {
  //     formattedValue = formattedValue.substring(0, formattedValue.length - 3);
  //   }

  //   String sign = doubleValue >= 0 ? "+" : "";
  //   Color color = doubleValue >= 0 ? Colors.green : Colors.red;

  //   return Text('($sign$formattedValue%)',
  //       style: context.textTheme.bodySmall!.copyWith(
  //         fontSize: 10,
  //         color: color,
  //         fontStyle: FontStyle.italic,
  //       ));
  // }

  //! dateTime
  // final isDateTimeNow = false.obs;
  // final selectedTime = TimeOfDay.now().obs;
  // final displayDate = DateTime.now().toString().obs;
  // final displayTime = TimeOfDay.now().toString().obs;
}
