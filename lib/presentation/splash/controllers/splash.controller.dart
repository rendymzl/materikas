import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/database/sync_status.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/billing_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/dal/services/purchase_order_service.dart';
import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';
import '../../global_widget/popup_page_widget.dart';
import '../../profile/controllers/profile.controller.dart';
import '../../profile/detail_profile_store.dart';
import '../../profile/detail_store.controller.dart';
import '../../profile/profile_store_widget.dart';

class SplashController extends GetxController {
  final SyncAppBar syncController = Get.put(SyncAppBar());
  final AuthService authService = Get.put(AuthService());
  final ProductService _productService = Get.put(ProductService());
  final InvoiceService _invoiceService = Get.put(InvoiceService());
  final CustomerService _customerService = Get.put(CustomerService());
  final SalesService _salesService = Get.put(SalesService());
  final InvoiceSalesService _invoiceSalesService =
      Get.put(InvoiceSalesService());
  final OperatingCostService _operatingCostService =
      Get.put(OperatingCostService());
  final PurchaseOrderService _purchaseOrderService =
      Get.put(PurchaseOrderService());

  late final AccountModel? account;

  late final isConnected = false.obs;

  void init() async {
    final isLoggedIn = await authService.isLoggedIn();
    isConnected.value = authService.connected.value;
    // await signOut();

    if (isLoggedIn) {
      Get.put(StoreService());
      await Future.delayed(const Duration(seconds: 2));
      await authService.getAccount();

      await authService.getStore();
      authService.getCashier();
      final accountService = Get.put(AccountService());

      account = authService.account.value;
      if (account!.accountType != 'setup') {
        await _invoiceService.subscribe(account!.storeId!);
        await _productService.subscribe(account!.storeId!);
        await _customerService.subscribe(account!.storeId!);
        await _salesService.subscribe(account!.storeId!);
        await _invoiceSalesService.subscribe(account!.storeId!);
        await _operatingCostService.subscribe(account!.storeId!);
        await _purchaseOrderService.subscribe(account!.storeId!);
        isConnected.value = authService.connected.value;

        Get.put(BillingService());
        Get.offAllNamed(Routes.SELECT_USER);
      } else {
        Get.put(DetailStoreController());
        final profileC = Get.put(ProfileController());
        await detailStore(foundStore: authService.store.value, setup: true);
        await showPopupPageWidget(
          title: 'Pasang PIN',
          content: const ChangePinWidget(setup: true),
          buttonList: [
            // Expanded(
            //   child: OutlinedButton(
            //     onPressed: () => Get.back(),
            //     child: const Text('Batal'),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => profileC.changePinHandle(),
                child: const Text('Simpan'),
              ),
            ),
          ],
          barrierDismissible: true,
        );

        // print(authService.account.value!.toJson());
        AccountModel updatedAccount =
            AccountModel.fromJson(authService.account.value!.toJson());

        updatedAccount.endDate = DateTime.now();
        updatedAccount.updatedAt = DateTime.now().toLocal();
        updatedAccount.accountType = 'flexible';
        await accountService.update(updatedAccount);

        Get.offAllNamed(Routes.SPLASH);
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> signOut() async {
    if (isConnected.value) {
      await logout();
      Get.offNamed(Routes.LOGIN);
    } else {
      AppDialog.show(
        title: 'Error',
        content: 'Tidak ada koneksi internet untuk mengeluarkan akun.',
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
    }
  }
}
