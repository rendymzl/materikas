import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../config.dart';
import '../../presentation/screens.dart';
import 'bindings/controllers/controllers_bindings.dart';
import 'routes.dart';

class EnvironmentsBadge extends StatelessWidget {
  final Widget child;
  EnvironmentsBadge({required this.child});
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
      page: () => const HomeScreen(),
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
      page: () => const SalesScreen(),
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
  ];
}
