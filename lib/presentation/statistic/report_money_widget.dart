import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/properties_row_widget.dart';
import 'controllers/statistic.controller.dart';
import 'payment_detail.dart';
import 'sales_payment_detail.dart';
import 'sales_payment_detail_mobile.dart';

class ReportMoneyWidget extends StatelessWidget {
  const ReportMoneyWidget({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    StatisticController controller = Get.find();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () {
          final data = controller.selectedChart.value;

          return Column(
            children: [
              Text(
                'DETAIL LAPORAN KEUANGAN',
                textAlign: TextAlign.center,
                style: context.textTheme.titleLarge!
                    .copyWith(color: Get.theme.primaryColor),
              ),
              Divider(color: Colors.grey[400], thickness: 2),
              controller.isLoading.value
                  ? Expanded(child: Center(child: CircularProgressIndicator()))
                  : data == null
                      ? Center(child: Text('Tidak ada data'))
                      : Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pemasukan dari penjualan',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              PropertiesRowWidget(
                                title: 'Cash',
                                value: 'title',
                                subValue: '+${currency.format(data.totalCash)}',
                                color: Colors.green,
                              ),
                              PropertiesRowWidget(
                                title: 'Transfer',
                                value: 'title',
                                subValue:
                                    '+${currency.format(data.totalTransfer)}',
                                color: Colors.blue,
                              ),
                              Divider(color: Colors.grey[400]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pemasukan dari pembayaran hutang',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              PropertiesRowWidget(
                                title: 'Cash',
                                value: 'title',
                                subValue:
                                    '+${currency.format(data.totalDebtCash)}',
                                color: Colors.green,
                              ),
                              PropertiesRowWidget(
                                title: 'Transfer',
                                value: 'title',
                                subValue:
                                    '+${currency.format(data.totalDebtTransfer)}',
                                color: Colors.blue,
                              ),
                              Divider(color: Colors.grey[400]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pengeluaran return barang',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              PropertiesRowWidget(
                                title: 'Cash',
                                value: 'title',
                                subValue:
                                    currency.format(data.finalReturn * -1),
                                color: Colors.red,
                              ),
                              Divider(color: Colors.grey[400]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pengeluaran beli barang',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              PropertiesRowWidget(
                                title: 'Cash',
                                value: 'title',
                                subValue:
                                    currency.format(data.totalSalesCash * -1),
                                color: Colors.red,
                              ),
                              PropertiesRowWidget(
                                title: 'Transfer',
                                value: 'title',
                                subValue: currency
                                    .format(data.totalSalesTransfer * -1),
                                color: Colors.red,
                              ),
                              // if (controller.selectedSection.value == 'daily')
                              //   Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       InkWell(
                              //         onTap: () async =>
                              //             detailSalesPaymentMobile(controller
                              //                 .invoicesSalesByPaymentDate)

                              //         // detailSalesPayment(controller
                              //         //     .invoicesSalesByPaymentDate)
                              //         ,
                              //         child: Container(
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 4, horizontal: 8),
                              //             decoration: BoxDecoration(
                              //               color: Theme.of(context)
                              //                   .colorScheme
                              //                   .primary,
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //             child: Text(
                              //               'Lihat Detail',
                              //               style:
                              //                   TextStyle(color: Colors.white),
                              //             )),
                              //       ),
                              //     ],
                              //   ),
                              if (!controller.isFetching.value)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () async =>
                                          detailSalesPaymentMobile(RxList(
                                              await controller
                                                  .getPaymentSalesByDate(
                                                      data.date))),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Lihat Detail',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )),
                                    ),
                                  ],
                                ),
                              Divider(color: Colors.grey[400]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pengeluaran operasional',
                                    style: Get.textTheme.titleLarge,
                                  )
                                ],
                              ),
                              PropertiesRowWidget(
                                title: 'Cash',
                                value: 'title',
                                subValue: currency
                                    .format(data.operatingCostCash * -1),
                                color: Colors.red,
                              ),
                              // PropertiesRowWidget(
                              //   title: 'Transfer',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.operatingCostTransfer),
                              //   color: Colors.red,
                              // ),
                              // Divider(color: Colors.grey[400]),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Text(
                              //       'Total yang diterima',
                              //       style: Get.textTheme.titleLarge,
                              //     )
                              //   ],
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Cash',
                              //   value: 'title',
                              //   subValue:
                              //       currency.format(data.finalIncomeCash),
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Transfer',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.finalIncomeTransfer),
                              //   color: Colors.blue,
                              // ),
                              // Divider(color: Colors.grey[400]),

                              // PropertiesRowWidget(
                              //   title: 'Cash Masuk',
                              //   value: currency.format(data.outcomeCash),
                              //   primary: true,
                              // ),

                              // const PropertiesRowWidget(
                              //   title: 'Pembayaran Pembelian',
                              //   value: 'title',
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Cash',
                              //   value: 'title',
                              //   italic: true,
                              //   subValue: currency.format(data.totalCash),
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Transfer',
                              //   value: 'title',
                              //   italic: true,
                              //   subValue:
                              //       currency.format(data.totalTransfer),
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Total Bayar Pembelian',
                              //   value: currency.format(data.income),
                              //   primary: true,
                              //   color: Colors.green,
                              // ),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'Belum Bayar',
                              //   value: currency.format(data.notYetPaid),
                              //   // subValue: data.totalDiscount > 0
                              //   //     ? 'Rp${currency.format(data.totalDebt)} - diskon Rp${currency.format(data.totalDiscount)}'
                              //   //     : '',
                              //   primary: true,
                              //   color: Colors.red,
                              // ),
                              // Divider(color: Colors.grey[400]),
                              // const SizedBox(height: 60),
                              // // Divider(color: Colors.grey[400]),
                              // const PropertiesRowWidget(
                              //   title: 'Pembayaran Piutang',
                              //   value: 'title',
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Cash',
                              //   value: 'title',
                              //   subValue:
                              //       currency.format(data.totalDebtCash),
                              //   italic: true,
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Transfer',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.totalDebtTransfer),
                              //   italic: true,
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Total Bayar Piutang',
                              //   value: currency.format(data.incomeDebt),
                              //   primary: true,
                              //   color: Colors.green,
                              // ),
                              // const SizedBox(height: 20),

                              // const SizedBox(height: 30),
                              // Divider(color: Colors.grey[400]),
                              // const PropertiesRowWidget(
                              //   title: 'Pembayaran Sales',
                              //   value: 'title',
                              //   primary: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Bayar Sales Cash',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.totalSalesCash * -1),
                              //   italic: true,
                              //   color: Colors.red,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Bayar Sales Transfer',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.totalSalesTransfer * -1),
                              //   italic: true,
                              //   color: Colors.red,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Total Bayar Sales',
                              //   value: currency.format(data.outcome * -1),
                              //   color: Colors.red,
                              //   primary: true,
                              // ),
                              // const SizedBox(height: 20),
                              // if (controller.selectedSection.value == 'daily')
                              //   Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       InkWell(
                              //         onTap: () async =>
                              //             detailSalesPaymentMobile(controller
                              //                 .invoicesSalesByPaymentDate)

                              //         // detailSalesPayment(controller
                              //         //     .invoicesSalesByPaymentDate)
                              //         ,
                              //         child: Container(
                              //             padding: const EdgeInsets.symmetric(
                              //                 vertical: 4, horizontal: 8),
                              //             decoration: BoxDecoration(
                              //               color: Theme.of(context)
                              //                   .colorScheme
                              //                   .primary,
                              //               borderRadius:
                              //                   BorderRadius.circular(4),
                              //             ),
                              //             child: Text(
                              //               'Lihat Detail',
                              //               style:
                              //                   TextStyle(color: Colors.white),
                              //             )),
                              //       ),
                              //     ],
                              //   ),
                              // const SizedBox(height: 60),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'Total Bayar Pembelian',
                              //   value: currency.format(data.outcome),
                              //   primary: true,
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: 'Total Bayar Piutang',
                              //   value: currency.format(data.incomeDebt),
                              //   primary: true,
                              //   color: Colors.green,
                              // ),
                              // PropertiesRowWidget(
                              //   title: controller
                              //               .authService.account.value!.name ==
                              //           'Arca Nusantara'
                              //       ? 'Total Bayar Sales Cash'
                              //       : 'Total Bayar Sales',
                              //   value: currency.format((controller.authService
                              //                   .account.value!.name ==
                              //               'Arca Nusantara'
                              //           ? data.totalSalesCash
                              //           : data.totalSalesPay) *
                              //       -1),
                              //   color: Colors.red,
                              //   primary: true,
                              // ),
                              // if (data.totalOperatingCost > 0)
                              //   PropertiesRowWidget(
                              //     title: 'Biaya Operasional',
                              //     value: currency.format(
                              //         data.totalOperatingCost * -1),
                              //     primary: true,
                              //     color: Colors.red,
                              //   ),
                              // Divider(color: Colors.grey[400]),
                              // PropertiesRowWidget(
                              //   title: 'TOTAL YANG DITERIMA',
                              //   primary: true,
                              //   value: currency.format(
                              //     controller.authService.account.value!.name ==
                              //             'Arca Nusantara'
                              //         ? data.totalReceiveMoneyArca
                              //         : data.finalIncomeCash,
                              //   ),
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Transfer diterima',
                              //   value: 'title',
                              //   subValue: currency
                              //       .format(data.finalIncomeTransfer),
                              //   italic: true,
                              // ),
                              // PropertiesRowWidget(
                              //   title: '      - Cash diterima',
                              //   value: 'title',
                              //   subValue: currency.format((controller
                              //               .authService.account.value!.name ==
                              //           'Arca Nusantara'
                              //       ? data.totalCashReceiveCashArca
                              //       : data.finalIncomeCash)),

                              // currency.format(
                              //     data.cash + data.debtCash - data.salesCash),
                              // italic: true,
                              // ),

                              // const SizedBox(height: 30),
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
