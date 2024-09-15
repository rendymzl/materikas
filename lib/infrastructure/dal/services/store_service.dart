import 'package:get/get.dart';
import 'package:materikas/infrastructure/models/store_model.dart';

import '../../../domain/core/interfaces/store_repository.dart';
import '../database/powersync.dart';

class StoreService extends GetxService implements StoreRepository {
  late final stores = Rx<StoreModel?>(null);

  @override
  Future<StoreModel> getStore(id) async {
    while (db.currentStatus.lastSyncedAt == null) {
      await Future.delayed(const Duration(seconds: 2));
      print(db.currentStatus);
      print('menunggu koneksi');
      if (db.currentStatus.lastSyncedAt == null) {
        print('mencoba koneksi ulang');
      }
    }
    final row = await db.get('SELECT * FROM stores WHERE id = ?', [id]);
    stores.value = StoreModel.fromRow(row);
    return stores.value!;
  }

  @override
  Future<void> insert(StoreModel store) async {
    await db.execute(
      '''
    INSERT INTO stores(
      id, created_at, name, address, phone, telp, promo, owner_id
    ) VALUES(uuid(), ?, ?, ?, ?, ?, ?)
    ''',
      [
        // store.id,
        store.createdAt.toIso8601String(),
        store.name.value,
        store.address.value,
        store.phone.value,
        store.telp.value,
        store.promo?.value,
      ],
    );
  }

  @override
  Future<void> update(StoreModel store) async {
    await db.execute(
      '''
    UPDATE stores SET
      created_at = ?, 
      name = ?, 
      address = ?, 
      phone = ?, 
      telp = ?, 
      promo = ?
    WHERE id = ?
    ''',
      [
        store.createdAt.toIso8601String(),
        store.name.value,
        store.address.value,
        store.phone.value,
        store.telp.value,
        store.promo?.value,
        store.id,
      ],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.execute(
      'DELETE FROM stores WHERE id = ?',
      [id],
    );
  }
}
