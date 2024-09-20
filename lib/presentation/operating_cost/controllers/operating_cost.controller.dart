import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/operating_cost_model.dart';

class OperatingCostController extends GetxController {
  final OperatingCostService _operatingCostService = Get.find();
  late final operatingCosts = _operatingCostService.foundOperatingCost;

  final initDate = DateTime.now().obs;
  final selectedDate = DateTime.now().obs;
  final dailyRangeController = DateRangePickerController().obs;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;

  @override
  void onInit() async {
    rangePickerHandle(DateTime.now());
    everAll([selectedDate, operatingCosts],
        (_) => rangePickerHandle(selectedDate.value));
    super.onInit();
  }

  Future rangePickerHandle(DateTime pickedDate) async {
    selectedDate.value = pickedDate;
    var items = operatingCosts.where((cost) {
      return cost.createdAt!.day == selectedDate.value.day &&
          cost.createdAt!.month == selectedDate.value.month &&
          cost.createdAt!.year == selectedDate.value.year;
    }).toList();
    dailyOperatingCosts.assignAll(items);
  }

  void deleteOperatingCost(OperatingCostModel operatingCost) async {
    await _operatingCostService.delete(operatingCost.id!);
    await rangePickerHandle(selectedDate.value);
  }
}
