import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../../infrastructure/navigation/routes.dart';
import '../../../../infrastructure/utils/display_format.dart';
import '../../payment_widget/payment_popup_widget.dart';
import '../../payment_widget/payment_widget_controller.dart';
import '../../properties_row_widget.dart';

class CalculatePrice extends StatelessWidget {
  const CalculatePrice({
    super.key,
    required this.editableInvoice,
    this.isEdit = false,
    this.onlyPayment = false,
  });

  final InvoiceModel editableInvoice;
  final bool isEdit;
  final bool onlyPayment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildPriceDetails(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPriceDetails() {
    final List<Widget> details = [];

    if (isEdit) {
      details.add(_buildPropertiesRow(
          'Total Harga (${editableInvoice.purchaseList.value.items.length} Barang)',
          currency.format(editableInvoice.subtotalBill)));
    }

    if (editableInvoice.totalInvididualDiscount > 0) {
      details.add(_buildPropertiesRow('Diskon',
          '-${currency.format(editableInvoice.totalInvididualDiscount)}',
          color: Colors.red));
    }

    if (editableInvoice.additionalDIscount > 0) {
      details.add(_buildPropertiesRow('Diskon Tambahan',
          '-${currency.format(editableInvoice.additionalDIscount)}',
          color: Colors.red));
    }

    if (editableInvoice.otherCosts.isNotEmpty) {
      details.add(_buildOtherCosts(editableInvoice));
    }

    if (isEdit) {
      details.add(_buildPropertiesRow('Return Tambahan',
          '-${currency.format(editableInvoice.subtotalAdditionalReturn)}',
          color: Colors.red));
      details.add(_buildPropertiesRow(
          'Biaya Return', currency.format(editableInvoice.returnFee.value)));
      details.add(_buildPropertiesRow(
          'Total Belanja', currency.format(editableInvoice.totalBill)));
      details.add(_buildPropertiesRow(
          'Total Pembayaran', currency.format(editableInvoice.subtotalPaid),
          color: Colors.green));
      details.add(
        _buildPropertiesRow(
          editableInvoice.debtAmount.value > 0 ? 'Sisa Bayar' : 'Kembalian',
          currency.format(editableInvoice.debtAmount.value * -1),
        ),
      );
    }

    if (isEdit) details.add(Divider(color: Colors.grey));

    if (editableInvoice.purchaseList.value.items.isNotEmpty) {
      details.add(PaymentButton(
        editableInvoice: editableInvoice,
        isEdit: isEdit,
        onlyPayment: onlyPayment,
      ));
    }

    return details;
  }

  Widget _buildPropertiesRow(String title, String value, {Color? color}) {
    return PropertiesRowWidget(title: title, value: value, color: color);
  }

  Widget _buildOtherCosts(InvoiceModel invoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(title: Text('Biaya Lainnya:')),
        ...invoice.otherCosts.map(
          (cost) => ListTile(
            tileColor: Colors.grey[100],
            dense: true,
            title: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(cost.name, textAlign: TextAlign.left),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Rp${currency.format(cost.amount)}',
                      textAlign: TextAlign.end),
                ),
              ],
            ),
            leading: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildRemoveCostButton(
                  () => invoice.removeOtherCost(cost.name)),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRemoveCostButton(VoidCallback onPressed) {
    return Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: Get.context!.theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Symbols.close, size: 12, color: Colors.white),
      ),
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({
    super.key,
    required this.editableInvoice,
    required this.isEdit,
    required this.onlyPayment,
  });

  final InvoiceModel editableInvoice;
  final bool isEdit;
  final bool onlyPayment;

  @override
  Widget build(BuildContext context) {
    final cartItems = editableInvoice.purchaseList.value.items;

    return Row(
      children: [
        Expanded(
          child: ListTile(
            onTap: isEdit
                ? null
                : () async {
                    final paymentC = Get.put(PaymentController());
                    paymentC.displayInvoice = editableInvoice;
                    paymentC.assign(
                      editableInvoice,
                      isEditMode: isEdit,
                      onlyPaymentMode: onlyPayment,
                    );
                    if (vertical) {
                      await Get.toNamed(Routes.PAYMENT_LIST_VIEW);
                    } else {
                      if (editableInvoice.totalBill > -1) {
                        await paymentPopup();
                      } else {
                        _showNoItemsDialog();
                      }
                    }
                  },
            tileColor: isEdit ? null : Theme.of(context).colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: _buildPaymentButtonContent(cartItems, context),
            trailing: isEdit
                ? null
                : const Icon(Symbols.shopping_basket,
                    fill: 1, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButtonContent(List cartItems, BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'TOTAL' : 'Total Harga',
                style: context.textTheme.titleLarge!.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isEdit
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
              Text(
                '(${cartItems.length} Item)',
                style: context.textTheme.titleSmall!.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  color: isEdit
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(() => Text(
                    'Rp${currency.format(editableInvoice.remainingDebt)}',
                    style: context.textTheme.titleLarge!.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isEdit
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    ),
                  )),
              if (editableInvoice.totalDiscount > 0 && !isEdit)
                Text(
                  'Rp-${currency.format(editableInvoice.subtotalBill)}',
                  style: context.textTheme.titleLarge!.copyWith(
                    fontSize: 14,
                    color: isEdit
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                        : Colors.white.withOpacity(0.5),
                    decoration: TextDecoration.lineThrough,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNoItemsDialog() {
    Get.defaultDialog(
      title: 'Error',
      middleText: 'Tidak ada Barang yang ditambahkan.',
      confirm: TextButton(
        onPressed: () => Get.back(),
        child: const Text('OK'),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

// import '../../../infrastructure/models/invoice_model/invoice_model.dart';
// import '../../../infrastructure/models/payment_list_model.dart';
// import '../../../infrastructure/navigation/routes.dart';
// import '../../../infrastructure/utils/display_format.dart';
// // import '../../../modules/home/views/payment_listview_view.dart';
// // import '../../cart/cart.screen.dart';
// import '../../global_widget/payment_widget/payment_popup_widget.dart';
// import '../../global_widget/payment_widget/payment_widget_controller.dart';

// class CalculatePrice extends StatelessWidget {
//   const CalculatePrice({super.key, required this.invoice, this.isEdit = false});

//   final InvoiceModel invoice;
//   final bool isEdit;

//   @override
//   Widget build(BuildContext context) {
//     print(invoice.totalBill);

//     return Row(
//       children: [
//         Expanded(
//           child: Obx(
//             () {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title:
//                           'Total Harga (${invoice.purchaseList.value.items.length} Barang)',
//                       value: currency.format(
//                         invoice.subtotalBill,
//                       ),
//                     ),
//                   if (invoice.totalInvididualDiscount > 0)
//                     PropertiesRowWidget(
//                       title: 'Diskon',
//                       value:
//                           '-${currency.format(invoice.totalInvididualDiscount)}',
//                       color: Colors.red,
//                     ),
//                   if (invoice.additionalDIscount > 0)
//                     PropertiesRowWidget(
//                       title: 'Diskon Tambahan',
//                       value: '-${currency.format(invoice.additionalDIscount)}',
//                       color: Colors.red,
//                     ),
//                   if (invoice.otherCosts.isNotEmpty)
//                     ListTile(
//                       title: Text(
//                         'Biaya Lainnya:',
//                         style: Get.context!.textTheme.bodySmall,
//                       ),
//                     ),
//                   if (invoice.otherCosts.isNotEmpty)
//                     ListView.builder(
//                       shrinkWrap: true,
//                       itemCount: invoice.otherCosts.length,
//                       itemBuilder: (context, index) {
//                         return ListTile(
//                           tileColor: Colors.grey[100],
//                           dense: true,
//                           title: Row(
//                             children: [
//                               Expanded(
//                                 flex: 5,
//                                 child: Text(invoice.otherCosts[index].name,
//                                     style: Theme.of(Get.context!)
//                                         .textTheme
//                                         .titleSmall,
//                                     textAlign: TextAlign.left),
//                               ),
//                               Expanded(
//                                 flex: 3,
//                                 child: Text(
//                                     'Rp${currency.format(invoice.otherCosts[index].amount)}',
//                                     style: Theme.of(Get.context!)
//                                         .textTheme
//                                         .titleSmall,
//                                     textAlign: TextAlign.end),
//                               ),
//                             ],
//                           ),
//                           leading: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 4),
//                             child: Container(
//                               height: 28,
//                               width: 28,
//                               decoration: BoxDecoration(
//                                   color: Theme.of(context).colorScheme.primary,
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(6))),
//                               child: IconButton(
//                                 onPressed: () => invoice.removeOtherCost(
//                                     invoice.otherCosts[index].name),
//                                 icon: const Icon(
//                                   Symbols.close,
//                                   size: 12,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title: 'Return Tambahan',
//                       value:
//                           '-${currency.format(invoice.subtotalAdditionalReturn)}',
//                       color: Colors.red,
//                     ),
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title: 'Biaya Return',
//                       value: currency.format(invoice.returnFee.value),
//                     ),
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title: 'Total Belanja',
//                       value: currency.format(invoice.totalBill),
//                     ),
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title: 'Total Pembayaran',
//                       value: currency.format(invoice.subtotalPaid),
//                       color: Colors.green,
//                     ),
//                   if (isEdit)
//                     PropertiesRowWidget(
//                       title: invoice.debtAmount.value > 0
//                           ? 'Sisa Bayar'
//                           : 'Kembalian',
//                       value: currency.format(invoice.debtAmount.value * -1),
//                     ),
//                   if (invoice.totalPaid < invoice.totalBill)
//                     PaymentButton(
//                       invoice: invoice,
//                       isEdit: isEdit,
//                     ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class PaymentButton extends StatelessWidget {
//   const PaymentButton({
//     super.key,
//     required this.invoice,
//     required this.isEdit,
//   });

//   final InvoiceModel invoice;
//   final bool isEdit;

//   @override
//   Widget build(BuildContext context) {
//     final PaymentController paymentC = Get.put(PaymentController());

//     final cartItems = invoice.purchaseList.value.items;
//     return Row(
//       children: [
//         Expanded(
//             child: ListTile(
//           onTap: () async {
//             if (vertical) {
//               paymentC.clear();
//               paymentC.invoice = invoice;
//               paymentC.isEdit.value = isEdit;
//               await Get.toNamed(Routes.PAYMENT_LIST_VIEW);
//               // }
//             } else {
//               if (invoice.totalBill > 0) {
//                 paymentPopup(invoice, isEdit: isEdit);
//               } else {
//                 Get.defaultDialog(
//                   title: 'Error',
//                   middleText: 'Tidak ada Barang yang ditambahkan.',
//                   confirm: TextButton(
//                     onPressed: () => Get.back(),
//                     child: const Text('OK'),
//                   ),
//                 );
//               }
//             }
//           },
//           tileColor: Theme.of(context).colorScheme.primary,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//           title: SizedBox(
//             height: 50,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isEdit ? 'Tambah pembayar' : 'Total Harga',
//                       style: context.textTheme.titleLarge!.copyWith(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Text(
//                       '(${cartItems.length} Item)',
//                       style: context.textTheme.titleSmall!.copyWith(
//                         // fontSize: 18,
//                         fontStyle: FontStyle.italic,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Rp${currency.format(invoice.remainingDebt)}',
//                       style: context.textTheme.titleLarge!.copyWith(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     if (invoice.totalDiscount > 0 && !isEdit)
//                       Text(
//                         'Rp-${currency.format(invoice.subtotalBill)}',
//                         style: context.textTheme.titleLarge!.copyWith(
//                           fontSize: 14,
//                           // fontWeight: FontWeight.bold,
//                           color: Colors.white.withOpacity(0.5),
//                           decoration: TextDecoration.lineThrough,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           trailing: isEdit
//               ? null
//               : Icon(
//                   Symbols.shopping_basket,
//                   fill: 1,
//                   color: Colors.white,
//                 ),
//         )),
//       ],
//     );
//   }
// }

// class PropertiesRowWidget extends StatelessWidget {
//   const PropertiesRowWidget({
//     super.key,
//     required this.title,
//     required this.value,
//     this.subValue,
//     this.primary,
//     this.color,
//   });

//   final String title;
//   final String value;
//   final String? subValue;
//   final bool? primary;
//   final Color? color;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(title,
//                     style: primary != null && primary == true
//                         ? context.textTheme.titleLarge!
//                             .copyWith(fontWeight: FontWeight.bold, color: color)
//                         : context.textTheme.titleMedium!
//                             .copyWith(color: color)),
//                 Row(
//                   children: [
//                     Text(
//                       subValue ?? '',
//                       style: context.textTheme.bodySmall!
//                           .copyWith(fontStyle: FontStyle.italic, color: color),
//                     ),
//                     const SizedBox(width: 16),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             value == '0' || value == '-0' ? '-' : 'Rp$value',
//             style: primary != null && primary == true
//                 ? context.textTheme.titleLarge!
//                     .copyWith(fontWeight: FontWeight.bold, color: color)
//                 : context.textTheme.titleMedium!.copyWith(color: color),
//           )
//         ],
//       ),
//     );
//   }
// }
