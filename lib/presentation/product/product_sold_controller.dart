// file: product_sold_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

// Sesuaikan path import model Anda
import '../../infrastructure/models/log_stock_model.dart';

class ProductSoldController extends GetxController {
  // --- STATE ---
  // Gunakan .obs untuk membuat variabel menjadi reaktif
  final RxMap<String, Map<String, dynamic>> productTotals =
      <String, Map<String, dynamic>>{}.obs;
  final RxList<String> sortedProducts = <String>[].obs;

  // Variabel untuk menampung data mentah awal
  final List<LogStock> rawLogStock;

  // Constructor untuk menerima data awal dari view
  ProductSoldController(this.rawLogStock);

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    processLogData(); // Olah data saat controller pertama kali diinisialisasi
  }

  // --- LOGIC ---
  void processLogData() {
    Map<String, Map<String, dynamic>> tempTotals = {};
    for (var log in rawLogStock) {
      if (log.label == 'Terjual' && log.productName != null) {
        if (!tempTotals.containsKey(log.productName)) {
          tempTotals[log.productName!] = {'total': 0.0, 'unit': log.unit ?? ''};
        }
        tempTotals[log.productName!]!['total'] =
            (tempTotals[log.productName!]!['total'] as double) +
                (log.amount * -1);
      }
    }

    List<String> tempSorted = tempTotals.keys.toList()
      ..sort((a, b) => (tempTotals[b]!['total'] as double)
          .compareTo(tempTotals[a]!['total'] as double));

    // Update state reaktif
    productTotals.value = tempTotals;
    sortedProducts.value = tempSorted;
  }

  Future<void> exportToExcel(BuildContext context) async {
    final salesLogs =
        rawLogStock.where((log) => log.label == 'Terjual').toList();

    if (sortedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data untuk diekspor!')),
      );
      return;
    }

    // =======================================================
    // PERUBAHAN 1: MENCARI RENTANG TANGGAL UNTUK NAMA FILE
    // =======================================================
    DateTime minDate = salesLogs.first.createdAt!;
    DateTime maxDate = salesLogs.first.createdAt!;

    for (var log in salesLogs) {
      if (log.createdAt!.isBefore(minDate)) {
        minDate = log.createdAt!;
      }
      if (log.createdAt!.isAfter(maxDate)) {
        maxDate = log.createdAt!;
      }
    }

    final String formattedMinDate = DateFormat('yyyy-MM-dd').format(minDate);
    final String formattedMaxDate = DateFormat('yyyy-MM-dd').format(maxDate);

    final String dateRangeFileName = (formattedMinDate == formattedMaxDate)
        ? formattedMinDate
        : '${formattedMinDate}_sd_${formattedMaxDate}';

    final excel = Excel.createExcel();
    final Sheet sheetObject = excel.sheets.values.first;

    final List<String> headers = [
      'No',
      'Tanggal',
      'Nama Produk',
      'Ukuran',
      'Jumlah',
    ];
    // final List<String> headers = [
    //   'No',
    //   'Tanggal',
    //   'Nama Produk',
    //   'Jumlah',
    //   'Satuan'
    // ];
    sheetObject
        .appendRow(headers.map((header) => TextCellValue(header)).toList());

    for (var i = 0; i < headers.length; i++) {
      var cell = sheetObject
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.cellStyle =
          CellStyle(bold: true, horizontalAlign: HorizontalAlign.Center);
    }

    for (int i = 0; i < salesLogs.length; i++) {
      final log = salesLogs[i];
      final double jumlah = log.amount * -1;

      // =======================================================
      // PERUBAHAN 2: FORMAT ANGKA JUMLAH SECARA CERDAS
      // =======================================================
      CellValue jumlahCell;
      // Cek apakah jumlahnya adalah bilangan bulat (tidak punya desimal)
      if (jumlah == jumlah.truncateToDouble()) {
        // Jika ya, simpan sebagai Integer (misal: 15)
        jumlahCell = IntCellValue(jumlah.toInt());
      } else {
        // Jika tidak, simpan sebagai Double (misal: 15.5)
        jumlahCell = DoubleCellValue(jumlah);
      }
      // =======================================================

      final row = [
        TextCellValue((i + 1).toString()),
        TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt!)),
        TextCellValue(log.productName ?? 'N/A'),
        TextCellValue(log.unit ?? ''),
        jumlahCell, // <-- Gunakan cell value yang sudah diformat
      ];

      // final row = [
      //   TextCellValue((i + 1).toString()),
      //   TextCellValue(DateFormat('yyyy-MM-dd HH:mm:ss').format(log.createdAt!)),
      //   TextCellValue(log.productName ?? 'N/A'),
      //   jumlahCell, // <-- Gunakan cell value yang sudah diformat
      //   TextCellValue(log.unit ?? ''),
      // ];
      sheetObject.appendRow(row);
    }

    // Mengatur lebar kolom menggunakan properti yang benar
    sheetObject.setColumnWidth(1, 20); // Kolom B (Tanggal)
    sheetObject.setColumnWidth(2, 30); // Kolom C (Nama Produk)

    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Laporan Excel Anda',
      fileName: 'laporan-penjualan_$dateRangeFileName.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile == null) return;

    final List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      try {
        await File(outputFile).writeAsBytes(fileBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ekspor berhasil! Tersimpan di $outputFile')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan file: $e')),
        );
      }
    }
  }

  // Helper function agar lebih rapi
  String _getSafeDateRangeFileName(List<LogStock> salesLogs) {
    DateTime minDate = salesLogs.first.createdAt!;
    DateTime maxDate = salesLogs.first.createdAt!;

    for (var log in salesLogs) {
      if (log.createdAt!.isBefore(minDate)) {
        minDate = log.createdAt!;
      }
      if (log.createdAt!.isAfter(maxDate)) {
        maxDate = log.createdAt!;
      }
    }

    final String formattedMinDate = DateFormat('yyyy-MM-dd').format(minDate);
    final String formattedMaxDate = DateFormat('yyyy-MM-dd').format(maxDate);

    return (formattedMinDate == formattedMaxDate)
        ? formattedMinDate
        : '${formattedMinDate}_sd_${formattedMaxDate}';
  }
}
