import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/models/account_model.dart';
import '../../infrastructure/models/user_model.dart';
import 'controllers/profile.controller.dart';
import 'detail_cashier.dart';

class CashierListMobile extends StatelessWidget {
  const CashierListMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
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
                    : ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4),
                        shrinkWrap: true,
                        itemCount: editAccount.users.length,
                        itemBuilder: (context, index) {
                          var cashier = editAccount.users[index];
                          var initCashier = Cashier.fromJson(cashier.toJson());
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              onTap: () => detailCashier(
                                  cashier, editAccount, initCashier),
                              leading: Text((index + 1).toString()),
                              title: Text(cashier.name),
                              trailing: Icon(
                                Symbols.arrow_right,
                                color: Colors.red,
                              ),
                              //  IconButton(
                              //   onPressed: () {}
                              //    IconButton(
                              //     onPressed: () => controller.removeCashier(
                              //         editAccount, cashier)
                              //   ,
                              //   icon: const Icon(
                              //     Symbols.arrow_right,
                              //     color: Colors.red,
                              //   )
                              //   ,
                              // ),
                            ),
                          );
                        },
                      );
              },
            ),
          ],
        ),
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
            mainAxisSize: MainAxisSize.min,
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
