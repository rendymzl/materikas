import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/operating_cost_model.dart';

class OperatingCostController extends GetxController {
  final OperatingCostService _operatingCostService = Get.find();
  late final operatingCosts = _operatingCostService.operatingCosts;

  final initDate = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  final dailyRangeController = DateRangePickerController().obs;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;

  void rangePickerHandle(DateTime pickedDate) async {
    selectedDate.value = pickedDate;

    dailyOperatingCosts.value = operatingCosts.where((cost) {
      return cost.createdAt!.day == selectedDate.value.day &&
          cost.createdAt!.month == selectedDate.value.month &&
          cost.createdAt!.year == selectedDate.value.year;
    }).toList();
  }

  void deleteOperatingCost(OperatingCostModel operatingCost) async {
    await _operatingCostService.delete(operatingCost.id!);
    rangePickerHandle(DateTime.now());
  }
}
