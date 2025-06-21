// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../infrastructure/dal/services/midtrans/midtrans_controller.dart';
// import '../../../infrastructure/utils/display_format.dart';
// import '../popup_page_widget.dart';
// import 'billing_controller.dart';
// import 'payment_billing_popup.dart';
// import 'payment_history_page.dart';

// void billingDashboard({bool expired = false}) async {
//   final BillingController billingController = Get.put(BillingController());

//   showPopupPageWidget(
//       barrierDismissible: expired,
//       title:
//           'Ringkasan Tagihan untuk ${getMonthName(billingController.billingService.selectedMonth.value.month)} ${billingController.billingService.selectedMonth.value.year}',
//       height: MediaQuery.of(Get.context!).size.height * (0.8),
//       width: MediaQuery.of(Get.context!).size.width * (0.90),
//       content: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           // mainAxisAlignment: MainAxisAlignment.end,
//           children: <Widget>[
//             // Ringkasan Tagihan
//             await _buildSummaryCard(),
//             SizedBox(height: 20),
      
//             // Tabel Rincian Invoice
//             _buildInvoiceTable(),
      
//             // Tombol aksi di bagian bawah
//             // Spacer(),
//           ],
//         ),
//       ),
//       buttonList: [
//         _buildBottomActions(),
//       ]);
// }

// // Fungsi untuk membuat Ringkasan Tagihan
// Future<Widget> _buildSummaryCard() async {
//   final BillingController controller = Get.find();
//   final billAmount = await controller.billingService.getBillAmount();
//   return Obx(
//     () => Row(
//       children: [
//         BillingBigCard(
//           title: 'Total Invoice Dihasilkan:',
//           value: '${controller.billInvoice.value.length}',
//         ),
//         BillingBigCard(
//           title: 'Total Biaya Tagihan:',
//           value: 'Rp ${currency.format(billAmount)}',
//         ),
//         BillingBigCard(
//           title: 'Status Tagihan:',
//           value: (controller.billingService.isExpired)
//               ? 'Bayar tagihan untuk lanjut menggunakan aplikasi'
//               : controller.billingService.getIsLastMonthBillPaid()
//                   ? 'Dapat dibayar di Bulan ${getMonthName(controller.billingService.nextMonth.month)}'
//                   : 'Belum dibayar',
//         ),
//       ],
//     ),
//   );
// }

// class BillingBigCard extends StatelessWidget {
//   const BillingBigCard({super.key, required this.title, required this.value});

//   final String title;
//   final String value;

//   @override
//   Widget build(BuildContext context) {
//     // final BillingController billingController = Get.find();
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: SizedBox(
//             height: 70,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 Text(title),
//                 Text(
//                   value,
//                   style: ((title.toLowerCase().contains('status'))
//                           ? context.textTheme.titleLarge!
//                           : context.textTheme.displaySmall!)
//                       .copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: title.toLowerCase().contains('status')
//                               ? Theme.of(context).primaryColor
//                               : null),
//                 ),
//                 // SizedBox(height: 12),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Fungsi untuk membuat Tabel Rincian Invoice
// Widget _buildInvoiceTable() {
//   final BillingController controller = Get.find();
//   return Obx(() => Expanded(
//         child: SizedBox(
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: DataTable(
//               columns: [
//                 DataColumn(label: Text('No')),
//                 DataColumn(label: Text('Tanggal Dibuat')),
//                 DataColumn(label: Text('Tanggal Transaksi')),
//                 DataColumn(label: Text('Nomor Invoice')),
//                 DataColumn(label: Text('Jumlah Transaksi')),
//                 DataColumn(label: Text('Biaya/Invoice')),
//                 DataColumn(label: Text('Status')),
//               ],
//               rows: List.generate(controller.billInvoice.value.length, (index) {
//                 final invoice = controller.billInvoice.value[index];
//                 return DataRow(cells: [
//                   DataCell(Text('${index + 1}')),
//                   DataCell(Text(date.format(invoice.initAt.value!))),
//                   DataCell(Text(date.format(invoice.createdAt.value!))),
//                   DataCell(Text(invoice.invoiceId!)),
//                   DataCell(
//                       Text('Rp ${currency.format(invoice.totalPurchase)}')),
//                   DataCell(Text(
//                       'Rp ${currency.format(invoice.appBillAmount.value)}')),
//                   DataCell(Text(
//                       invoice.removeAt.value != null ? 'Dihapus' : 'Valid')),
//                 ]);
//               }),
//             ),
//           ),
//         ),
//       ));
// }

// // Fungsi untuk membuat Tombol Aksi di bagian bawah
// Widget _buildBottomActions() {
//   final BillingController billingController = Get.find();
//   final MidtransController midtransC = Get.put(MidtransController());
//   return Obx(
//     () => Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         ElevatedButton(
//           onPressed: () => billingHistory(),
//           child: Text('Riwayat Pembayaran'),
//         ),
//         SizedBox(width: 12),
//         (midtransC.isLoading.value)
//             ? const CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed:
//                     billingController.billingService.getIsLastMonthBillPaid()
//                         ? null
//                         : () => paymentBillingPopup(),
//                 child: Text('Bayar Sekarang'),
//               ),
//       ],
//     ),
//   );
// }
