import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/models/customer_model.dart';
import '../../infrastructure/utils/display_format.dart';
import 'controllers/customer.controller.dart';
import 'detail_customer/detail_customer.dart';

class CustomerListMobile extends StatelessWidget {
  const CustomerListMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: "Cari Pelanggan",
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => controller.filterCustomers(value),
        ),
        Divider(color: Colors.grey[300]),
        Expanded(
          child: Obx(
            () => ListView.separated(
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[300]),
              itemCount: controller.foundCustomers.length,
              itemBuilder: (BuildContext context, int index) {
                final foundCustomer = controller.foundCustomers[index];
                return CustomerTile(foundCustomer: foundCustomer);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.foundCustomer});

  final CustomerModel foundCustomer;

  @override
  Widget build(BuildContext context) {
    final CustomerController controller = Get.find();
    return ListTile(
      leading: CircleAvatar(
        child: Text(foundCustomer.name.toUpperCase().substring(0, 2)),
      ),
      title: Text(
        foundCustomer.name,
        style: context.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Telp: ${foundCustomer.phone ?? ''}',
            style: context.textTheme.bodySmall,
          ),
          Text(
            'Alamat: ${foundCustomer.address ?? ''}',
            style: context.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: foundCustomer.deposit != null
                  ? Colors.green[400]
                  : Colors.grey[300], // Gunakan warna abu-abu jika deposit null
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
        ],
      ),
      onTap: () => controller.editCustomer.value
          ? detailCustomer(foundCustomer: foundCustomer)
          : null,
    );
  }
}
