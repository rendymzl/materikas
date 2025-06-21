import 'package:get/get.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/database/sync_status.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/internet_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/dal/services/purchase_order_service.dart';
import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';

import 'handle_setup_widget.dart';

class SplashController extends GetxController {
  final syncController = Get.put(SyncAppBar());
  final internetService = Get.put(InternetService());
  final storeService = Get.put(StoreService());
  final accountService = Get.put(AccountService());
  final productService = Get.put(ProductService());
  final invoiceService = Get.put(InvoiceService());
  final customerService = Get.put(CustomerService());
  final salesService = Get.put(SalesService());
  final invoiceSalesService = Get.put(InvoiceSalesService());
  final operatingCostService = Get.put(OperatingCostService());
  final purchaseOrderService = Get.put(PurchaseOrderService());
  final authService = Get.put(AuthService());

  final isLoading = false.obs;

  Future<void> init() async {
    isLoading(true);
    // await logout();
    if (await authService.isLoggedIn()) {
      await _handleSync();

      final account = await accountService.get();
      authService.account(account);
      authService.store(await storeService.getStore(account.storeId!));
      authService.getCashier();
      if (account.accountType != 'setup') {
        await _subscribeToServices();

        await _waitForServicesToBeReady();

        isLoading(false);
        Get.offAllNamed(Routes.SELECT_USER);
      } else {
        await handleSetup();
      }
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _handleSync() async {
    int tryingCount = 0;
    await Future.doWhile(() async {
      print('percobaan ke-$tryingCount');
      print('Menghubungkan...');
      await Future.delayed(const Duration(milliseconds: 500));
      tryingCount++;
      return !syncController.hasSynced.value;
    });
  }

  Future<void> _subscribeToServices() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await Future.wait([
      productService.subscribe(),
      invoiceService.subscribe(),
      customerService.subscribe(),
      salesService.subscribe(),
      invoiceSalesService.subscribe(),
      operatingCostService.subscribe(),
      purchaseOrderService.subscribe(),
    ]);
  }

  Future<void> _waitForServicesToBeReady() async {
    var tryCount = 0;
    await Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      print('_waitForServicesToBeReady $tryCount');
      tryCount++;
      return !productService.isReady.value || !invoiceService.isReady.value;
    });
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> signOut() async {
    if (internetService.isConnected.value) {
      await logout(); // Assumes logout function exists
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
