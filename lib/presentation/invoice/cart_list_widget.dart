import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/invoice_model/cart_item_model.dart';
import '../../infrastructure/models/invoice_model/cart_model.dart';
import '../../infrastructure/models/invoice_model/invoice_model.dart';
import '../../infrastructure/utils/display_format.dart';

import 'add_product_dialog.dart';
import 'detail_invoice/SingleReturnCartList.dart';
import 'edit_invoice/single_cart_list.dart';

class CardListWidget extends StatelessWidget {
  const CardListWidget(
      {super.key, required this.editInvoice, this.isReturnPage = false});

  final InvoiceModel editInvoice;
  final bool isReturnPage;

  @override
  Widget build(BuildContext context) {
    if (editInvoice.returnList.value != null) {
      editInvoice.returnList.value = Cart(items: <CartItem>[].obs);
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Return',
                    style: Theme.of(Get.context!).textTheme.titleLarge,
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 12),
                  SingleCartList(
                    editInvoice: editInvoice,
                    cartItemList: editInvoice.purchaseList.value,
                    isReturn: true,
                  ),
                  const SizedBox(height: 12),
                  if (isReturnPage)
                    Obx(
                      () {
                        return editInvoice.returnList.value!.items.isNotEmpty
                            ? Column(
                                children: [
                                  Divider(color: Colors.grey[200]),
                                  Text(
                                    'Return Tambahan',
                                    style: Theme.of(Get.context!)
                                        .textTheme
                                        .titleLarge,
                                    textAlign: TextAlign.end,
                                  ),
                                  const SizedBox(height: 12),
                                  SingleReturnCartList(
                                    editInvoice: editInvoice,
                                    cartItemList: editInvoice.returnList.value!,
                                    isReturn: true,
                                  ),
                                ],
                              )
                            : const SizedBox();
                      },
                    )
                  // const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                child: Column(
                  children: [
                    Text(
                      'Pembelian',
                      style: Theme.of(Get.context!).textTheme.titleLarge,
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 12),
                    SingleCartList(
                      editInvoice: editInvoice,
                      cartItemList: editInvoice.purchaseList.value,
                    ),
                    const SizedBox(height: 12),
                    // if (isReturnPage)
                    //   SingleCartList(
                    //     editInvoice: editInvoice,
                    //     cartItemList: editInvoice.returnList.value!,
                    //   ),
                    // const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ReturnFeeWidget(editInvoice: editInvoice),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    editInvoice.purchaseList.value.bundleDiscount.value > 0
                        ? ListTile(
                            title: Text(
                              'Diskon Tambahan: Rp-${currency.format(editInvoice.purchaseList.value.bundleDiscount.value)}',
                              textAlign: TextAlign.right,
                            ),
                          )
                        : const SizedBox(),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Expanded(child: SizedBox()),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => addProductDialog(
                                isReturnPage
                                    ? editInvoice.returnList.value!
                                    : editInvoice.purchaseList.value,
                                isReturnPage: isReturnPage,
                              ),
                              child: const Text(
                                'Tambah Barang',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class ReturnFeeWidget extends StatelessWidget {
  const ReturnFeeWidget({
    super.key,
    required this.editInvoice,
  });

  final InvoiceModel editInvoice;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Obx(
            () {
              final returnFeeTextC = TextEditingController();
              returnFeeTextC.text = editInvoice.returnFee.value == 0
                  ? '-'
                  : currency.format(editInvoice.returnFee.value);
              returnFeeTextC.selection = TextSelection.fromPosition(
                TextPosition(offset: returnFeeTextC.text.length),
              );
              return Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: TextField(
                      controller: returnFeeTextC,
                      textAlign: TextAlign.right,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: 'Biaya Return',
                        labelStyle: Get.context!.textTheme.bodySmall!
                            .copyWith(fontStyle: FontStyle.italic),
                        prefixText: 'Rp',
                        counterText: '',
                        filled: true,
                        fillColor: Theme.of(Get.context!)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        contentPadding: const EdgeInsets.all(10),
                        border: const OutlineInputBorder(
                            borderSide: BorderSide.none),
                        isDense: true,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (value) {
                        editInvoice.returnFee.value = value == ''
                            ? 0
                            : double.parse(value.replaceAll('.', ''));

                        editInvoice.updateReturn();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  'TOTAL RETURN',
                  textAlign: TextAlign.right,
                  style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(Get.context!).colorScheme.primary),
                ),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    'Rp${currency.format(editInvoice.totalReturnFinal)}',
                    textAlign: TextAlign.end,
                    style: Theme.of(Get.context!).textTheme.bodyLarge!.copyWith(
                          color: Theme.of(Get.context!).colorScheme.primary,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
