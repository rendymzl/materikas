import 'package:flutter_thermal_printer/utils/printer.dart';

class PrinterSettingModel {
  String name;
  String address;
  String method;
  String paperSize;
  ConnectionType? connectionType;
  bool printDate;

  PrinterSettingModel({
    required this.name,
    required this.address,
    required this.method,
    required this.paperSize,
    this.connectionType,
    this.printDate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'method': method,
      'paperSize': paperSize,
      'connectionType': connectionType?.toString(),
      'printDate': printDate,
    };
  }

  factory PrinterSettingModel.fromMap(Map<String, dynamic> map) {
    return PrinterSettingModel(
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      method: map['method'] ?? '',
      paperSize: map['paperSize'] ?? '',
      connectionType: map['connectionType'] == 'USB'
          ? ConnectionType.USB
          : ConnectionType.BLE,
      printDate: map['printDate'] ?? false,
    );
  }
}
