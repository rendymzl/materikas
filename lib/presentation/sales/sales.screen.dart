import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/sales.controller.dart';

class SalesScreen extends GetView<SalesController> {
  const SalesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SalesScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'SalesScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
