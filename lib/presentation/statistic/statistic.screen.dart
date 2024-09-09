import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'controllers/statistic.controller.dart';

class StatisticScreen extends GetView<StatisticController> {
  const StatisticScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StatisticScreen'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'StatisticScreen is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
