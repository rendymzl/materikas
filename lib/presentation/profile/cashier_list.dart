import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/account_model.dart';
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
              AccountModel editAccount =
                  AccountModel.fromJson(controller.account.value!.toJson());
              return editAccount.users.isEmpty
                  ? const Text('Tidak ada kasir')
                  : Expanded(
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        shrinkWrap: true,
                        itemCount: editAccount.users.length,
                        itemBuilder: (context, index) {
                          var cashier = editAccount.users[index];
                          var initCashier = Cashier.fromJson(cashier.toJson());
                          return ListTile(
                            tileColor: Colors.grey[100],
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 20,
                                    child: Text((index + 1).toString())),
                                Expanded(
                                    child: Text(
                                        '${cashier.name}   |   Akses Aplikasi:',
                                        textAlign: TextAlign.center)),
                                IconButton(
                                  onPressed: () => controller.removeCashier(
                                      editAccount, cashier),
                                  icon: const Icon(
                                    Symbols.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckBoxWidget(
                                            title: 'Menu Invoice',
                                            cashier: cashier,
                                            accessName: 'Invoice',
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
                                            title: 'Pembayaran',
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
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckBoxWidget(
                                            title: 'Menu Pelanggan',
                                            cashier: cashier,
                                            accessName: 'Pelanggan',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Tambah Pelanggan',
                                            cashier: cashier,
                                            accessName: 'addCustomer',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Edit Pelanggan',
                                            cashier: cashier,
                                            accessName: 'editCustomer',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Hapus Pelanggan',
                                            cashier: cashier,
                                            accessName: 'destroyCustomer',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckBoxWidget(
                                            title: 'Menu Barang',
                                            cashier: cashier,
                                            accessName: 'Barang',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Edit Barang',
                                            cashier: cashier,
                                            accessName: 'editProduct',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Hapus Barang',
                                            cashier: cashier,
                                            accessName: 'destroyProduct',
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CheckBoxWidget(
                                            title: 'Menu Sales',
                                            cashier: cashier,
                                            accessName: 'Sales',
                                          ),
                                          CheckBoxWidget(
                                            title: 'Menu Operasional',
                                            cashier: cashier,
                                            accessName: 'Operasional',
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(width: 4),
                                    // Expanded(
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       CheckBoxWidget(
                                    //         title: 'Menu Laporan',
                                    //         cashier: cashier,
                                    //         accessName: 'Laporan',
                                    //       ),
                                    //       CheckBoxWidget(
                                    //         title: 'Biaya Operasional',
                                    //         cashier: cashier,
                                    //         accessName: 'addOperationalCost',
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                                Obx(() {
                                  Function deepEq =
                                      const DeepCollectionEquality().equals;
                                  bool equal = deepEq(cashier.accessList,
                                      initCashier.accessList);
                                  if (!equal) {
                                    return ElevatedButton(
                                      onPressed: () =>
                                          controller.saveAccess(editAccount),
                                      child: const Text('Simpan Perubahan'),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),
                              ],
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          margin: const EdgeInsets.all(4),
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
