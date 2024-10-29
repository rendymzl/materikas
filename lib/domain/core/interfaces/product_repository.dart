import '../../../infrastructure/models/product_model.dart';

abstract class ProductRepository {
  Future<void> subscribe();
  Future<void> insert(ProductModel product);
  Future<void> insertList(List<ProductModel> productList);
  Future<void> update(ProductModel updatedProduct);
  Future<void> updateList(List<ProductModel> updatedProductList);
  Future<void> backup(String storeId);
  Future<void> delete(String id);
}
