import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import 'print_usb_controller.dart';

Future<Uint8List> generateInvoice(InvoiceModel invoice,
    {bool isSupplier = false}) async {
  final controller = Get.put(PrinterUsbController());

  List<CartItem> filterPurchase(InvoiceModel invoice) {
    List<CartItem> workerData = invoice.purchaseList.value.items
        .where((p) => p.quantity.value > 0)
        .map((purchased) => purchased)
        .toList();
    return workerData;
  }

  String getPaymentTypes(InvoiceModel invoice) {
    String paymentTypes = '';
    if (invoice.payments.isNotEmpty) {
      for (var payment in invoice.payments) {
        if (payment.amountPaid > 0) {
          if (paymentTypes.isNotEmpty) {
            paymentTypes += ', ';
          }
          paymentTypes += payment.method!;
        }
      }
    }
    return paymentTypes.isEmpty ? 'Cash' : paymentTypes;
  }

  List<CartItem> purchase = filterPurchase(invoice);

  String phone = controller.store!.phone.value;
  String telp = controller.store!.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';

  final pdf = pw.Document();

  // Lebar kertas continuous form
  const double paperWidth = 230.0; // 8.3 inch (A4 width)

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(
          paperWidth * PdfPageFormat.mm, double.infinity), // Panjang otomatis
      build: (pw.Context context) {
        return pw.Container(
          width: paperWidth * PdfPageFormat.mm,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      if (controller.logo.value != null)
                        pw.Image(
                          pw.MemoryImage(
                              controller.logo.value!.readAsBytesSync()),
                          width: 50,
                          height: 50,
                        ),
                      pw.SizedBox(width: 4),
                      pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              controller.store!.name.value,
                              style: pw.TextStyle(
                                  fontSize: 18, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(controller.store!.address.value),
                            pw.Text('$phone $slash $telp'),
                          ]),
                    ],
                  ),
                  pw.Text(
                    isSupplier ? '' : 'INVOICE',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.right,
                  ),
                ],
              ),
              pw.Text(
                  '---------------------------------------------------------------------'),
              // Info Invoice
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text("No Invoice"),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(': ${invoice.invoiceId!}'),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: pw.Text(isSupplier ? "Supplier" : "Kepada Yth."),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                              isSupplier ? "Tgl Pembelian" : "Tgl Penjualan"),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                              ': ${DateFormat('dd MMMM yyyy', 'id').format(
                            invoice.createdAt.value!,
                          )}'),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: pw.Text(invoice.customer.value != null
                        ? '${invoice.customer.value!.name}  ${invoice.customer.value!.address!}'
                        : ''),
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text("Jenis Transaksi"),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(': ${getPaymentTypes(invoice)}'),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 4),
                  pw.Expanded(
                    child: pw.Text(invoice.customer.value != null
                        ? invoice.customer.value!.address!
                        : ''),
                  ),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.SizedBox(width: 24, child: pw.Text('No')),
                  pw.Expanded(flex: 9, child: pw.Text('Nama Barang')),
                  pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Qty',
                        textAlign: pw.TextAlign.center,
                      )),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'diskon',
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Harga',
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Jumlah',
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.Divider(),

              // purchase.map(toElement)

              for (var i = 0; i < purchase.length; i++)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.SizedBox(width: 24, child: pw.Text('${i + 1}')),
                    pw.Expanded(
                      flex: 9,
                      child: pw.Text(purchase[i].product.productName),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        number.format(purchase[i].quantity.value),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.SizedBox(width: 4),
                    pw.Expanded(
                      child: pw.Text(purchase[i].product.unit),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        currency.format(purchase[i].individualDiscount.value),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        currency.format(isSupplier
                            ? purchase[i].product.costPrice.value
                            : purchase[i].getPrice(invoice.priceType.value)),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        currency.format(isSupplier
                            ? purchase[i].subCost
                            : purchase[i].getSubBill(invoice.priceType.value)),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                      flex: 11,
                      child: pw.Text(
                        !isSupplier &&
                                controller.store!.textPrint != null &&
                                controller.store!.textPrint!.isNotEmpty
                            ? controller.store!.textPrint![0]
                            : '',
                      )),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Total :', textAlign: pw.TextAlign.right),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      currency.format(
                          isSupplier ? invoice.totalCost : invoice.totalBill),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              if (!isSupplier &&
                  controller.store!.textPrint != null &&
                  controller.store!.textPrint!.length > 1)
                for (var i = 1; i < controller.store!.textPrint!.length; i++)
                  pw.Text(controller.store!.textPrint![i]),

              for (var i = 0; i < 14 - purchase.length; i++)
                pw.SizedBox(height: 4),
              if (!isSupplier)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child:
                          pw.Text('Customer', textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      child: pw.Text('Admin', textAlign: pw.TextAlign.center),
                    ),
                    pw.Expanded(
                      child: pw.Text('Driver', textAlign: pw.TextAlign.center),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    ),
  );

  return pdf.save();
}
