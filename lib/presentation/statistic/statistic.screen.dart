import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/activate_popup/activate_account_popup.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import '../sales/selected_product_sales_widget/calculate_sales.dart';
import '../operating_cost/add_operating_cost.dart';
import '../global_widget/billing_widget/billing_dashboard.dart';
import 'controllers/statistic.controller.dart';
import 'date_picker_cart.dart';
import 'detail_operating_cost.dart';

class StatisticScreen extends GetView<StatisticController> {
  const StatisticScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MenuWidget(title: 'Laporan'),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 300, child: DatePickerCard()),
                Expanded(
                    child: Column(
                  children: [
                    controller.isLoading.value
                        ? CircularProgressIndicator()
                        : Expanded(
                            child: Row(
                            children: [
                              Expanded(
                                  child: Card(child: ReportSellingWidget())),
                              Expanded(child: Card(child: ReportMoneyWidget())),
                            ],
                          )),
                    Card(
                      child: SectionMenuBar(),
                    ),
                  ],
                )),
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
      padding: const EdgeInsets.all(12),
      // height: 70,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  controller.rangePickerHandle(controller.args.value);
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
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (controller.authService.account.value!.accountType ==
                      'flexible') {
                    Get.defaultDialog(
                      title: 'Upgrade Akun',
                      middleText: 'Upgrade akun untuk menambahkan kasir',
                      confirm: ElevatedButton(
                        onPressed: () async => activateAccountPopup(),
                        child: const Text('Upgrade Paket'),
                      ),
                    );
                  } else {
                    controller.rangePickerHandle(controller.args.value);
                    controller.selectedSection.value = 'weekly';
                  }
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
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (controller.authService.account.value!.accountType ==
                      'flexible') {
                    Get.defaultDialog(
                      title: 'Upgrade Akun',
                      middleText: 'Upgrade akun untuk menambahkan kasir',
                      confirm: ElevatedButton(
                        onPressed: () async => activateAccountPopup(),
                        child: const Text('Upgrade Paket'),
                      ),
                    );
                  } else {
                    controller.monthPickerHandle(controller.args.value);
                    controller.selectedSection.value = 'monthly';
                  }
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
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (controller.authService.account.value!.accountType ==
                      'flexible') {
                    Get.defaultDialog(
                      title: 'Upgrade Akun',
                      middleText: 'Upgrade akun untuk menambahkan kasir',
                      confirm: ElevatedButton(
                        onPressed: () async => activateAccountPopup(),
                        child: const Text('Upgrade Paket'),
                      ),
                    );
                  } else {
                    controller.yearPickerHandle(controller.args.value);
                    controller.selectedSection.value = 'yearly';
                  }
                },
                style: ButtonStyle(
                  enableFeedback: true,
                  backgroundColor: WidgetStatePropertyAll(
                    controller.selectedSection.value == 'yearly'
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white,
                  ),
                ),
                child: Text(
                  'Tahunan',
                  style: TextStyle(
                    fontSize: 16,
                    color: controller.selectedSection.value == 'yearly'
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                ),
              ),
            ),
            // Divider(color: Colors.grey[200]),
            if (controller.authService.account.value!.accountType == 'flexible')
              const SizedBox(width: 16),
            if (controller.authService.account.value!.accountType == 'flexible')
              ElevatedButton(
                onPressed: () => billingDashboard(),
                style: ButtonStyle(
                  enableFeedback: true,
                  backgroundColor: WidgetStatePropertyAll(
                    // Colors.white,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Obx(
                  () {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Tagihan ${getMonthName(controller.billingService.selectedMonth.value.month)}',
                          style: context.textTheme.titleLarge!
                              .copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: FutureBuilder<double>(
                            future: controller.billingService.getBillAmount(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  'Rp${currency.format(snapshot.data)}',
                                  style: context.textTheme.titleLarge!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                );
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ReportSellingWidget extends StatelessWidget {
  const ReportSellingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () {
          final data = controller.selectedChart.value!;

          return Column(
            children: [
              Text(
                'LAPORAN TRANSAKSI PENJUALAN',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              Divider(color: Colors.grey[400], thickness: 2),
              controller.isLoading.value
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(data.dateString),
                              const SizedBox(width: 12),
                              Text('Total Invoice: ${data.totalInvoice}'),
                            ],
                          ),
                          PropertiesRowWidget(
                            title: 'Total Penjualan',
                            value: currency.format(data.totalSellPrice),
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: 'Total Diskon',
                            value: '-${currency.format(data.totalDiscount)}',
                            color: Colors.red,
                          ),
                          if (data.totalOtherCost > 0)
                            PropertiesRowWidget(
                              title: 'Total Biaya Lainnya',
                              value: currency.format(data.totalOtherCost),
                              color: Colors.green,
                            ),
                          if (data.totalReturn > 0)
                            const PropertiesRowWidget(
                              title: 'Return',
                              value: 'title',
                              primary: true,
                            ),
                          if (data.totalReturn > 0)
                            PropertiesRowWidget(
                              title: '      - Pesanan Direturn',
                              value: 'title',
                              subValue: currency.format(data.totalReturn * -1),
                              italic: true,
                              color: Colors.red,
                            ),
                          if (data.totalReturn > 0)
                            PropertiesRowWidget(
                              title: '      - Total Cas Return',
                              value: 'title',
                              subValue: currency.format(data.totalChargeReturn),
                              italic: true,
                              color: Colors.green,
                            ),
                          if (data.totalReturn > 0)
                            PropertiesRowWidget(
                              title: 'Total Return',
                              value: currency.format((data.finalReturn) * -1),
                              color: Colors.red,
                            ),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'Penjualan Bersih',
                            value: currency.format(data.sellPrice),
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: 'Modal Pokok',
                            value: currency.format(data.totalCostPrice * -1),
                            color: Colors.red,
                          ),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'Laba Kotor',
                            value: currency.format(data.grossProfit),
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: 'Biaya Operasional',
                            value: currency.format(data.operatingCost * -1),
                            color: Colors.red,
                          ),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'Laba Bersih',
                            value: currency.format(data.cleanProfit),
                            primary: true,
                          ),
                        ],
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class ReportMoneyWidget extends StatelessWidget {
  const ReportMoneyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () {
          final data = controller.selectedChart.value!;

          return Column(
            children: [
              Text(
                'LAPORAN KEUANGAN',
                textAlign: TextAlign.center,
                style: context.textTheme.bodyLarge,
              ),
              Divider(color: Colors.grey[400], thickness: 2),
              controller.isLoading.value
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(data.dateString)],
                          ),
                          // PropertiesRowWidget(
                          //   title: 'SubTotal Penjualan',
                          //   value: currency.format(data.totalSellPrice),
                          //   subValue: '',
                          //   primary: true,
                          // ),
                          // PropertiesRowWidget(
                          //   title: 'Total Diskon',
                          //   value: currency.format(data.totalDiscount * -1),
                          //   subValue: '',
                          //   color: Colors.red,
                          // ),
                          // PropertiesRowWidget(
                          //   title: 'Total Biaya Lainnya',
                          //   value: currency.format(data.totalOtherCost),
                          //   subValue: '',
                          //   color: Colors.green,
                          // ),
                          // PropertiesRowWidget(
                          //   title: 'Total Return',
                          //   value: currency.format(data.totalReturn * -1),
                          //   subValue: '',
                          //   color: Colors.red,
                          // ),
                          // PropertiesRowWidget(
                          //   title: 'Total Cas Return',
                          //   value: currency.format(data.totalChargeReturn),
                          //   subValue: '',
                          //   color: Colors.green,
                          // ),
                          PropertiesRowWidget(
                            title: 'Penjualan Bersih',
                            value: currency.format(data.sellPrice),
                            primary: true,
                          ),

                          const PropertiesRowWidget(
                            title: 'Pembayaran Pembelian',
                            value: 'title',
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: '      - Cash',
                            value: 'title',
                            italic: true,
                            subValue: currency.format(data.cash),
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: '      - Transfer',
                            value: 'title',
                            italic: true,
                            subValue: currency.format(data.transfer),
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: 'Total Bayar Pembelian',
                            value: currency.format(data.totalPay),
                            primary: true,
                            color: Colors.green,
                          ),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'Belum Bayar',
                            value: currency.format(data.totalDebt),
                            // subValue: data.totalDiscount > 0
                            //     ? 'Rp${currency.format(data.totalDebt)} - diskon Rp${currency.format(data.totalDiscount)}'
                            //     : '',
                            primary: true,
                            color: Colors.red,
                          ),
                          Divider(color: Colors.grey[400]),
                          const SizedBox(height: 60),
                          // Divider(color: Colors.grey[400]),
                          const PropertiesRowWidget(
                            title: 'Pembayaran Piutang',
                            value: 'title',
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: '      - Cash',
                            value: 'title',
                            subValue: currency.format(data.debtCash),
                            italic: true,
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: '      - Transfer',
                            value: 'title',
                            subValue: currency.format(data.debtTransfer),
                            italic: true,
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: 'Total Bayar Piutang',
                            value: currency.format(data.totalDebtPay),
                            primary: true,
                            color: Colors.green,
                          ),
                          // const SizedBox(height: 30),
                          Divider(color: Colors.grey[400]),
                          const PropertiesRowWidget(
                            title: 'Pembayaran Sales',
                            value: 'title',
                            primary: true,
                          ),
                          PropertiesRowWidget(
                            title: '      - Bayar Sales Cash',
                            value: 'title',
                            subValue: currency.format(data.salesCash * -1),
                            italic: true,
                            color: Colors.red,
                          ),
                          PropertiesRowWidget(
                            title: '      - Bayar Sales Transfer',
                            value: 'title',
                            subValue: currency.format(data.salesTransfer * -1),
                            italic: true,
                            color: Colors.red,
                          ),
                          PropertiesRowWidget(
                            title: 'Total Bayar Sales',
                            value: currency.format(data.totalSalesPay * -1),
                            color: Colors.red,
                            primary: true,
                          ),
                          const SizedBox(height: 60),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'Total Bayar Pembelian',
                            value: currency.format(data.totalPay),
                            primary: true,
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: 'Total Bayar Piutang',
                            value: currency.format(data.totalDebtPay),
                            primary: true,
                            color: Colors.green,
                          ),
                          PropertiesRowWidget(
                            title: controller.authService.account.value!.name ==
                                    'Arca Nusantara'
                                ? 'Total Bayar Sales Cash'
                                : 'Total Bayar Sales',
                            value: currency.format(
                                (controller.authService.account.value!.name ==
                                            'Arca Nusantara'
                                        ? data.salesCash
                                        : data.totalSalesPay) *
                                    -1),
                            color: Colors.red,
                            primary: true,
                          ),
                          if (data.operatingCost > 0)
                            PropertiesRowWidget(
                              title: 'Biaya Operasional',
                              value: currency.format(data.operatingCost * -1),
                              primary: true,
                              color: Colors.red,
                            ),
                          Divider(color: Colors.grey[400]),
                          PropertiesRowWidget(
                            title: 'TOTAL UANG YANG DITERIMA',
                            primary: true,
                            value: currency.format(
                              controller.authService.account.value!.name ==
                                      'Arca Nusantara'
                                  ? data.totalReceiveMoneyArca
                                  : data.totalReceiveMoney,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}
