import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/invoice.controller.dart';
import 'layout/invoice_horizontal_layout.dart';
import 'layout/invoice_vertical_layout.dart';

class InvoiceScreen extends GetView<InvoiceController> {
  const InvoiceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: vertical ? Colors.white : null,
          appBar: _buildAppBar(context),
          drawer: vertical ? buildDrawer(context) : null,
          body: Column(
            children: [
              if (!vertical) const MenuWidget(title: 'Invoice'),
              Expanded(
                child: vertical
                    ? InvoiceVerticalLayout(controller: controller)
                    : InvoiceHorizontalLayout(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar? _buildAppBar(BuildContext context) {
    if (!vertical) return null;

    return AppBar(
      title: const Text("Invoice"),
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        },
      ),
      actions: _buildAppBarActions(context),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () => controller.handleFilteredDate(context),
          icon: const Icon(Symbols.calendar_month))
    ];
  }
}
