import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../../infrastructure/models/purchase_order_model.dart';
import '../../../infrastructure/models/sales_model.dart';
import '../../global_widget/date_picker_widget/date_picker_widget.dart';
import '../buy_product_widget/buy_product_controller.dart';
import '../buy_product_widget/cart_sales_widget.dart';
import '../controllers/sales.controller.dart';
import 'calculate_sales.dart';

class SelectedProductSales extends StatelessWidget {
  const SelectedProductSales({super.key, this.po = false, this.purchaseOrder});

  final bool po;
  final PurchaseOrderModel? purchaseOrder;

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Obx(
        () {
          if (purchaseOrder != null) {
            print(purchaseOrder!.purchaseList.value.toJson());
            controller.cart.value = purchaseOrder!.purchaseList.value;
          }
          final cart = controller.cart.value;
          final cartItems = controller.cart.value.items;
          return ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: HeaderSelectedProductSales(po: po),
                  ),
                  Divider(color: Colors.grey[100]),
                  cartItems.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          controller: controller.scrollController,
                          itemCount: cartItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = cartItems[index];

                            return CartSalesWidget(
                                item: item, index: index, cart: cart, po: po);
                          },
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Barang yang Anda klik akan ditampilkan di sini.',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey),
                          ),
                        ),
                ],
              ),
              Divider(color: Colors.grey[100]),
              Obx(
                () {
                  return cartItems.isNotEmpty
                      ? SizedBox(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: CalculateSalesPrice(
                                    invoice: controller.invoice, po: po),
                              ),
                            ],
                          ),
                          // ),
                        )
                      : const SizedBox();
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class HeaderSelectedProductSales extends StatelessWidget {
  const HeaderSelectedProductSales({super.key, this.po = false});
  final bool po;

  @override
  Widget build(BuildContext context) {
    late BuyProductController controller = Get.find();
    late SalesController salesC = Get.find();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
          ),
          height: 50,
          child: TextField(
            decoration: InputDecoration(
              labelText: po ? "ID Purchase Order" : "ID Invoice",
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Symbols.numbers),
              border: InputBorder.none,
            ),
            onChanged: (value) => controller.nomorInvoice.value = value,
          ),
        ),
        const SizedBox(width: 8),
        //! dropdown menu sales
        if (po)
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            height: 50,
            child: Autocomplete<SalesModel>(
              initialValue: salesC.salesTextC.value,
              optionsBuilder: (TextEditingValue salesTextC) {
                return salesC.sales.where((SalesModel sales) {
                  final String customerName = sales.name?.toLowerCase() ?? '';
                  final String input = salesTextC.text.toLowerCase();
                  return customerName.contains(input);
                });
              },
              displayStringForOption: (SalesModel sales) => sales.name ?? '',
              fieldViewBuilder: (BuildContext context,
                  TextEditingController salesTextC,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return Obx(
                  () => TextField(
                    key: salesC.textFieldKey,
                    controller: salesTextC,
                    focusNode: focusNode,
                    onChanged: (value) {
                      salesC.showSuffixClear.value = value != '';
                      debugPrint((value != '').toString());
                    },
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                    decoration: InputDecoration(
                      labelText: "Cari Sales",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Symbols.search),
                      suffixIconColor: Colors.red,
                      suffixIcon: salesC.showSuffixClear.value
                          ? IconButton(
                              onPressed: () {
                                salesTextC.text = '';
                                salesC.clear();
                              },
                              icon: const Icon(Symbols.close))
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<SalesModel> onSelected,
                  Iterable<SalesModel> options) {
                final int optionsLength = options.length;
                final RenderBox renderBox = salesC.textFieldKey.currentContext
                    ?.findRenderObject() as RenderBox;
                final double textFieldWidth = renderBox.size.width;

                return Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    width: textFieldWidth,
                    child: Card(
                      color: Colors.grey[100],
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: optionsLength,
                        itemBuilder: (BuildContext context, int index) {
                          final SalesModel option = options.elementAt(index);
                          return ListTile(
                            // hoverColor: Colors.white,
                            title: Text(option.name ?? ''),
                            onTap: () {
                              onSelected(option);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (SalesModel sales) {
                salesC.selectedSalesHandle(sales);
                salesC.showSuffixClear.value = true;
              },
            ),
          ),
        //! ===
        const SizedBox(width: 8),
        const DatePickerWidget(),
      ],
    );
  }
}
