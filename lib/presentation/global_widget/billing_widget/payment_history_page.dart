import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'billing_controller.dart';

void billingHistory() async {
  final BillingService billingService = Get.find();

  billingService.onInit();
  // print('awdwadwadwad ${billingService.isExpired}');
  showPopupPageWidget(
      title: 'Riwayat Pembayaran',
      height: MediaQuery.of(Get.context!).size.height * (0.8),
      width: MediaQuery.of(Get.context!).size.width * (0.75),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildPaymentHistoryTable(),
        ],
      ));
}

// Fungsi untuk menampilkan Tabel Riwayat Pembayaran
Widget _buildPaymentHistoryTable() {
  final BillingController billingController = Get.find();
  return Obx(() => Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No')),
              DataColumn(label: Text('Tagihan')),
              DataColumn(label: Text('Nomor Invoice')),
              DataColumn(label: Text('Tanggal Pembayaran')),
              DataColumn(label: Text('Total Tagihan')),
              // DataColumn(label: Text('Jumlah Dibayar')),
              DataColumn(label: Text('Status Pembayaran')),
            ],
            rows: List.generate(
                billingController.authService.store.value!.billings!.length,
                (index) {
              final payment =
                  billingController.authService.store.value!.billings![index];
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(payment.billingName)),
                DataCell(Text(payment.billingNumber)),
                DataCell(Text(payment.isPaid
                    ? date.format(payment.paymentDate ?? DateTime.now())
                    : '-')),
                // DataCell(Text(
                //     'Rp ${currency.format(billingController.billingService.billAmount.value)}')),
                DataCell(Text('Rp ${currency.format(payment.amountBill)}')),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: payment.isPaid ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      payment.isPaid ? 'Dibayar' : 'Belum Dibayar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ));
}
