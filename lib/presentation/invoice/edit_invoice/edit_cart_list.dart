import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../../infrastructure/models/invoice_model/cart_model.dart';
import '../../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../../infrastructure/utils/display_format.dart';

class EditCartList extends StatelessWidget {
  const EditCartList({
    super.key,
    required this.invoice,
    required this.cartItemList,
    this.isReturn = false,
  });

  final InvoiceModel invoice;
  final Cart cartItemList;
  final bool isReturn;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.grey[200],
      ),
      itemCount: cartItemList.items.length,
      itemBuilder: (BuildContext context, int index) {
        return Obx(
          () {
            late CartItem productCart;

            productCart = cartItemList.items[index];

            final quantityTextC = TextEditingController();
            String displayQtyValue = productCart.quantity.value % 1 == 0
                ? productCart.quantity.value.toInt().toString()
                : productCart.quantity.value.toString().replaceAll('.', ',');
            quantityTextC.text = displayQtyValue;
            quantityTextC.selection = TextSelection.fromPosition(
              TextPosition(offset: quantityTextC.text.length),
            );

            final quantityReturnTextC = TextEditingController();
            String displayReturnQtyValue =
                productCart.quantityReturn.value % 1 == 0
                    ? productCart.quantityReturn.value.toInt().toString()
                    : productCart.quantityReturn.value
                        .toString()
                        .replaceAll('.', ',');
            quantityReturnTextC.text = displayReturnQtyValue;
            quantityReturnTextC.selection = TextSelection.fromPosition(
              TextPosition(offset: quantityReturnTextC.text.length),
            );

            final discountTextC = TextEditingController();
            discountTextC.text = productCart.individualDiscount.value == 0
                ? '-'
                : currency.format(productCart.individualDiscount.value);
            discountTextC.selection = TextSelection.fromPosition(
              TextPosition(offset: discountTextC.text.length),
            );

            bool emptyQty = ((productCart.quantity.value == 0 && !isReturn) ||
                (productCart.quantityReturn.value == 0 && isReturn));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: ListTile(
                enabled: !emptyQty,
                tileColor: emptyQty
                    ? Colors.grey[100]!.withOpacity(0.3)
                    : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                title: SizedBox(
                  height: 30,
                  // margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${productCart.product.productName}',
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Container(
                            height: 28,
                            width: 28,
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(5))),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Symbols.close,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                subtitle: SizedBox(
                  // color: Colors.amber,
                  height: 47,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          child: Text(
                            'Rp${currency.format(productCart.product.getPrice(invoice.priceType.value).value)}',
                            // style: context.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          child: Row(
                            children: [
                              // Expanded(
                              //           child: QuantityTextField(
                              //             invoice: invoice,
                              //             quantityTextC: quantityReturnTextC,
                              //             controller: controller,
                              //             productCart: productCart,
                              //             isEdit: isEdit,
                              //             isReturn: isReturn,
                              //             additionalReturn: additionalReturn,
                              //           ),
                              //         )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 7,
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// //* 1.1 QuantityTextField ==================================================================
// class QuantityTextField extends StatelessWidget {
//   const QuantityTextField({
//     super.key,
//     required this.invoice,
//     required this.quantityTextC,
//     required this.controller,
//     required this.productCart,
//     required this.isEdit,
//     required this.isReturn,
//     required this.additionalReturn,
//   });

//   final Invoice invoice;
//   final TextEditingController quantityTextC;
//   final InvoiceController controller;
//   final CartItem productCart;
//   final bool isEdit;
//   final bool isReturn;
//   final bool additionalReturn;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//         controller: quantityTextC,
//         textAlign: TextAlign.center,
//         // maxLength: 3,
//         decoration: InputDecoration(
//           labelText: 'Jumlah',
//           labelStyle: context.textTheme.bodySmall!
//               .copyWith(fontStyle: FontStyle.italic),
//           prefixText: 'x',
//           counterText: '',
//           filled: true,
//           fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//           contentPadding: const EdgeInsets.all(10),
//           border: const OutlineInputBorder(borderSide: BorderSide.none),
//           isDense: true,
//         ),
//         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         inputFormatters: [
//           FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d*'))
//         ],
//         onChanged: (value) {
//           if (!value.endsWith(',')) {
//             controller.isComa.value = false;
//             value == '' ? 0 : value;
//             String unformattedValue = value.replaceAll('.', '');
//             String processedValue = unformattedValue.replaceAll(',', '.');
//             !additionalReturn
//                 ? isEdit
//                     ? controller.quantityEditHandle(productCart, processedValue,
//                         invoice, quantityTextC, isReturn)
//                     : controller.quantityReturnHandle(
//                         productCart, processedValue, invoice, quantityTextC)
//                 : controller.quantityMoreReturnHandle(
//                     productCart, processedValue, invoice, quantityTextC);
//           } else {
//             controller.isComa.value = true;
//           }
//         });
//   }
// }

//* 1.2 discountTextfield ==================================================================
// class DiscountTextfield extends StatelessWidget {
//   const DiscountTextfield({
//     super.key,
//     required this.invoice,
//     required this.discountTextC,
//     // required this.controller,
//     required this.productCart,
//   });

//   final Invoice invoice;
//   final TextEditingController discountTextC;
//   // final InvoiceController controller;
//   final CartItem productCart;

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: discountTextC,
//       textAlign: TextAlign.center,
//       decoration: InputDecoration(
//         labelText: 'Discount',
//         labelStyle:
//             context.textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic),
//         prefixText: 'Rp',
//         counterText: '',
//         filled: true,
//         fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
//         contentPadding: const EdgeInsets.all(10),
//         border: const OutlineInputBorder(borderSide: BorderSide.none),
//         isDense: true,
//       ),
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
//       onChanged: (value) {
//         double valueint =
//             value == '' ? 0 : double.parse(value.replaceAll('.', ''));
//         String newValue = currency.format(valueint);
//         productCart.individualDiscount.value = valueint;
//         if (newValue != discountTextC.text) {
//           discountTextC.value = TextEditingValue(
//             text: newValue,
//             selection: TextSelection.collapsed(offset: newValue.length),
//           );
//         }
//         invoice.updateIsDebtPaid();
//       },
//     );
//   }
// }
