import 'package:get/get.dart';
// import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../infrastructure/dal/services/operating_cost_service.dart';
import '../../../infrastructure/models/operating_cost_model.dart';
// import '../../../infrastructure/utils/display_format.dart';

class OperatingCostController extends GetxController {
  final OperatingCostService _operatingCostService = Get.find();

  final selectedDate = DateTime.now().obs;
  // final displayDate = 'Pilih Tanggal'.obs;
  late final dailyOperatingCosts = <OperatingCostModel>[].obs;

  @override
  void onInit() async {
    rangePickerHandle(DateTime.now());
    everAll([selectedDate, _operatingCostService.updatedCount],
        (_) async => rangePickerHandle(selectedDate.value));
    super.onInit();
  }

  Future<void> rangePickerHandle(DateTime pickedDate) async {
    // displayDate.value = DateFormat('dd MMM y', 'id').format(pickedDate);
    selectedDate.value = pickedDate;
    final pickerDateRange =
        PickerDateRange(pickedDate, pickedDate.add(Duration(days: 1)));
    final items = await _operatingCostService.getByDate(pickerDateRange);
    dailyOperatingCosts.assignAll(items);
  }

  void deleteOperatingCost(OperatingCostModel operatingCost) async {
    await _operatingCostService.delete(operatingCost.id!);
    await rangePickerHandle(selectedDate.value);
  }
}
