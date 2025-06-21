import 'package:hive/hive.dart';

import '../models/printer_setting_model.dart';

class HiveBox {
  static const String printerBox = 'printerBox';
  static const String selectedUserBox = 'selectedUser';
  static const String midtransBox = 'midtrans';
  static const String imageBox = 'image';

  static Future<void> savePrinter(PrinterSettingModel printer) async {
    var box = await Hive.openBox(printerBox);
    box.put('printer', printer.toMap());
  }

  static Future<PrinterSettingModel?> getPrinter() async {
    var box = await Hive.openBox(printerBox);
    var settingMap = box.get('printer');
    Map<String, dynamic> parsedSetting = {};
    if (settingMap != null) {
      parsedSetting =
          (settingMap as Map<dynamic, dynamic>).cast<String, dynamic>();
    }

    return PrinterSettingModel.fromMap(parsedSetting);
  }

  static Future<void> deletePrinter() async {
    var box = await Hive.openBox(printerBox);
    box.delete('printer');
  }

  static Future<void> saveSelectedUser(String selectedUser) async {
    var box = await Hive.openBox(selectedUserBox);
    box.put('user', selectedUser);
  }

  static Future<String?> getSelectedUser() async {
    var box = await Hive.openBox(selectedUserBox);
    return box.get('user');
  }

  static Future<void> saveImageShow(bool isShow) async {
    var box = await Hive.openBox(imageBox);
    box.put('image_show', isShow);
  }

  static Future<bool?> getImageShow() async {
    var box = await Hive.openBox(imageBox);
    return box.get('image_show');
  }

  static Future<void> deleteImageShow() async {
    var box = await Hive.openBox(imageBox);
    box.delete('image_show');
  }

  static Future<void> saveGridLayout(bool isGridLayout) async {
    var box = await Hive.openBox(imageBox);
    box.put('grid_layout', isGridLayout);
  }

  static Future<bool?> getGridLayout() async {
    var box = await Hive.openBox(imageBox);
    return box.get('grid_layout');
  }

  static Future<void> deleteGridLayout() async {
    var box = await Hive.openBox(imageBox);
    box.delete('grid_layout');
  }

  static Future<void> saveMidtrans(String key, dynamic value) async {
    var box = await Hive.openBox(midtransBox);
    box.put(key, value);
  }

  static Future<void> deleteMidtrans(String key) async {
    var box = await Hive.openBox(midtransBox);
    box.delete(key);
  }

  static Future<String> getMidtrans(String value) async {
    var box = await Hive.openBox(midtransBox);
    return box.get(value) ?? '';
  }
}
