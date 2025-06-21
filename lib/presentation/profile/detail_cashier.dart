import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/account_model.dart';
import '../../infrastructure/models/user_model.dart';
import '../global_widget/popup_page_widget.dart';
import 'controllers/profile.controller.dart';

void detailCashier(
  Cashier cashier,
  AccountModel editAccount,
  Cashier initCashier,
) {
  final ProfileController controller = Get.find();

  showPopupPageWidget(
      title: '${cashier.name} akses:',
      iconButton: IconButton(
        onPressed: () => controller.removeCashier(editAccount, cashier),
        icon: const Icon(
          Symbols.delete,
          color: Colors.red,
        ),
      ),
      height: MediaQuery.of(Get.context!).size.height * (0.65),
      width: MediaQuery.of(Get.context!).size.width * (0.9),
      content: Expanded(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Divider(color: Colors.grey[200]),
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
                Divider(color: Colors.grey[200]),
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
                Divider(color: Colors.grey[200]),
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
                Divider(color: Colors.grey[200]),
                Divider(color: Colors.grey[200]),
              ],
            ),
          ],
        ),
      ),
      buttonList: [
        Obx(() {
          Function deepEq = const DeepCollectionEquality().equals;
          bool equal = deepEq(cashier.accessList, initCashier.accessList);
          if (!equal) {
            return ElevatedButton(
              onPressed: () => controller.saveAccess(editAccount),
              child: const Text('Simpan Perubahan'),
            );
          }
          return const SizedBox.shrink();
        }),
      ]);
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
