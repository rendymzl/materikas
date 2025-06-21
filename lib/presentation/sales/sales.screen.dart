import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../infrastructure/utils/display_format.dart';
import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/sales.controller.dart';
import 'layout/sales_horizontal_layout.dart';
import 'layout/sales_vertical_layout.dart';

class SalesScreen extends GetView<SalesController> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: vertical ? Colors.white : null,
        appBar: _buildAppBar(context),
        drawer: vertical ? buildDrawer(context) : null,
        body: Column(
          children: [
            if (!vertical) const MenuWidget(title: 'Sales'),
            Expanded(
              child: vertical
                  ? SalesVerticalLayout(controller: controller)
                  : SalesHorizontalLayout(controller: controller),
            ),
          ],
        ),
      ),
    );
  }

  AppBar? _buildAppBar(BuildContext context) {
    if (!vertical) return null;

    return AppBar(
      title: const Text("Supplier"),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState!.openDrawer(),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
    );
  }
}
