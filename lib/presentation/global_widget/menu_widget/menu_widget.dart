import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/menu_model.dart';
import '../../../infrastructure/utils/display_format.dart';
import '../activate_popup/activate_account_popup.dart';
import '../app_dialog_widget.dart';
import '../billing_widget/billing_dashboard.dart';
import 'menu_controller.dart';

class MenuWidget extends GetView<MenuWidgetController> {
  const MenuWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    bool trial = controller.account.value!.accountType == 'free_trial';
    bool almostExpired = false;
    bool isFlexibleFirstMonthNotPaid = false;
    if (controller.account.value!.endDate != null) {
      almostExpired = controller.account.value!.endDate!
          .isBefore(DateTime.now().add(const Duration(days: 5)));
    }
    if (controller.account.value!.accountType == 'flexible') {
      isFlexibleFirstMonthNotPaid =
          !controller.billingService.getIsLastMonthBillPaid();
    }
    return Container(
      // padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      height: 70 +
          (controller.authService.isOwner.value &&
                  (trial || almostExpired || isFlexibleFirstMonthNotPaid)
              ? 40
              : 0),
      child: Column(
        children: [
          if (controller.authService.isOwner.value)
            if (trial || almostExpired || isFlexibleFirstMonthNotPaid)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(8)),
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isFlexibleFirstMonthNotPaid
                          ? 'Tagihan bulan lalu sudah terbit, Lakukan pembayaran sebelum tanggal 10.'
                          : 'Akun anda akan berakhir pada ',
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (!isFlexibleFirstMonthNotPaid)
                      Text(
                        controller.account.value!.endDate != null
                            ? date.format(controller.account.value!.endDate!)
                            : '',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    if (!isFlexibleFirstMonthNotPaid)
                      const Text(
                        ' dan tersisa ',
                        style: TextStyle(color: Colors.white),
                      ),
                    if (!isFlexibleFirstMonthNotPaid) controller.countdown,
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: isFlexibleFirstMonthNotPaid
                          ? () async => billingDashboard()
                          : () async => activateAccountPopup(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFlexibleFirstMonthNotPaid
                              ? 'Bayar Tagihan'
                              : 'Perpanjang Akun',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    child: Obx(
                      () {
                        var data = controller.menuData;
                        Future.delayed(const Duration(seconds: 2), () {
                          controller.billingService.onInit();
                          // print(
                          //     'controller.expired ${controller.billingService.isExpired}');
                          if (controller.billingService.isExpired &&
                              controller
                                      .authService.account.value!.accountType ==
                                  'flexible') {
                            billingDashboard(
                                expired: controller.billingService.isExpired);
                          }
                          if (controller.subsExpired.value &&
                              controller
                                      .authService.account.value!.accountType ==
                                  'subscription') {
                            activateAccountPopup(
                                expired: controller.subsExpired.value);
                          }
                        });
                        return ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 8),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: (data.length),
                          itemBuilder: (context, index) =>
                              buildMenuEntry(data[index], index, context),
                        );
                      },
                    ),
                  ),
                ),
                Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: controller.authService.connected.value
                          ? Colors.green
                          : Colors.red,
                    ),
                    height: 12,
                    width: 12,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    AppDialog.show(
                      title: 'Keluar',
                      content: 'Ganti Pengguna?',
                      confirmText: "Ya",
                      cancelText: "Tidak",
                      confirmColor: Colors.grey,
                      cancelColor: Get.theme.primaryColor,
                      onConfirm: () => controller.changeUser(),
                      onCancel: () => Get.back(),
                    );
                    // controller.connected.value
                    //     ? AppDialog.show(
                    //         title: 'Keluar',
                    //         content: 'Keluar dari aplikasi?',
                    //         confirmText: "Ya",
                    //         cancelText: "Tidak",
                    //         confirmColor: Colors.grey,
                    //         cancelColor: Get.theme.primaryColor,
                    //         onConfirm: () => controller.signOut(),
                    //         onCancel: () => Get.back(),
                    //       )
                    //     : await Get.defaultDialog(
                    //         title: 'Error',
                    //         middleText:
                    //             'Tidak ada koneksi internet untuk mengeluarkan akun.',
                    //         confirm: TextButton(
                    //           onPressed: () {
                    //             Get.back();
                    //             Get.back();
                    //           },
                    //           child: const Text('OK'),
                    //         ),
                    //       );
                  },
                  icon: const Icon(Symbols.logout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuEntry(MenuModel data, int index, BuildContext context) {
    return Obx(
      () => ElevatedButton.icon(
        onPressed: () => controller.handleClick(index, data.label),
        icon: Icon(
          data.icon,
          color: controller.authService.selectedIndexMenu.value == index
              ? Colors.white
              : Colors.grey[700],
        ),
        label: Text(
          data.label,
          style: TextStyle(
            fontSize: 14,
            color: controller.authService.selectedIndexMenu.value == index
                ? Colors.white
                : Colors.grey[700],
            // fontWeight: controller.isExpand.value
            //     ? FontWeight.w600
            //     : FontWeight.normal,
          ),
        ),
        style: ButtonStyle(
          alignment: Alignment.centerLeft,
          enableFeedback: true,
          backgroundColor: WidgetStatePropertyAll(
            controller.authService.selectedIndexMenu.value == index
                ? Theme.of(context).colorScheme.primary
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
