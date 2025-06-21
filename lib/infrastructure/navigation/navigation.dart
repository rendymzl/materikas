import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../modules/home/views/payment_view.dart';
import '../../modules/home/views/topup_view.dart';
import '../../presentation/invoice/views/invoice_detail_view.dart';
import '../../presentation/invoice/views/invoice_edit_view.dart';
import '../../presentation/invoice/views/invoice_print_view.dart';
import '../../presentation/invoice/views/invoice_return_view.dart';
import '../../presentation/sales/views/buy_product_view.dart';
import '../../presentation/sales/views/detail_invoice_sales_view.dart';
import '../../presentation/sales/views/edit_invoice_sales_view.dart';
import '../../presentation/sales/views/invoice_sales_list_view.dart';
import '../../presentation/sales/views/payment_sales_invoice_view.dart';
import '../../presentation/sales/views/product_sales_list_view.dart';
// import '../../presentation/sales/views/purchase_order_view.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  const EnvironmentsBadge({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    var env = ConfigEnvironments.getEnvironments()['env'];
    return env != Environments.PRODUCTION
        ? Banner(
            location: BannerLocation.topStart,
            message: env!,
            color: env == Environments.QAS ? Colors.blue : Colors.purple,
            child: child,
          )
        : SizedBox(child: child);
  }
}

class Nav {
  static List<GetPage> routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      binding: HomeControllerBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashScreen(),
      binding: SplashControllerBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginControllerBinding(),
    ),
    GetPage(
      name: Routes.INVOICE,
      page: () => const InvoiceScreen(),
      binding: InvoiceControllerBinding(),
    ),
    GetPage(
      name: Routes.CUSTOMER,
      page: () => const CustomerScreen(),
      binding: CustomerControllerBinding(),
    ),
    GetPage(
      name: Routes.PRODUCT,
      page: () => const ProductScreen(),
      binding: ProductControllerBinding(),
    ),
    GetPage(
      name: Routes.SALES,
      page: () => SalesScreen(),
      binding: SalesControllerBinding(),
    ),
    GetPage(
      name: Routes.STATISTIC,
      page: () => const StatisticScreen(),
      binding: StatisticControllerBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileControllerBinding(),
    ),
    GetPage(
      name: Routes.SELECT_USER,
      page: () => const SelectUserScreen(),
      binding: SelectUserControllerBinding(),
    ),
    GetPage(
      name: Routes.OPERATING_COST,
      page: () => const OperatingCostScreen(),
      binding: OperatingCostControllerBinding(),
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => const SignupScreen(),
      binding: SignupControllerBinding(),
    ),
    GetPage(
      name: Routes.SETUP,
      page: () => const SetupScreen(),
      binding: SetupControllerBinding(),
    ),
    GetPage(
      name: Routes.TEST,
      page: () => const TestScreen(),
      binding: TestControllerBinding(),
    ),
    GetPage(
        name: Routes.PAYMENT_LIST_VIEW,
        page: () => const PaymentView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_DETAIL,
        page: () => const InvoiceDetailView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_RETURN,
        page: () => const InvoiceReturnView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_EDIT,
        page: () => const InvoiceEditView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_PRINT,
        page: () => const InvoicePrintView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_SALES_LIST,
        page: () => const InvoiceSalesListView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    // GetPage(
    //     name: Routes.INVOICE_PURCHASE_ORDER,
    //     page: () => const PurchaseOrderView(),
    //     transition: Transition.cupertino,
    //     curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_PRODUCT_LIST,
        page: () => const ProductSalesListView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    GetPage(
        name: Routes.INVOICE_BUY_PRODUCT,
        page: () => const BuyProductView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.PAYMENT_SALES_INVOICE,
        page: () => const PaymentSalesInvoiceView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    GetPage(
        name: Routes.DETAIL_INVOICE_SALES,
        page: () => const DetailInvoiceSalesView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    GetPage(
        name: Routes.EDIT_INVOICE_SALES,
        page: () => const EditInvoiceSalesView(),
        transition: Transition.cupertino,
        curve: Easing.linear),
    GetPage(
        name: Routes.TOPUP,
        page: () => const TopupView(),
        transition: Transition.native,
        curve: Easing.linear),
    GetPage(
        name: Routes.GRAPH,
        page: () => const GraphScreen(),
        binding: GraphControllerBinding(),
        transition: Transition.cupertino,
        curve: Easing.linear),
  ];
}
