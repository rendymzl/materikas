import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/utils/display_format.dart';
import 'controllers/graph.controller.dart';

class GraphScreen extends GetView<GraphController> {
  const GraphScreen({super.key});
  @override
  Widget build(BuildContext context) {
    // DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text("Grafik Penjualan Harian"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => controller.handleFilteredDate(context),
              icon: Icon(Symbols.calendar_month))
        ],
        // backgroundColor: Colors.white,
      ),
      // backgroundColor: Colors.white,
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: const CircularProgressIndicator())
            : Column(
                children: [
                  // Tombol untuk memfilter data 7 hari
                  // ElevatedButton(
                  //   onPressed: () {
                  //     controller.filterSalesByDayFor7Days(today);
                  //   },
                  //   child: Text("Tampilkan Data 7 Hari"),
                  // ),
                  Expanded(
                    child: Obx(() {
                      if (controller.chartLists.isEmpty) {
                        return Center(child: Text("Tidak ada data penjualan."));
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Text('Total Invoice'),
                                  SizedBox(height: 12),
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        titlesData: FlTitlesData(
                                          topTitles: AxisTitles(),
                                          rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index <
                                                    controller
                                                        .chartLists.length) {
                                                  return Column(
                                                    children: [
                                                      Text(
                                                        dayName.format(
                                                            controller
                                                                .chartLists[
                                                                    index]
                                                                .date),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        shortDate.format(
                                                            controller
                                                                .chartLists[
                                                                    index]
                                                                .date),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey))),
                                        gridData:
                                            FlGridData(drawVerticalLine: false),
                                        barGroups: controller.chartLists
                                            .asMap()
                                            .entries
                                            .map((entry) => BarChartGroupData(
                                                  x: entry.key,
                                                  barRods: [
                                                    BarChartRodData(
                                                      toY: entry
                                                          .value.totalInvoice
                                                          .toDouble(),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(4)),
                                                      width: 18,
                                                    )
                                                  ],
                                                ))
                                            .toList(),
                                        barTouchData: BarTouchData(
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                              getTooltipColor: (touchedSpot) =>
                                                  Colors.grey[800]!
                                                      .withOpacity(0.8),
                                              getTooltipItem: (group,
                                                  groupIndex, rod, rodIndex) {
                                                final data = controller
                                                    .chartLists[groupIndex];
                                                return BarTooltipItem(
                                                  '${data.totalInvoice}',
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                );
                                              },
                                            ),
                                            touchCallback: (event, response) {
                                              if (response != null &&
                                                  response.spot != null &&
                                                  event is FlTapUpEvent) {
                                                final x = response
                                                    .spot!.touchedBarGroup.x;
                                                final isShowing = controller
                                                        .showingTooltip.value ==
                                                    x;
                                                if (isShowing) {
                                                  controller.showingTooltip(-1);
                                                } else {
                                                  controller.showingTooltip(x);
                                                }
                                              }
                                            },
                                            mouseCursorResolver:
                                                (event, response) {
                                              return response == null ||
                                                      response.spot == null
                                                  ? MouseCursor.defer
                                                  : SystemMouseCursors.click;
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    }),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.chartLists.isEmpty) {
                        return Center(child: Text("Tidak ada data penjualan."));
                      }
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(() => Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Penjualan'),
                                        ],
                                      ),
                                      SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.teal,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text('Laba Bersih'),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Expanded(
                                    child: BarChart(
                                      BarChartData(
                                        titlesData: FlTitlesData(
                                          topTitles: AxisTitles(),
                                          rightTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                  showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              interval: 1,
                                              getTitlesWidget: (value, meta) {
                                                int index = value.toInt();
                                                if (index <
                                                    controller
                                                        .chartLists.length) {
                                                  return Column(
                                                    children: [
                                                      Text(
                                                        dayName.format(
                                                            controller
                                                                .chartLists[
                                                                    index]
                                                                .date),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                      Text(
                                                        shortDate.format(
                                                            controller
                                                                .chartLists[
                                                                    index]
                                                                .date),
                                                        style: TextStyle(
                                                            fontSize: 10),
                                                      ),
                                                    ],
                                                  );
                                                }
                                                return Container();
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.grey))),
                                        gridData:
                                            FlGridData(drawVerticalLine: false),
                                        barGroups: controller.chartLists
                                            .asMap()
                                            .entries
                                            .map((entry) => BarChartGroupData(
                                                  x: entry.key,
                                                  barRods: [
                                                    // BarChartRodData(
                                                    //   toY:
                                                    //       entry.value.sellPrice,
                                                    //   color: Theme.of(context)
                                                    //       .colorScheme
                                                    //       .primary,
                                                    //   borderRadius:
                                                    //       BorderRadius.vertical(
                                                    //           top: Radius
                                                    //               .circular(4)),
                                                    //   width: 18,
                                                    // ),
                                                    BarChartRodData(
                                                      toY: entry
                                                          .value.cleanProfit,
                                                      color: Colors.teal,
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(4)),
                                                      width: 18,
                                                    )
                                                  ],
                                                ))
                                            .toList(),
                                        barTouchData: BarTouchData(
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                              getTooltipColor: (touchedSpot) =>
                                                  Colors.grey[800]!
                                                      .withOpacity(0.8),
                                              getTooltipItem: (group,
                                                  groupIndex, rod, rodIndex) {
                                                return BarTooltipItem(
                                                  'Rp.${currency.format(rod.toY)}',
                                                  const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                );
                                              },
                                            ),
                                            touchCallback: (event, response) {
                                              if (response != null &&
                                                  response.spot != null &&
                                                  event is FlTapUpEvent) {
                                                final x = response
                                                    .spot!.touchedBarGroup.x;
                                                final isShowing = controller
                                                        .showingTooltip.value ==
                                                    x;
                                                if (isShowing) {
                                                  controller.showingTooltip(-1);
                                                } else {
                                                  controller.showingTooltip(x);
                                                }
                                              }
                                            },
                                            mouseCursorResolver:
                                                (event, response) {
                                              return response == null ||
                                                      response.spot == null
                                                  ? MouseCursor.defer
                                                  : SystemMouseCursors.click;
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    }),
                  ),
                ],
              ),
      ),
    );
  }
}
