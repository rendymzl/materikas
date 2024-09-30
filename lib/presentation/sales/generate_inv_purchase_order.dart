import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/invoice_model/cart_item_model.dart';

import '../../../infrastructure/models/print_column_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../../infrastructure/models/purchase_order_model.dart';
import '../global_widget/invoice_print_widget/generator.dart';

var divider = Uint8List.fromList(
    '--------------------------------------------------------------------------------'
        .codeUnits);
var space = Uint8List.fromList([27, 74, 24]);

Future<List<int>> generateInvPurchaseOrder(PurchaseOrderModel invoice) async {
  final AuthService authService = Get.find<AuthService>();
  late final store = authService.store.value;
  Generator generator = Generator();
  List<int> bytes = [];

  //!widht 80
  bytes += generator.row([
    PrintColumn(
        text: (store!.name.value).toUpperCase(),
        width: 22,
        bold: true,
        size: 'large'),
    PrintColumn(text: '', width: 14, bold: true, size: 'large', align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(text: 'PO Barang', width: 22, bold: true, size: 'large'),
    PrintColumn(text: '', width: 14, bold: true, size: 'large', align: 'right'),
  ]);
  bytes += generator.row([
    PrintColumn(text: '', width: 3),
    PrintColumn(text: '', width: 32),
    PrintColumn(text: '', width: 13, align: 'right'),
    PrintColumn(text: '', width: 10),
    PrintColumn(
        text: '${DateFormat('dd-MM-y', 'id').format(
          invoice.createdAt.value!,
        )} ${invoice.orderId!}',
        width: 22,
        align: 'right'),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: 'Toko Bangunan',
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'Kepada Yth.',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(text: invoice.sales.value?.name ?? '', width: 30),
  ]);

  bytes += generator.row([
    PrintColumn(
      text: store.address.value,
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'Alamat',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(text: invoice.sales.value?.address ?? '', width: 30),
  ]);

  String phone = store.phone.value;
  String telp = store.telp.value;
  String slash = (phone.isNotEmpty && telp.isNotEmpty) ? '/' : '';
  bytes += generator.row([
    PrintColumn(
      text: '$phone $slash $telp',
      width: 35,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(
      text: 'No Telp',
      width: 11,
    ),
    PrintColumn(
      text: ':',
      width: 2,
    ),
    PrintColumn(text: invoice.sales.value?.phone ?? '', width: 30),
  ]);

  bytes += divider;
  bytes += generator.row([
    PrintColumn(text: 'No', width: 3),
    PrintColumn(text: 'Nama Barang', width: 32),
    PrintColumn(text: '', width: 13, align: 'right'),
    PrintColumn(text: 'Jumlah', width: 10),
    PrintColumn(text: '', width: 9, align: 'right'),
    PrintColumn(text: '', width: 13, align: 'right'),
  ]);
  bytes += divider;

  List<CartItem> purchase = invoice.purchaseList.value.items;
  for (var i = 0; i < purchase.length; i++) {
    var item = purchase[i];
    if (item.quantity.value > 0) {
      bytes += generator.row([
        PrintColumn(text: '${i + 1}', width: 3),
        PrintColumn(text: item.product.productName, width: 32),
        PrintColumn(text: '', width: 13, align: 'right'),
        PrintColumn(
            text: '${number.format(item.quantity.value)} ${item.product.unit}',
            width: 10),
        PrintColumn(text: '', width: 9, align: 'right'),
        PrintColumn(text: '', width: 13, align: 'right'),
      ]);
    }
  }
  for (var i = 0; i < 14 - purchase.length; i++) {
    bytes += space;
  }
  bytes += divider;
  bytes += generator.row([
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: 'Menerima,',
      width: 20,
    ),
    PrintColumn(
      text: 'Hormat Kami,',
      width: 20,
    ),
    PrintColumn(
      text: '',
      width: 5,
    ),
    PrintColumn(
      text: '',
      width: 15,
    ),
    PrintColumn(
      text: '',
      width: 2,
    ),
    PrintColumn(text: '', width: 13, align: 'right'),
  ]);
  // bytes += generator.row([
  //   PrintColumn(
  //     text: '',
  //     width: 50,
  //   ),
  //   PrintColumn(
  //     text: 'Diskon',
  //     width: 15,
  //   ),
  //   PrintColumn(
  //     text: ':',
  //     width: 2,
  //   ),
  //   PrintColumn(
  //       text: invoice.totalDiscount > 0
  //           ? '-${currency.format(invoice.totalDiscount)}'
  //           : '0',
  //       width: 13,
  //       align: 'right'),
  // ]);
  // bytes += generator.row([
  //   PrintColumn(
  //     text: '',
  //     width: 50,
  //   ),
  //   PrintColumn(
  //     text: 'Biaya Lainnya',
  //     width: 15,
  //   ),
  //   PrintColumn(
  //     text: ':',
  //     width: 2,
  //   ),
  //   PrintColumn(
  //       text: currency.format(invoice.totalOtherCosts),
  //       width: 13,
  //       align: 'right'),
  // ]);
  // bytes += generator.row([
  //   PrintColumn(
  //     text: '',
  //     width: 50,
  //   ),
  //   PrintColumn(
  //     text: 'Total',
  //     width: 15,
  //   ),
  //   PrintColumn(
  //     text: ':',
  //     width: 2,
  //   ),
  //   PrintColumn(
  //       text: currency.format(invoice.totalBill), width: 13, align: 'right'),
  // ]);

  // bytes += space;
  // bytes += generator.row([
  //   PrintColumn(
  //     text: '',
  //     width: 50,
  //   ),
  //   PrintColumn(
  //     text: 'Bayar',
  //     width: 15,
  //   ),
  //   PrintColumn(
  //     text: ':',
  //     width: 2,
  //   ),
  //   PrintColumn(
  //       text: currency.format(invoice.totalPaid), width: 13, align: 'right'),
  // ]);
  // bytes += generator.row([
  //   PrintColumn(
  //     text: '',
  //     width: 50,
  //   ),
  //   PrintColumn(
  //     text: invoice.remainingDebt <= 0 ? 'Kembalian' : 'Kurang Bayar',
  //     width: 15,
  //   ),
  //   PrintColumn(
  //     text: ':',
  //     width: 2,
  //   ),
  //   PrintColumn(
  //       text: currency.format(invoice.remainingDebt * -1),
  //       width: 13,
  //       align: 'right'),
  // ]);

  bytes += [27, 69, 0];
  return bytes;
}
