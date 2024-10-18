import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'billing_controller.dart';

void billingHistory() async {
  showPopupPageWidget(
      title: '',
      height: MediaQuery.of(Get.context!).size.height * (0.8),
      width: MediaQuery.of(Get.context!).size.width * (0.90),
      content: SizedBox(
        height: MediaQuery.of(Get.context!).size.height * (0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header
            Text(
              'Riwayat Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Tabel Riwayat Pembayaran
            _buildPaymentHistoryTable(),
          ],
        ),

        // buttonList: [
        //   Expanded(child: _buildBottomActions()),
        // ]
      ));
}

// Fungsi untuk menampilkan Tabel Riwayat Pembayaran
Widget _buildPaymentHistoryTable() {
  final BillingController billingController = Get.find();
  return Obx(() => Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No')),
              DataColumn(label: Text('Tagihan')),
              DataColumn(label: Text('Nomor Invoice')),
              DataColumn(label: Text('Tanggal Pembayaran')),
              DataColumn(label: Text('Jumlah Dibayar')),
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
                DataCell(Text(
                    payment.isPaid ? date.format(payment.paymentDate!) : '')),
                DataCell(Text('Rp ${currency.format(payment.amountPaid)}')),
                DataCell(Text(payment.isPaid ? 'Dibayar' : 'Belum Dibayar')),
              ]);
            }),
          ),
        ),
      ));
}
