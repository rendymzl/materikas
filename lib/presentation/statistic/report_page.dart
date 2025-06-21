import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../infrastructure/models/chart_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/statistic.controller.dart';
import 'report_money_widget.dart';
import 'report_selling_widget.dart';
// import 'report_controller.dart';

class ReportPage extends StatelessWidget {
  final controller = Get.find<StatisticController>();

  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            TabBar(
              tabs: const [
                Tab(text: "Keuangan"),
                Tab(text: "Penjualan"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFinanceReport(),
                  _buildSalesReport(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Halaman Laporan Keuangan
  Widget _buildFinanceReport() {
    return Obx(() {
      if (controller.selectedChart.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final reports = controller.chartList;
      final report = controller.selectedChart.value;

      final isArca = controller.authService.store.value!.id ==
          '4ac964d8-d504-4dec-b32a-c0d4e918918d';

      return report == null
          ? Center(child: Text('Tidak ada data'))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        report.dateDisplay.isNotEmpty
                            ? report.dateDisplay
                            : dateWihtoutTime.format(report.date).toString(),
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              // Added Expanded widget
                              child: Column(
                                // padding: EdgeInsets.all(8),
                                // shrinkWrap: true,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SummaryCard(
                                        title:
                                            "Total Pemasukan: ${currency.format(report.finalIncome)}",
                                        subtitle:
                                            'Cash: ${currency.format(report.incomeCash)}    Transfer: ${currency.format(report.incomeTransfer)}',
                                        color: Colors.green,
                                        icon: Symbols.account_balance_wallet,
                                        // tooltipMessage:
                                        //     'Cash: ${currency.format(report.incomeCash)}    Transfer: ${currency.format(report.incomeTransfer)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SummaryCard(
                                        title:
                                            "Total Pengeluaran: ${currency.format(isArca ? report.finalOutcomeArca : report.finalOutcome)}",
                                        subtitle:
                                            'Cash: ${currency.format(isArca ? report.outcomeCashArca : report.outcomeCash)}    Transfer: ${currency.format(isArca ? report.outcomeTransferArca : report.outcomeTransfer)}',
                                        color: Colors.red,
                                        icon: Symbols.account_balance_wallet,
                                        // tooltipMessage:
                                        //     'Cash: ${currency.format(report.outcomeCash)}    Transfer: ${currency.format(report.outcomeTransfer)}',
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SummaryCard(
                                        title:
                                            "Total yang diterima: ${currency.format(isArca ? report.resultIncomeOutcomeArca : report.resultIncomeOutcome)}",
                                        subtitle:
                                            'Cash: ${currency.format(isArca ? report.finalIncomeCashArca : report.finalIncomeCash)}    Transfer: ${currency.format(isArca ? report.finalIncomeTransferArca : report.finalIncomeTransfer)}',
                                        color: Colors.teal,
                                        icon: Symbols.payments,
                                        // tooltipMessage:
                                        //     'Cash: ${currency.format(report.finalIncomeCash)}    Transfer: ${currency.format(report.finalIncomeTransfer)}',
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[400]!),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: _buildLineMoneyChart(reports)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // VerticalDivider(color: Colors.grey[300], thickness: 1),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ReportMoneyWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
    });
  }

  /// Halaman Laporan Penjualan
  Widget _buildSalesReport() {
    return Obx(() {
      if (controller.selectedChart.value == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final reports = controller.chartList;
      final report = controller.selectedChart.value;

      final isArca = controller.authService.store.value!.id ==
          '4ac964d8-d504-4dec-b32a-c0d4e918918d';

      return report == null
          ? Center(child: Text('Tidak ada data'))
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Get.theme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        report.dateDisplay.isNotEmpty
                            ? report.dateDisplay
                            : dateWihtoutTime.format(report.date).toString(),
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              // Added Expanded widget
                              child: Column(
                                // padding: EdgeInsets.all(8),
                                // shrinkWrap: true,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SummaryCard(
                                        title: "Penjualan Bersih",
                                        subtitle:
                                            'Total: ${currency.format(report.finalBill)}',
                                        color: Colors.green,
                                        icon: Symbols.sell,
                                      ),
                                      // SummaryCard(
                                      //   title: "Laba Bersih",
                                      //   value: report.finalOutcome,
                                      //   color: Colors.red,
                                      //   icon: Symbols.account_balance_wallet,
                                      //   tooltipMessage:
                                      //       'Cash: ${currency.format(report.outcomeCash)}    Transfer: ${currency.format(report.outcomeTransfer)}',
                                      // ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SummaryCard(
                                        title: "Laba Bersih",
                                        subtitle:
                                            'Total: ${currency.format(report.cleanProfit)}',
                                        color: Colors.teal,
                                        icon: Symbols.payments,
                                      ),
                                    ],
                                  ),
                                  // const SizedBox(height: 16),
                                  Expanded(
                                    child: Container(
                                        margin: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey[400]!),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: _buildLineSellChart(reports)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // VerticalDivider(color: Colors.grey[300], thickness: 1),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ReportSellingWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 16),
                // _buildBarChart(report),
              ],
            );
    });
  }

  /// Widget Grafik Batang
  // Widget _buildBarChart(Chart report) {
  //   return SizedBox(
  //     height: 250,
  //     child: BarChart(
  //       BarChartData(
  //         alignment: BarChartAlignment.spaceAround,
  //         barGroups: [
  //           BarChartGroupData(x: 0, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 1, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 2, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 3, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 4, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 5, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //           BarChartGroupData(x: 6, barRods: [
  //             BarChartRodData(toY: report.totalSellPrice, color: Colors.blue),
  //             BarChartRodData(toY: report.totalCostPrice, color: Colors.red),
  //             BarChartRodData(toY: report.grossProfit, color: Colors.green),
  //             BarChartRodData(toY: report.cleanProfit, color: Colors.orange),
  //           ]),
  //         ],
  //         titlesData: FlTitlesData(
  //           bottomTitles: AxisTitles(
  //             sideTitles: SideTitles(
  //               showTitles: true,
  //               getTitlesWidget: (value, meta) {
  //                 String text;
  //                 switch (value.toInt()) {
  //                   case 0:
  //                     text = 'Sen';
  //                     break;
  //                   case 1:
  //                     text = 'Sel';
  //                     break;
  //                   case 2:
  //                     text = 'Rab';
  //                     break;
  //                   case 3:
  //                     text = 'Kam';
  //                     break;
  //                   case 4:
  //                     text = 'Jum';
  //                     break;
  //                   case 5:
  //                     text = 'Sab';
  //                     break;
  //                   case 6:
  //                     text = 'Min';
  //                     break;
  //                   default:
  //                     text = '';
  //                     break;
  //                 }
  //                 return SideTitleWidget(
  //                   axisSide: meta.axisSide,
  //                   space: 4,
  //                   child: Text(text),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildLineMoneyChart(List<Chart> reports) {
    return Column(
      children: [
        SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: reports
                        .map((report) => FlSpot(
                              reports.indexOf(report).toDouble(),
                              report.finalIncome,
                            ))
                        .toList(),
                    isCurved: false,
                    color: Colors.green,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: reports
                        .map((report) => FlSpot(
                              reports.indexOf(report).toDouble(),
                              report.finalOutcome,
                            ))
                        .toList(),
                    isCurved: false,
                    color: Colors.red,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: reports
                        .map((report) => FlSpot(
                              reports.indexOf(report).toDouble(),
                              report.resultIncomeOutcome,
                            ))
                        .toList(),
                    isCurved: false,
                    color: Colors.teal,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: leftTitleWidgets,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      String date = dateWihtoutTime
                          .format(reports[touchedSpots.first.x.toInt()].date);
                      touchedSpots.sort((a, b) => a.bar.color
                          .toString()
                          .compareTo(b.bar.color.toString()));

                      return touchedSpots.map((barSpot) {
                        final flSpot = barSpot;

                        return LineTooltipItem(
                          'Rp${currency.format(flSpot.y)}',
                          TextStyle(
                            color: flSpot.bar.color,
                            fontWeight: FontWeight.bold,
                          ),
                          children: flSpot == touchedSpots.last
                              ? [
                                  TextSpan(
                                    text: '\n\n$date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ]
                              : [],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Total Pemasukan'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Total Pengeluaran'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Total yang diterima'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildLineSellChart(List<Chart> reports) {
    return Column(
      children: [
        SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: reports
                        .map((report) => FlSpot(
                              reports.indexOf(report).toDouble(),
                              report.finalBill,
                            ))
                        .toList(),
                    isCurved: false,
                    color: Colors.green,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                  LineChartBarData(
                    spots: reports
                        .map((report) => FlSpot(
                              reports.indexOf(report).toDouble(),
                              report.cleanProfit,
                            ))
                        .toList(),
                    isCurved: false,
                    color: Colors.teal,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: leftTitleWidgets,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: bottomTitleWidgets,
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      String date = dateWihtoutTime
                          .format(reports[touchedSpots.first.x.toInt()].date);
                      touchedSpots.sort((a, b) => a.bar.color
                          .toString()
                          .compareTo(b.bar.color.toString()));

                      return touchedSpots.map((barSpot) {
                        final flSpot = barSpot;

                        return LineTooltipItem(
                          'Rp${currency.format(flSpot.y)}',
                          TextStyle(
                            color: flSpot.bar.color,
                            fontWeight: FontWeight.bold,
                          ),
                          children: flSpot == touchedSpots.last
                              ? [
                                  TextSpan(
                                    text: '\n\n$date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Colors.white),
                                  ),
                                ]
                              : [],
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Penjualan Bersih'),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('Laba Bersih'),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String formattedValue;
    if (value >= 1100000) {
      formattedValue = '${(value / 1000000).toStringAsFixed(1)}jt';
    } else if (value >= 1000000) {
      formattedValue = '${(value / 1000000).toStringAsFixed(0)}jt';
    } else if (value >= 1000) {
      formattedValue = '${(value / 1000).toStringAsFixed(0)}rb';
    } else if (value <= -1000) {
      formattedValue = '${(value / 1000).toStringAsFixed(0)}rb';
    } else if (value >= -1000000) {
      formattedValue = '${(value / 1000000).toStringAsFixed(0)}rb';
    } else {
      formattedValue = value.toStringAsFixed(0);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(formattedValue),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    DateTime tanggal;
    switch (value.toInt()) {
      case 0:
        tanggal = controller.selectedDate.value;
        break;
      case 1:
        tanggal = controller.selectedDate.value.add(const Duration(days: 1));
        break;
      case 2:
        tanggal = controller.selectedDate.value.add(const Duration(days: 2));
        break;
      case 3:
        tanggal = controller.selectedDate.value.add(const Duration(days: 3));
        break;
      case 4:
        tanggal = controller.selectedDate.value.add(const Duration(days: 4));
        break;
      case 5:
        tanggal = controller.selectedDate.value.add(const Duration(days: 5));
        break;
      case 6:
        tanggal = controller.selectedDate.value.add(const Duration(days: 6));
        break;
      default:
        tanggal = controller.selectedDate.value.add(const Duration(days: 7));
        break;
    }
    if (value % 1 != 0) {
      return Container();
    }

    final selectedSection = controller.selectedSection.value;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: selectedSection == 'monthly'
          ? Text('')
          : Text(shortDate.format(tanggal)),
    );
  }
}

/// Widget Kartu Ringkasan
class SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final String? tooltipMessage;

  const SummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.tooltipMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isHover = false.obs;
    final LayerLink layerLink = LayerLink();
    return Expanded(
      child: CompositedTransformTarget(
        link: layerLink,
        child: MouseRegion(
          onEnter: (_) => isHover.value = true,
          onExit: (_) => isHover.value = false,
          child: Obx(
            () => Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      subtitle,
                      style: TextStyle(color: color),
                    ),
                  ),
                ),
                // Tooltip muncul saat hover
                if (isHover.value &&
                    tooltipMessage != null &&
                    tooltipMessage!.isNotEmpty)
                  Positioned(
                    // top: 0,
                    // left: 0,
                    // right: 0,
                    child: CompositedTransformFollower(
                      link: layerLink,
                      offset: const Offset(0, -10),
                      child: Material(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Icon(Icons.info, color: Colors.white, size: 16),
                              // SizedBox(width: 8),
                              Text(
                                tooltipMessage!,
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
