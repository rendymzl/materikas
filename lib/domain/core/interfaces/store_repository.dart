import '../../../infrastructure/models/store_model.dart';

abstract class StoreRepository {
  Future<StoreModel> getStore(String storeId);
  Future<void> insert(StoreModel store);
  Future<void> update(StoreModel updatedstore);
  Future<void> delete(String id);
}
