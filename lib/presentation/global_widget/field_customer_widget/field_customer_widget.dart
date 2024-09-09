import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/customer_model.dart';
import 'field_customer_widget_controller.dart';

class CustomerInputField extends StatelessWidget {
  const CustomerInputField({super.key});

  @override
  Widget build(BuildContext context) {
    late CustomerInputFieldController controller =
        Get.put(CustomerInputFieldController());
    OutlineInputBorder outlineRed =
        const OutlineInputBorder(borderSide: BorderSide(color: Colors.red));
    final GlobalKey textFieldKey = GlobalKey();
    return Container(
      height: 250,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: Autocomplete<CustomerModel>(
              initialValue: controller.customerNameController.value,
              optionsBuilder: (TextEditingValue customerTextC) {
                if (customerTextC.text.isEmpty) {
                  return controller.customers;
                } else {
                  return controller.customers.where((CustomerModel customer) {
                    final String customerName = customer.name.toLowerCase();
                    final String input = customerTextC.text.toLowerCase();
                    return customerName.contains(input);
                  });
                }
              },
              displayStringForOption: (CustomerModel customer) => customer.name,
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return Obx(
                  () => TextField(
                    key: textFieldKey,
                    controller: textEditingController,
                    focusNode: focusNode,
                    onChanged: (value) {
                      controller.showSuffixClear.value = value != '';
                    },
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                    decoration: InputDecoration(
                      labelText: "Cari Pelanggan",
                      labelStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Symbols.search),
                      suffixIconColor: Colors.red,
                      suffixIcon: controller.showSuffixClear.value
                          ? IconButton(
                              onPressed: () {
                                textEditingController.text = '';
                                controller.showSuffixClear.value = false;
                                controller.clear();
                              },
                              icon: const Icon(Symbols.close))
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<CustomerModel> onSelected,
                  Iterable<CustomerModel> options) {
                final int optionsLength = options.length;
                final RenderBox renderBox = textFieldKey.currentContext
                    ?.findRenderObject() as RenderBox;
                final double textFieldWidth = renderBox.size.width;

                return Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(),
                    width: textFieldWidth,
                    child: Card(
                      color: Colors.grey[100],
                      shadowColor: Colors.grey[300],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: optionsLength,
                        itemBuilder: (BuildContext context, int index) {
                          final CustomerModel option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.name),
                            onTap: () {
                              onSelected(option);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
              onSelected: (CustomerModel customer) {
                controller.asignCustomer(customer);
              },
            ),
          ),
          Divider(color: Colors.grey[200]),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                      controller: controller.customerNameController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Nama Pelanggan',
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        focusedErrorBorder: outlineRed,
                        errorBorder: outlineRed,
                      ),
                      onChanged: (value) {
                        controller.customerNameController.text = value;
                        controller.displayName.value = value;
                        controller.updateSelectedCustomer(
                          controller.selectedCustomer.value!,
                        );
                      }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextField(
                      controller: controller.customerPhoneController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'No. Telp',
                        labelStyle: const TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary),
                        focusedErrorBorder: outlineRed,
                        errorBorder: outlineRed,
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                      ],
                      onChanged: (value) {
                        controller.customerPhoneController.text = value;
                        controller.updateSelectedCustomer(
                          controller.selectedCustomer.value!,
                        );
                      }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller.customerAddressController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Alamat',
                alignLabelWithHint: true,
                labelStyle: const TextStyle(color: Colors.grey),
                floatingLabelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
                focusedErrorBorder: outlineRed,
                errorBorder: outlineRed,
              ),
              onChanged: (value) {
                controller.customerAddressController.text = value;
                controller.updateSelectedCustomer(
                  controller.selectedCustomer.value!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
