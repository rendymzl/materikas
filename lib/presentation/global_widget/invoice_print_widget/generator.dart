import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../infrastructure/dal/services/auth_service.dart';
import '../../../infrastructure/models/print_column_model.dart';

class Generator {
  String _fontType = 'B'; // Default Font A

  void setFontGlobal(String type) {
    if (type.toLowerCase() == 'a' ||
        type.toLowerCase() == 'b' ||
        type.toLowerCase() == 'c' ||
        type.toLowerCase() == 'large') {
      _fontType = type;
    } else {
      throw Exception(
          'Jenis font tidak valid. Gunakan "A", "B", atau "large".');
    }
  }

  List<int> _getFontCommand() {
    switch (_fontType.toLowerCase()) {
      case 'a':
        return [27, 33, 0]; // ESC ! 0 (Font A - Normal)
      case 'b':
        return [27, 33, 1]; // ESC ! 1 (Font B - Kecil)
      case 'large':
        return [27, 33, 48]; // ESC ! 48 (Double Width & Height)
      case 'c':
        return [29, 33, 8]; //ESC ! 16 (Ukuran C, di atas normal)
      default:
        return [27, 33, 0]; // Default ke Font A
    }
  }

  List<int> printText(String text) {
    List<int> bytes = [];
    bytes += _getFontCommand(); // Gunakan font global
    bytes += text.codeUnits;
    bytes += '\n'.codeUnits;
    return bytes;
  }

  String padRight(String text, int length) {
    return text.length < length
        ? text.padRight(length)
        : '${text.substring(0, length - 1)} ';
  }

  String padLeft(String text, int length) {
    return text.length < length
        ? text.padLeft(length)
        : text.substring(0, length);
  }

  String padCenter(String text, int length) {
    int padding = length - text.length;
    if (padding <= 0) {
      return text.substring(0, length);
    }
    int padLeft = padding ~/ 2;
    int padRight = padding - padLeft;
    return '${' ' * padLeft}$text${' ' * padRight}';
  }

  List<String> wrapText(String text, int width) {
    List<String> lines = [];
    while (text.isNotEmpty) {
      if (text.length <= width) {
        lines.add(text);
        break;
      } else {
        int breakIndex = text.lastIndexOf(' ', width);
        if (breakIndex == -1) {
          breakIndex = width;
        }
        lines.add(text.substring(0, breakIndex));
        text = text.substring(breakIndex).trimLeft();
      }
    }
    return lines;
  }

  List<int> printRow(List<PrintColumn> columnConfig) {
    List<int> bytes = [];
    List<List<String>> wrappedColumns =
        columnConfig.map((col) => wrapText(col.text, col.width)).toList();
    int maxLines =
        wrappedColumns.map((col) => col.length).reduce((a, b) => a > b ? a : b);

    for (int lineIndex = 0; lineIndex < maxLines; lineIndex++) {
      bytes +=
          _getFontCommand(); // Pastikan font global diterapkan di setiap baris

      for (int colIndex = 0; colIndex < columnConfig.length; colIndex++) {
        var col = columnConfig[colIndex];

        // Cek apakah kolom memiliki gambar
        if (col.image != null) {
          bytes += col.image!;
          continue;
        }

        String columnText = lineIndex < wrappedColumns[colIndex].length
            ? wrappedColumns[colIndex][lineIndex]
            : '';

        if (col.bold) {
          bytes += [27, 69, 1]; // ESC E 1 untuk bold
        }

        if (col.align == 'right') {
          bytes += padLeft(columnText, col.width).codeUnits;
        } else if (col.align == 'center') {
          bytes += padCenter(columnText, col.width).codeUnits;
        } else {
          bytes += padRight(columnText, col.width).codeUnits;
        }

        // Reset bold
        if (col.bold) {
          bytes += [27, 69, 0]; // ESC E 0 untuk normal (non-bold)
        }
      }
      bytes += '\n'.codeUnits;
    }
    return bytes;
  }

  List<int> row(List<PrintColumn> cols) {
    List<int> bytes = [];
    bytes += printRow(cols);
    return bytes;
  }

  final AuthService authService = Get.find<AuthService>();
  late final account = authService.account.value;
  late final store = authService.store.value;

  List<int> newLine() {
    return '\n'.codeUnits;
  }

  List<int> space() {
    return Uint8List.fromList([27, 74, 24]);
  }

  List<int> divider({int paperSize = 90}) {
    switch (paperSize) {
      case 90:
        return Uint8List.fromList(
            '------------------------------------------------------------------------------------------------'
                .codeUnits);
      case 32:
        return Uint8List.fromList('--------------------------------'.codeUnits);
      default:
        throw Exception('Ukuran kertas tidak valid');
    }
  }

  List<int> cut() {
    return [0x1D, 0x56, 0x00]; // ESC/POS command untuk memotong kertas
  }
}
