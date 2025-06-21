import '../../../infrastructure/models/operating_cost_model.dart';

abstract class OperatingCostRepository {
  Future<void> subscribe();
  Future<void> insert(OperatingCostModel operatingCost);
  Future<void> update(OperatingCostModel updateOperatingCost);
  Future<void> delete(String id);
}
