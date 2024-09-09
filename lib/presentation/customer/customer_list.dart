import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/customer_model.dart';
import 'controllers/customer.controller.dart';
import 'detail_customer/detail_customer.dart';

class CustomerList extends StatelessWidget {
  const CustomerList({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            height: 50,
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
          style: context.textTheme.bodySmall,
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
                foundCustomer.phone ?? '',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: SizedBox(
              child: Text(
                foundCustomer.address ?? '',
                style: context.textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      trailing: controller.isAdmin
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                onPressed: () => controller.destroyHandle(foundCustomer),
                icon: const Icon(
                  Symbols.delete,
                  color: Colors.red,
                ),
              ),
            )
          : null,
      onTap: () => detailCustomer(foundCustomer: foundCustomer),
    );
  }
}
