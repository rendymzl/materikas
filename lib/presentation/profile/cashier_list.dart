import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/user_model.dart';
import 'controllers/profile.controller.dart';

class CashierListWidget extends StatelessWidget {
  const CashierListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Daftar Kasir',
            style: context.textTheme.titleLarge,
          ),
          Divider(color: Colors.grey[200]),
          Obx(
            () {
              return controller.account.value!.users.isEmpty
                  ? const Text('Tidak ada kasir')
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.account.value!.users.length,
                        itemBuilder: (context, index) {
                          var cashier = controller.account.value!.users[index];
                          return ListTile(
                            leading: Text((index + 1).toString()),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: Text(cashier.name)),
                                Column(
                                  children: [
                                    CheckBoxWidget(
                                      title: 'Menu Invoice',
                                      cashier: cashier,
                                      accessName: 'invoiceMenu',
                                    ),
                                    CheckBoxWidget(
                                      title: 'Edit Invoice',
                                      cashier: cashier,
                                      accessName: 'editInvoice',
                                    ),
                                    CheckBoxWidget(
                                      title: 'Return Invoice',
                                      cashier: cashier,
                                      accessName: 'returnInvoice',
                                    ),
                                    CheckBoxWidget(
                                      title: 'Pembayaran Invoice',
                                      cashier: cashier,
                                      accessName: 'paymentInvoice',
                                    ),
                                    CheckBoxWidget(
                                      title: 'Hapus Invoice',
                                      cashier: cashier,
                                      accessName: 'destroyInvoice',
                                    ),
                                  ],
                                ),
                                CheckBoxWidget(
                                  title: 'Menu Pelanggan',
                                  cashier: cashier,
                                  accessName: 'customerMenu',
                                ),
                                CheckBoxWidget(
                                  title: 'Menu Barang',
                                  cashier: cashier,
                                  accessName: 'productMenu',
                                ),
                                CheckBoxWidget(
                                  title: 'Menu Sales',
                                  cashier: cashier,
                                  accessName: 'salesMenu',
                                ),
                                CheckBoxWidget(
                                  title: 'Menu Laporan',
                                  cashier: cashier,
                                  accessName: 'statisticMenu',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  controller.removeCashier(cashier),
                              icon: const Icon(
                                Symbols.delete,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    );
            },
          )
        ],
      ),
    );
  }
}

class CheckBoxWidget extends StatelessWidget {
  const CheckBoxWidget({
    super.key,
    required this.title,
    required this.cashier,
    required this.accessName,
  });

  final String title;
  final Cashier cashier;
  final String accessName;

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Obx(
      () => InkWell(
        onTap: () => controller.checkBoxHandle(cashier, accessName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Checkbox(
                value: cashier.accessList.contains(accessName),
                onChanged: (_) =>
                    controller.checkBoxHandle(cashier, accessName),
              ),
              Text(
                title,
                style: cashier.accessList.contains(accessName)
                    ? context.textTheme.bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.primary)
                    : context.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
