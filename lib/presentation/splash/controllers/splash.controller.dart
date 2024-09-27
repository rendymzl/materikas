import 'package:get/get.dart';

import '../../../infrastructure/dal/database/powersync.dart';
import '../../../infrastructure/dal/services/account_service.dart';
import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/dal/services/customer_service.dart';
import '../../../infrastructure/dal/services/invoice_sales_service.dart';
import '../../../infrastructure/dal/services/invoice_service.dart';
import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/dal/services/product_service.dart';
import '../../../infrastructure/dal/services/sales_service.dart';
import '../../../infrastructure/dal/services/store_service.dart';
import '../../../infrastructure/models/account_model.dart';
import '../../../infrastructure/models/store_model.dart';
import '../../../infrastructure/navigation/routes.dart';
import '../../global_widget/app_dialog_widget.dart';

class SplashController extends GetxController {
  final AuthService authService = Get.put(AuthService());
  final ProductService _productService = Get.put(ProductService());
  final InvoiceService _invoiceService = Get.put(InvoiceService());
  final CustomerService _customerService = Get.put(CustomerService());
  final SalesService _salesService = Get.put(SalesService());
  final InvoiceSalesService _invoiceSalesService =
      Get.put(InvoiceSalesService());
  final OperatingCostService _operatingCostService =
      Get.put(OperatingCostService());

  late final AccountModel? account;
  late final StoreModel? store;

  late final isConnected = false.obs;
  late final loadingStatus = authService.loadingStatus;

  void init() async {
    isConnected.value = authService.connected.value;
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn) {
      await authService.getAccount();
      authService.loadingStatus.value = 'menghubungkan toko';
      await authService.getStore();
      authService.loadingStatus.value = 'mengambil data toko';
      await authService.getCashier();
      Get.put(StoreService());
      Get.put(AccountService());
      print('SelectUserController INIT');

      print('SelectUserController getAccount');
      account = authService.account.value;

      // store = await _storeService.getStore(account!.storeId!);
      await _invoiceService.subscribe(account!.storeId!);
      await _productService.subscribe(account!.storeId!);
      await _customerService.subscribe(account!.storeId!);
      await _salesService.subscribe(account!.storeId!);
      await _invoiceSalesService.subscribe(account!.storeId!);
      await _operatingCostService.subscribe(account!.storeId!);
      print('SelectUserController FINISH INIT');
      authService.loadingStatus.value = 'selesai';
      Get.offAllNamed(Routes.SELECT_USER);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> signOut() async {
    // try {
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

  Future<void> checkStats() async {
    authService.checkStats();
  }
}
