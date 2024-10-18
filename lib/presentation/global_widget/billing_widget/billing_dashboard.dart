import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../popup_page_widget.dart';
import 'billing_controller.dart';
import 'payment_history_page.dart';

void billingDashboard() async {
  showPopupPageWidget(
      title: '',
      height: MediaQuery.of(Get.context!).size.height * (0.8),
      width: MediaQuery.of(Get.context!).size.width * (0.90),
      content: SizedBox(
        height: MediaQuery.of(Get.context!).size.height * (0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Ringkasan Tagihan
            _buildSummaryCard(),
            SizedBox(height: 20),

            // Tabel Rincian Invoice
            _buildInvoiceTable(),

            // Tombol aksi di bagian bawah
            Spacer(),
          ],
        ),
      ),
      buttonList: [
        Expanded(child: _buildBottomActions()),
      ]);
}

// Fungsi untuk membuat Ringkasan Tagihan
Widget _buildSummaryCard() {
  final BillingController billingController = Get.put(BillingController());
  return Obx(
    () => Column(
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ringkasan Tagihan untuk ${getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Invoice Dihasilkan:'),
                    Text(
                        '${billingController.invoiceService.monthlyInvoice.length}'),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Biaya Tagihan:'),
                    Text(
                        'Rp ${currency.format(billingController.authService.thisMonthAppBill.value)}'),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status Pembayaran:'),
                    Text(billingController.paymentStatus.value,
                        style: TextStyle(color: Colors.red)),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => billingHistory(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(Get.context!).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Riwayat Pembayaran',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// Fungsi untuk membuat Tabel Rincian Invoice
Widget _buildInvoiceTable() {
  final BillingController billingController = Get.find();
  return Obx(() => Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No')),
              DataColumn(label: Text('Tanggal Invoice Dibuat')),
              DataColumn(label: Text('Tanggal Transaksi')),
              DataColumn(label: Text('Nomor Invoice')),
              DataColumn(label: Text('Jumlah Transaksi')),
              DataColumn(label: Text('Biaya per Invoice')),
              DataColumn(label: Text('Status Invoice')),
            ],
            rows: List.generate(
                billingController.invoiceService.monthlyInvoice.length,
                (index) {
              final invoice =
                  billingController.invoiceService.monthlyInvoice[index];
              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(date.format(invoice.createdAt.value!))),
                DataCell(Text(date.format(invoice.initAt.value!))),
                DataCell(Text(invoice.invoiceId!)),
                DataCell(Text('Rp ${currency.format(invoice.totalPurchase)}')),
                DataCell(
                    Text('Rp ${currency.format(invoice.appBillAmount.value)}')),
                DataCell(
                    Text(invoice.removeAt.value != null ? 'Dihapus' : 'Valid')),
              ]);
            }),
          ),
        ),
      ));
}

// Fungsi untuk membuat Tombol Aksi di bagian bawah
Widget _buildBottomActions() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      ElevatedButton(
        onPressed: () {
          // Aksi untuk tombol Cetak Tagihan
        },
        child: Text('Cetak Tagihan'),
      ),
      ElevatedButton(
        onPressed: () {
          // Aksi untuk tombol Bayar Sekarang
        },
        child: Text('Bayar Sekarang'),
      ),
    ],
  );
}
