import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/menu_model.dart';

class MenuData {
  final menu = <MenuModel>[
    const MenuModel(icon: Symbols.add_notes, label: 'Transaksi'),
    if (Get.find<AuthService>().selectedUser.value.isNotEmpty) ...[
      if (Get.find<AuthService>().isOwner.value ||
          Get.find<AuthService>()
              .account
              .value!
              .users
              .firstWhere((user) =>
                  user.name == Get.find<AuthService>().selectedUser.value)
              .accessList
              .contains('invoiceMenu')) ...[
        const MenuModel(icon: Symbols.clinical_notes, label: 'Invoice'),
      ],
      if (Get.find<AuthService>().isOwner.value ||
          Get.find<AuthService>()
              .account
              .value!
              .users
              .firstWhere((user) =>
                  user.name == Get.find<AuthService>().selectedUser.value)
              .accessList
              .contains('customerMenu')) ...[
        const MenuModel(icon: Symbols.groups, label: 'Pelanggan'),
      ],
      if (Get.find<AuthService>().isOwner.value ||
          Get.find<AuthService>()
              .account
              .value!
              .users
              .firstWhere((user) =>
                  user.name == Get.find<AuthService>().selectedUser.value)
              .accessList
              .contains('productMenu')) ...[
        const MenuModel(icon: Symbols.handyman, label: 'Barang'),
      ],
      if (Get.find<AuthService>().isOwner.value ||
          Get.find<AuthService>()
              .account
              .value!
              .users
              .firstWhere((user) =>
                  user.name == Get.find<AuthService>().selectedUser.value)
              .accessList
              .contains('salesMenu')) ...[
        const MenuModel(icon: Symbols.people, label: 'sales'),
      ],
      if (Get.find<AuthService>().isOwner.value ||
          Get.find<AuthService>()
              .account
              .value!
              .users
              .firstWhere((user) =>
                  user.name == Get.find<AuthService>().selectedUser.value)
              .accessList
              .contains('statisticMenu')) ...[
        const MenuModel(icon: Symbols.monitoring, label: 'Laporan'),
      ],
      if (Get.find<AuthService>().isOwner.value) ...[
        const MenuModel(icon: Symbols.store, label: 'Toko'),
      ],
    ],
  ];
}
