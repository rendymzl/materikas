import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../infrastructure/navigation/routes.dart';
import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import '../global_widget/properties_row_widget.dart';
import 'report_page.dart';
import 'controllers/statistic.controller.dart';
import 'date_picker_cart.dart';
import 'report_money_widget.dart';
import 'report_selling_widget.dart';
import 'sales_payment_detail_mobile.dart';

class StatisticScreen extends GetView<StatisticController> {
  const StatisticScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      backgroundColor: isMobile ? Colors.white : null,
      appBar: isMobile
          ? AppBar(
              title: const Text("Laporan"),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: isMobile
                  ? [
                      IconButton(
                          icon: const Icon(Symbols.monitoring),
                          onPressed: () {
                            Get.toNamed(Routes.GRAPH);
                          }),
                    ]
                  : null,
            )
          : null,
      drawer: isMobile ? buildDrawer(context) : null,
      body: Column(
        children: [
          if (!isMobile) MenuWidget(title: 'Laporan'),
          Expanded(
            child: isMobile
                ? buildMobileLayout(context)
                : buildDesktopLayout(context),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk tampilan desktop
  Widget buildDesktopLayout(BuildContext context) {
    // controller.isMobile.value = false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // color: Colors.amber,
            width: 320,
            child: Column(
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DatePickerCard(),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: SectionMenuBar(),
                ),
              ],
            ),
          ),
          Expanded(child: ReportPage()
              //     Column(
              //   children: [
              //     Expanded(
              //         child: Row(
              //       children: [
              //         Expanded(
              //             child: Column(
              //           children: [
              //             Expanded(
              //                 flex: 5,
              //                 child: Card(
              //                     elevation: 0, child: ReportSellingWidget())),
              //             Expanded(
              //                 flex: 3,
              //                 child: Card(
              //                     elevation: 0, child: ReportPurchaseWidget())),
              //           ],
              //         )),
              //         Expanded(
              //             child: Card(elevation: 0, child: ReportMoneyWidget())),
              //       ],
              //     )),
              //     // Card(
              //     //   elevation: 0,
              //     //   child: SectionMenuBar(),
              //     // ),
              //   ],
              // ),
              ),
          // Obx(
          //   () {
          //     if (controller.selectedSection.value == 'daily') {
          //       return Expanded(
          //         flex: 4,
          //         child: Card(
          //           child: Padding(
          //             padding: const EdgeInsets.all(8.0),
          //             child: Column(
          //               children: [
          //                 Padding(
          //                   padding: const EdgeInsets.all(8.0),
          //                   child: Row(
          //                     mainAxisAlignment:
          //                         MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       const Text(
          //                         'Biaya Operasional',
          //                         style: TextStyle(),
          //                       ),
          //                       if (controller.accessOperational.value)
          //                         IconButton(
          //                           onPressed: () =>
          //                               detailOperatingCost(),
          //                           icon: Icon(Symbols.open_in_new,
          //                               color: Theme.of(context)
          //                                   .colorScheme
          //                                   .primary),
          //                         )
          //                     ],
          //                   ),
          //                 ),
          //                 Divider(color: Colors.grey[200]),
          //                 Expanded(
          //                   child: Obx(
          //                     () {
          //                       print(controller
          //                           .dailyOperatingCosts.length);
          //                       return ListView.builder(
          //                         itemCount: controller
          //                             .dailyOperatingCosts.length,
          //                         shrinkWrap: true,
          //                         itemBuilder: (context, index) {
          //                           var operatingCost = controller
          //                               .dailyOperatingCosts[index];
          //                           return ListTile(
          //                             title: Row(
          //                               mainAxisAlignment:
          //                                   MainAxisAlignment
          //                                       .spaceBetween,
          //                               children: [
          //                                 Text(operatingCost.name!),
          //                                 Text(
          //                                     'Rp${currency.format(operatingCost.amount!)}')
          //                               ],
          //                             ),
          //                             subtitle: Text(
          //                               operatingCost.note!,
          //                               style: TextStyle(
          //                                 color: Colors.grey[400],
          //                                 fontStyle: FontStyle.italic,
          //                               ),
          //                             ),
          //                             leading: controller
          //                                     .accessOperational.value
          //                                 ? IconButton(
          //                                     onPressed: () async =>
          //                                         await Get.defaultDialog(
          //                                       title: 'Hapus',
          //                                       middleText:
          //                                           'Hapus Biaya?',
          //                                       confirm: TextButton(
          //                                         onPressed: () async {
          //                                           controller
          //                                               .deleteOperatingCost(
          //                                                   operatingCost);
          //                                           Get.back();
          //                                         },
          //                                         child:
          //                                             const Text('Hapus'),
          //                                       ),
          //                                       cancel: TextButton(
          //                                         onPressed: () {
          //                                           Get.back();
          //                                         },
          //                                         child: Text(
          //                                           'Batal',
          //                                           style: TextStyle(
          //                                               color: Colors
          //                                                   .black
          //                                                   .withOpacity(
          //                                                       0.5)),
          //                                         ),
          //                                       ),
          //                                     ),
          //                                     icon: const Icon(
          //                                       Symbols.close,
          //                                       color: Colors.red,
          //                                     ),
          //                                   )
          //                                 : null,
          //                           );
          //                         },
          //                       );
          //                     },
          //                   ),
          //                 ),
          //                 if (controller.accessOperational.value)
          //                   ElevatedButton(
          //                     onPressed: () => addOperatingCostDialog(),
          //                     child: const Text(
          //                       'Tambah Biaya Operasional',
          //                     ),
          //                   ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     } else {
          //       return Container();
          //     }
          //   },
          // ),
        ],
      ),
    );
  }

  // Fungsi untuk tampilan mobile
// Fungsi untuk tampilan mobile
  Widget buildMobileLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Symbols.arrow_left),
                  onPressed: () {
                    controller.dailyPickerHandle(controller.selectedDate.value
                        .subtract(Duration(days: 1)));
                    // controller.selectedDate.value = controller
                    //     .selectedDate.value
                    //     .subtract(Duration(days: 1));
                  },
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: 300,
                                height: 480,
                                child: SfDateRangePicker(
                                  navigationDirection:
                                      DateRangePickerNavigationDirection
                                          .vertical,
                                  navigationMode:
                                      DateRangePickerNavigationMode.scroll,
                                  headerStyle: DateRangePickerHeaderStyle(
                                      backgroundColor: Colors.white,
                                      textStyle: context.textTheme.bodyLarge),
                                  backgroundColor: Colors.white,
                                  enableMultiView: true,
                                  initialSelectedDate:
                                      controller.selectedDate.value,
                                  monthViewSettings:
                                      const DateRangePickerMonthViewSettings(
                                    firstDayOfWeek: 1,
                                  ),
                                  selectionMode:
                                      DateRangePickerSelectionMode.single,
                                  minDate: DateTime(2000),
                                  maxDate: DateTime.now(),
                                  showActionButtons: true,
                                  cancelText: 'Batal',
                                  onCancel: () => Get.back(),
                                  onSubmit: (p0) async {
                                    controller
                                        .dailyPickerHandle(p0 as DateTime);
                                    Get.back();
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.all(12),
                    child: Text(
                      DateFormat('dd MMMM y', 'id')
                          .format(controller.selectedDate.value),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.arrow_right),
                  onPressed: () {
                    final nextDate =
                        controller.selectedDate.value.add(Duration(days: 1));
                    if (!nextDate.isAfter(DateTime.now())) {
                      controller.dailyPickerHandle(nextDate);
                    }
                  },
                ),
              ],
            ),
          ),
          // Bagian untuk memilih tanggal
          // const Padding(
          //   padding: EdgeInsets.all(8.0),
          //   child: DatePickerDaily(
          //     isPopUp: true,
          //   ),
          // ),
          // Header tabel untuk nama biaya operasional dan jumlahnya
          // const TableHeader(),
          Divider(color: Colors.grey[200]),
          Obx(
            () {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectedPaymentMethod.value =
                          controller.displaySection[0],
                      child: Card(
                        color: controller.selectedPaymentMethod.value ==
                                controller.displaySection[0]
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long,
                                  color:
                                      controller.selectedPaymentMethod.value ==
                                              controller.displaySection[0]
                                          ? Colors.white
                                          : Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text('PENJUALAN',
                                  style: TextStyle(
                                      color: controller.selectedPaymentMethod
                                                  .value ==
                                              controller.displaySection[0]
                                          ? Colors.white
                                          : Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => controller.selectedPaymentMethod.value =
                          controller.displaySection[1],
                      child: Card(
                        color: controller.selectedPaymentMethod.value ==
                                controller.displaySection[1]
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payments,
                                  color:
                                      controller.selectedPaymentMethod.value ==
                                              controller.displaySection[1]
                                          ? Colors.white
                                          : Colors.grey[700]),
                              const SizedBox(width: 8),
                              Text('KEUANGAN',
                                  style: TextStyle(
                                      color: controller.selectedPaymentMethod
                                                  .value ==
                                              controller.displaySection[1]
                                          ? Colors.white
                                          : Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Daftar biaya operasional
          Obx(
            () {
              return Expanded(
                  child: controller.selectedPaymentMethod.value == 'transaction'
                      ? ReportSellingWidget()
                      : ReportMoneyWidget(isMobile: true));
            },
          ),
        ],
      ),
    );
  }
}

class SectionMenuBar extends StatelessWidget {
  const SectionMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Container(
      padding: const EdgeInsets.all(8),
      // height: 70,
      child: Obx(
        () => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.dailyPickerHandle(DateTime.now());
                      controller.selectedSection.value = 'daily';
                    },
                    style: ButtonStyle(
                      enableFeedback: true,
                      backgroundColor: WidgetStatePropertyAll(
                        controller.selectedSection.value == 'daily'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                    child: Text(
                      'Harian',
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.selectedSection.value == 'daily'
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // if (controller.authService.account.value!.accountType ==
                      //     'flexible') {
                      //   Get.defaultDialog(
                      //     title: 'Upgrade Akun',
                      //     middleText: 'Upgrade akun untuk menambahkan kasir',
                      //     confirm: ElevatedButton(
                      //       onPressed: () async => activateAccountPopup(),
                      //       child: const Text('Upgrade Paket'),
                      //     ),
                      //   );
                      // } else {
                      controller.weeklyPickerHandle(DateTime.now());
                      controller.selectedSection.value = 'weekly';
                      // }
                    },
                    style: ButtonStyle(
                      enableFeedback: true,
                      backgroundColor: WidgetStatePropertyAll(
                        controller.selectedSection.value == 'weekly'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                    child: Text(
                      'Mingguan',
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.selectedSection.value == 'weekly'
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // if (controller.authService.account.value!.accountType ==
                      //     'flexible') {
                      //   Get.defaultDialog(
                      //     title: 'Upgrade Akun',
                      //     middleText: 'Upgrade akun untuk menambahkan kasir',
                      //     confirm: ElevatedButton(
                      //       onPressed: () async => activateAccountPopup(),
                      //       child: const Text('Upgrade Paket'),
                      //     ),
                      //   );
                      // } else {
                      controller.monthlyPickerHandle(DateTime.now());
                      controller.selectedSection.value = 'monthly';
                      // }
                    },
                    style: ButtonStyle(
                      enableFeedback: true,
                      backgroundColor: WidgetStatePropertyAll(
                        controller.selectedSection.value == 'monthly'
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                      ),
                    ),
                    child: Text(
                      'Bulanan',
                      style: TextStyle(
                        fontSize: 16,
                        color: controller.selectedSection.value == 'monthly'
                            ? Colors.white
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {
            //     // if (controller.authService.account.value!.accountType ==
            //     //     'flexible') {
            //     //   Get.defaultDialog(
            //     //     title: 'Upgrade Akun',
            //     //     middleText: 'Upgrade akun untuk menambahkan kasir',
            //     //     confirm: ElevatedButton(
            //     //       onPressed: () async => activateAccountPopup(),
            //     //       child: const Text('Upgrade Paket'),
            //     //     ),
            //     //   );
            //     // } else {
            //     controller.yearlyPickerHandle(DateTime.now());
            //     controller.selectedSection.value = 'yearly';
            //     // }
            //   },
            //   style: ButtonStyle(
            //     enableFeedback: true,
            //     backgroundColor: WidgetStatePropertyAll(
            //       controller.selectedSection.value == 'yearly'
            //           ? Theme.of(context).colorScheme.primary
            //           : Colors.white,
            //     ),
            //   ),
            //   child: Text(
            //     'Tahunan',
            //     style: TextStyle(
            //       fontSize: 16,
            //       color: controller.selectedSection.value == 'yearly'
            //           ? Colors.white
            //           : Colors.grey[700],
            //     ),
            //   ),
            // ),
            // Divider(color: Colors.grey[200]),
            // if (controller.authService.account.value!.accountType == 'flexible')
            //   const SizedBox(width: 16),
            // if (controller.authService.account.value!.accountType == 'flexible')
            //   ElevatedButton(
            //     onPressed: () => billingDashboard(),
            //     style: ButtonStyle(
            //       enableFeedback: true,
            //       backgroundColor: WidgetStatePropertyAll(
            //         // Colors.white,
            //         Theme.of(context).colorScheme.primary,
            //       ),
            //     ),
            //     child: Obx(
            //       () {
            //         return Column(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text(
            //               'Tagihan ${getMonthName(controller.billingService.selectedMonth.value.month)}',
            //               style: context.textTheme.titleLarge!
            //                   .copyWith(color: Colors.white),
            //             ),
            //             const SizedBox(height: 8),
            //             Container(
            //               padding: const EdgeInsets.symmetric(
            //                   vertical: 4, horizontal: 8),
            //               decoration: BoxDecoration(
            //                 color: Colors.white,
            //                 borderRadius: BorderRadius.circular(4),
            //                 boxShadow: [
            //                   BoxShadow(
            //                     color: Colors.black.withOpacity(0.2),
            //                     spreadRadius: 2,
            //                     blurRadius: 5,
            //                     offset: const Offset(0, 3),
            //                   ),
            //                 ],
            //               ),
            //               child: FutureBuilder<double>(
            //                 future: controller.billingService.getBillAmount(),
            //                 builder: (context, snapshot) {
            //                   if (snapshot.hasData) {
            //                     return Text(
            //                       'Rp${currency.format(snapshot.data)}',
            //                       style: context.textTheme.titleLarge!.copyWith(
            //                           color: Theme.of(context)
            //                               .colorScheme
            //                               .primary),
            //                     );
            //                   } else if (snapshot.hasError) {
            //                     return Text('Error: ${snapshot.error}');
            //                   } else {
            //                     return const CircularProgressIndicator();
            //                   }
            //                 },
            //               ),
            //             ),
            //           ],
            //         );
            //       },
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

// class ReportPurchaseWidget extends StatelessWidget {
//   const ReportPurchaseWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     StatisticController controller = Get.find();
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Obx(
//         () {
//           final data = controller.selectedChart.value;

//           return Column(
//             children: [
//               Text(
//                 'LAPORAN TRANSAKSI PEMBELIAN BARANG',
//                 textAlign: TextAlign.center,
//                 style: context.textTheme.bodyLarge,
//               ),
//               Divider(color: Colors.grey[400], thickness: 2),
//               controller.isLoading.value
//                   ? Expanded(
//                       child: Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     )
//                   : data == null
//                       ? Text('Tidak ada data')
//                       : Expanded(
//                           child: ListView(
//                             shrinkWrap: true,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Text(data.dateString),
//                                   const SizedBox(width: 12),
//                                   Text(
//                                       'Total Invoice Sales: ${data.totalInvoiceSales}'),
//                                 ],
//                               ),
//                               PropertiesRowWidget(
//                                 title: 'Total Pembelian',
//                                 value:
//                                     currency.format(data.totalSellPriceSales),
//                                 primary: true,
//                               ),
//                               PropertiesRowWidget(
//                                 title: 'Total Diskon',
//                                 value:
//                                     '-${currency.format(data.totalDiscountSales)}',
//                                 color: Colors.red,
//                               ),

//                               Divider(color: Colors.grey[400]),
//                               PropertiesRowWidget(
//                                 title: 'Pembelian Bersih',
//                                 value: currency.format(data.sellPriceSales),
//                                 primary: true,
//                               ),
//                               // PropertiesRowWidget(
//                               //   title: 'Modal Pokok',
//                               //   value:
//                               //       currency.format(data.totalCostPrice * -1),
//                               //   color: Colors.red,
//                               // ),
//                               // Divider(color: Colors.grey[400]),
//                               // PropertiesRowWidget(
//                               //   title: 'Laba Kotor',
//                               //   value: currency.format(data.grossProfit),
//                               //   primary: true,
//                               // ),
//                               // PropertiesRowWidget(
//                               //   title: 'Biaya Operasional',
//                               //   value: currency.format(data.operatingCost * -1),
//                               //   color: Colors.red,
//                               // ),
//                               // Divider(color: Colors.grey[400]),
//                               // PropertiesRowWidget(
//                               //   title: 'Laba Bersih',
//                               //   value: currency.format(data.cleanProfit),
//                               //   primary: true,
//                               // ),
//                             ],
//                           ),
//                         ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
