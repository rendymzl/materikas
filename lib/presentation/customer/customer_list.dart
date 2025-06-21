import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:materikas/infrastructure/utils/display_format.dart';

import '../../infrastructure/models/customer_model.dart';
import 'controllers/customer.controller.dart';
import 'detail_customer/detail_customer.dart';

class CustomerList extends StatelessWidget {
  const CustomerList({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            // margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            // height: 50,
            child: TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
                labelText: "Cari Pelanggan",
                labelStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Symbols.search),
              ),
              onChanged: (value) => controller.filterCustomers(value),
            ),
          ),
          const TableHeader(), //* TableHeader
          Divider(color: Colors.grey[500]),
          Expanded(
            child: Obx(
              () => ListView.separated(
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[300]),
                itemCount: controller.foundCustomers.length,
                itemBuilder: (BuildContext context, int index) {
                  final foundCustomer = controller.foundCustomers[index];
                  return TableContent(
                      foundCustomer: foundCustomer); //* TableContent
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableHeader extends StatelessWidget {
  const TableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          'ID',
          style: context.textTheme.headlineSmall,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 8,
            child: SizedBox(
              child: Text(
                'Nama Pelanggan',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              child: Text(
                'No. Telp',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: SizedBox(
              child: Text(
                'Alamat',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Deposit',
                style: context.textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableContent extends StatelessWidget {
  const TableContent({super.key, required this.foundCustomer});

  final CustomerModel foundCustomer;

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();
    return ListTile(
      leading: SizedBox(
        width: 50,
        child: Text(
          foundCustomer.customerId!,
          style: context.textTheme
              .bodyMedium, // Gunakan bodyMedium untuk ukuran teks yang lebih besar
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.only(right: 30),
              child: Text(
                foundCustomer.name,
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: SizedBox(
              child: Text(
                foundCustomer.phone ?? '-', // Tampilkan '-' jika phone kosong
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: SizedBox(
              child: Text(
                foundCustomer.address ??
                    '-', // Tampilkan '-' jika address kosong
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: foundCustomer.deposit != null
                      ? Colors.green[400]
                      : Colors
                          .grey[300], // Gunakan warna abu-abu jika deposit null
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  foundCustomer.deposit != null
                      ? 'Rp.${currency.format(foundCustomer.deposit)}'
                      : '-',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: foundCustomer.deposit != null
                        ? Colors.white
                        : Colors.black, // Gunakan warna hitam jika deposit null
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      onTap: () => controller.editCustomer.value
          ? detailCustomer(foundCustomer: foundCustomer)
          : null,
    );
  }
}
