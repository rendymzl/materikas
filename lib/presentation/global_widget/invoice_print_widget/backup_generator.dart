import '../../../infrastructure/models/print_column_model.dart';
import 'package:image/image.dart' as img;

class Generator {
  String padRight(String text, int length) {
    if (text.length < length) {
      return text.padRight(length);
    } else {
      return '${text.substring(0, length - 1)} ';
    }
  }

  String padLeft(String text, int length) {
    if (text.length < length) {
      return text.padLeft(length);
    } else {
      return text.substring(0, length);
    }
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

        if (col.size == 'large') {
          bytes += [27, 33, 40]; // ESC ! 48 untuk ukuran font besar
        }

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

        // Reset size
        if (col.size == 'normal') {
          bytes += [27, 33, 0]; // ESC ! 0 untuk ukuran font normal
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

  List<int> imageRaster(img.Image image, {String align = 'center'}) {
    List<int> bytes = [];

    // Konversi gambar ke grayscale
    img.Image grayscale = img.grayscale(image);

    // Dapatkan dimensi gambar
    final int width = grayscale.width;
    final int height = grayscale.height;

    // Hitung jumlah bytes per baris
    final int widthBytes = (width + 7) ~/ 8;

    // Konversi gambar ke format raster
    List<int> rasterData = [];
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < widthBytes; x++) {
        int byte = 0;
        for (int bit = 0; bit < 8; bit++) {
          int px = x * 8 + bit;
          if (px < width) {
            // Ambil pixel dan konversi ke binary (hitam/putih)
            num pixel = grayscale.getPixel(px, y).r;
            if (pixel < 128) { // Threshold untuk hitam/putih
              byte |= (1 << (7 - bit));
            }
          }
        }
        rasterData.add(byte);
      }
    }

    // Header untuk raster bit image
    bytes += [0x1D, 0x76, 0x30, 0x00]; // GS v 0
    bytes += [widthBytes & 0xff, (widthBytes >> 8) & 0xff]; // width bytes
    bytes += [height & 0xff, (height >> 8) & 0xff]; // height pixels
    bytes += rasterData;

    return bytes;
  }
}
