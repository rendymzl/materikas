import 'package:material_symbols_icons/symbols.dart';

import '../../../infrastructure/models/menu_model.dart';

class MenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Symbols.add_notes, label: 'Transaksi'),
    MenuModel(icon: Symbols.clinical_notes, label: 'Invoice'),
    MenuModel(icon: Symbols.groups, label: 'Pelanggan'),
    MenuModel(icon: Symbols.handyman, label: 'Barang'),
    MenuModel(icon: Symbols.people, label: 'sales'),
    MenuModel(icon: Symbols.monitoring, label: 'Laporan'),
    MenuModel(icon: Symbols.store, label: 'Toko'),
  ];
}
