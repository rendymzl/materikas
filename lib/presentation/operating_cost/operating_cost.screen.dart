import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../global_widget/menu_widget/menu_widget.dart';
import 'controllers/operating_cost.controller.dart';

class OperatingCostScreen extends GetView<OperatingCostController> {
  const OperatingCostScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          MenuWidget(title: 'Operasional'),
          Center(
            child: Text(
              'OperatingCostScreen is working',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
