import 'package:get/get.dart';

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

class SplashController extends GetxController {
  final AuthService _authService = Get.put(AuthService());
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

  void init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await _authService.getAccount();
      await _authService.getStore();
      await _authService.getCashier();
      Get.put(StoreService());
      Get.put(AccountService());
      print('SelectUserController INIT');
      isConnected.value = _authService.connected.value;
      print('SelectUserController getAccount');
      account = _authService.account.value;

      // store = await _storeService.getStore(account!.storeId!);
      await _invoiceService.subscribe(account!.storeId!);
      await _productService.subscribe(account!.storeId!);
      await _customerService.subscribe(account!.storeId!);
      await _salesService.subscribe(account!.storeId!);
      await _invoiceSalesService.subscribe(account!.storeId!);
      await _operatingCostService.subscribe(account!.storeId!);
      print('SelectUserController FINISH INIT');
      Get.offAllNamed(Routes.SELECT_USER);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
