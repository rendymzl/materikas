using System;
using System.Drawing;
using System.Drawing.Printing;
using System.IO;
using Newtonsoft.Json.Linq;
using Newtonsoft.Json; // Menambahkan using directive untuk Newtonsoft.Json
using System.Text; // Tambahkan ini
using System.Collections.Generic; // Tambahkan ini
using Newtonsoft.Json.Linq;
using System.Linq;

public class Program
{
    private const float LineSpacing = 15f; // Menambahkan konstanta untuk jarak antar baris
    //private const float MarginKiri = 5f; // Margin dihilangkan
    // private static readonly Font FontBold = new Font("Segoe UI", 11); // Mengganti font dan ukuran
    private static readonly Font FontNormal = new Font("Segoe UI", 10, FontStyle.Regular); // Font normal tanpa bold
    private static readonly Font FontBold = new Font("Segoe UI", 10, FontStyle.Bold); // Font bold
    private static readonly Font FontLarge = new Font("Segoe UI", 14, FontStyle.Bold); // Mengganti font dan ukuran
    private static readonly Brush BrushDefault = Brushes.Black;


    public static void Main(string[] args)
    {
        if (args.Length < 6)
        {
            Console.WriteLine("Error: Not enough arguments provided.");
            return;
        }

        string imagePath = args[0];
        string printerName = args[1];
        string storeName = args.Length > 2 ? args[2] : null;
        string storeAddress = args.Length > 3 ? args[3] : null;
        string storePhone = args.Length > 4 ? args[4] : null;
        string jsonInvoice = args[5];
        string jsonStore = args[6];
        string subTotalBill = args[7];
        string totalDiscount = args[8];
        string totalOtherCosts = args[9];
        string remainingDebtKey = args[10];
        string remainingDebtValue = args[11];
        string printDate = args[12];
        string paperSize = args[13];
        string printTransport = args[14];
        string supplier = args[15];
        string PO = args[16];

        bool isPrintTransport = printTransport == "1";
        bool isSupplier = supplier == "1";
        bool isPO = PO == "1";
        float PageWidth = paperSize == "small" ? 250f : 800f;
        // 58mm dalam pixel (220px ≈ 58mm dengan asumsi 3.78px/mm)

        try
        {
            JObject invoiceData = JObject.Parse(jsonInvoice);
            JObject storeData = JObject.Parse(jsonStore);
            PrintReceipt(imagePath, printerName, storeName, storeAddress, storePhone, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, remainingDebtKey, remainingDebtValue, printDate, PageWidth, isPrintTransport, isSupplier, isPO);
        }
        catch (JsonException ex) // Mengganti JsonReaderException dengan JsonException
        {
            Console.WriteLine($"Error parsing JSON: {ex.Message}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error during printing: {ex.Message}");
        }

    }

    private static void PrintReceipt(string imagePath, string printerName, string storeName, string storeAddress, string storePhone, JObject invoiceData, JObject storeData, string subTotalBill, string totalDiscount, string totalOtherCosts, string remainingDebtKey, string remainingDebtValue, string printDate, float PageWidth, bool isPrintTransport, bool isSupplier, bool isPO)
    {
        PrintDocument printDoc = new PrintDocument();
        printDoc.PrinterSettings.PrinterName = printerName;
        printDoc.PrintPage += (sender, e) => PrintPage(e.Graphics, imagePath, storeName, storeAddress, storePhone, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, remainingDebtKey, remainingDebtValue, printDate, PageWidth, isPrintTransport, isSupplier, isPO);

        try
        {
            printDoc.Print();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error printing document: {ex.Message}");
        }
    }

    private static void PrintPage(Graphics g, string imagePath, string storeName, string storeAddress, string storePhone, JObject invoiceData, JObject storeData, string subTotalBill, string totalDiscount, string totalOtherCosts, string remainingDebtKey, string remainingDebtValue, string printDate, float PageWidth, bool isPrintTransport, bool isSupplier, bool isPO)
    {
        float x = 0; // Margin kiri dihilangkan
        float y = 0; // Margin atas dihilangkan
        float lineHeight = FontBold.Height; // Mendapatkan tinggi font default

        // 1️⃣ Cetak Logo (Jika Ada)
        PrintHeader(g, imagePath, ref x, ref y, PageWidth, storeName, storeAddress, storePhone, lineHeight, isPrintTransport, isPO);
        y += 5;
        g.DrawLine(Pens.Black, x, y, PageWidth, y);
        y += 5;

        // 4️⃣ Cetak Informasi Invoice
        PrintInvoiceInfo(g, invoiceData, ref x, ref y, lineHeight, PageWidth, isPrintTransport, isSupplier);
        if (PageWidth < 500f)
        {
            y += lineHeight;
        }

        y += 5;
        g.DrawLine(Pens.Black, x, y, PageWidth, y);
        y += 5;

        // 5️⃣ Cetak Daftar Barang
        PrintItemList(g, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, ref x, ref y, lineHeight, PageWidth, remainingDebtKey, remainingDebtValue, isPrintTransport, isSupplier);

        // 6️⃣ Cetak Total Harga
        // PrintTotal(g, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, ref x, ref y, lineHeight, PageWidth, remainingDebtKey, remainingDebtValue);


        if (PageWidth < 500f)
        {
            if (!isPrintTransport && !isSupplier) {
                y += 5;
                g.DrawLine(Pens.Black, x, y, PageWidth, y);
                y += 5;
                DrawTextWithSpacing(g, remainingDebtKey, remainingDebtValue, FontBold, x, ref y, PageWidth, lineHeight);
                y += lineHeight;

                foreach (var note in storeData["text_print"])
                {
                PrintCenterText(g, note.ToString(), FontBold, ref x, ref y, lineHeight, PageWidth);
                y += lineHeight;
                }
            }
            y += lineHeight;
            PrintCenterText(g, printDate, FontBold, ref x, ref y, lineHeight, PageWidth);
            y += lineHeight;
            y += lineHeight;
            PrintCenterText(g, "-", FontBold, ref x, ref y, lineHeight, PageWidth);
        } else {
            y += lineHeight;
            y += lineHeight;
            if (!isSupplier || isPO) {
                DrawTripleText(g, "Customer", "Admin", "Driver", FontBold, x, ref y, PageWidth, lineHeight);
            }
        }
    }

    private static void PrintHeader(Graphics g, string imagePath, ref float x, ref float y, float PageWidth, string storeName, string storeAddress, string storePhone, float lineHeight, bool isPrintTransport, bool isPO)
    {
        if (File.Exists(imagePath))
        {
            try
            {
                if (PageWidth < 500f)
                {
                    using (Image logo = Image.FromFile(imagePath))
                    {
                        // Sesuaikan ukuran logo agar sesuai dengan lebar kertas 58mm
                        float logoWidth = 100f; // Contoh: lebar logo 50 pixel
                        float logoHeight = logoWidth * logo.Height / logo.Width;
                        g.DrawImage(logo, (PageWidth - logoWidth) / 2, y, logoWidth, logoHeight);
                        y += logoHeight + 2; // Tambahkan jarak 5 pixel setelah logo
                    }
                    // 2️⃣ Cetak Info Toko
                    PrintCenterText(g, storeName, FontLarge, ref x, ref y, lineHeight, PageWidth);
                    PrintCenterText(g, storeAddress, FontBold, ref x, ref y, lineHeight, PageWidth);
                    PrintCenterText(g, storePhone, FontBold, ref x, ref y, lineHeight, PageWidth);
                } else {
                    using (Image logo = Image.FromFile(imagePath))
                    {
                        float logoWidth = logo.Width;
                        float logoHeight = logo.Height;
                        g.DrawImage(logo, 0, y, logoWidth, logoHeight);

                        float rightColumnWidth = PageWidth - logoWidth - 15; // 15 for padding
                        float xRight = logoWidth + 10;

                        SizeF storeNameSize = g.MeasureString(storeName, FontLarge);
                        SizeF invoiceSize = g.MeasureString(isPO ? "PURCHASE ORDER" : isPrintTransport ? "SURAT JALAN" : "INVOICE", FontLarge);

                        if (storeNameSize.Width > rightColumnWidth)
                        {
                            string shortenedStoreName = storeName.Substring(0, Math.Max(0, storeName.Length - ((int)((storeNameSize.Width - rightColumnWidth) / 8))));
                            storeNameSize = g.MeasureString(shortenedStoreName, FontLarge);
                        }

                        StringFormat rightAlign = new StringFormat();
                        rightAlign.Alignment = StringAlignment.Far;
                        
                        // 2️⃣ Cetak Info Toko
                        g.DrawString(storeName, FontLarge, BrushDefault, xRight, y);
                        g.DrawString(isPO ? "PURCHASE ORDER" : isPrintTransport ? "SURAT JALAN" : "INVOICE", FontLarge, BrushDefault, PageWidth, y, rightAlign);
                        y += lineHeight;
                        g.DrawString(storeAddress, FontBold, BrushDefault, xRight, y);
                        y += lineHeight;
                        g.DrawString(storePhone, FontBold, BrushDefault, xRight, y);
                        y += lineHeight;
                        y += lineHeight;
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error loading logo: {ex.Message}");
            }
        }
    }

    private static void PrintCenterText(Graphics g, string info, Font font, ref float x, ref float y, float lineHeight, float PageWidth)
    {
        if (!string.IsNullOrEmpty(info))
        {
            CenterText(g, info, font, BrushDefault, x, ref y, PageWidth);
            // y += lineHeight; // Tambahkan jarak antar baris
        }
    }

    private static void PrintInvoiceInfo(Graphics g, JObject invoiceData, ref float x, ref float y, float lineHeight, float PageWidth, bool isPrintTransport, bool isSupplier)
    {
        string priceType = invoiceData["price_type"]?.ToString() ?? "";

        string invoiceId = invoiceData["invoice_id"]?.ToString() ?? "";
        string dateTime = DateTime.Parse(invoiceData["created_at"]?.ToString() ?? DateTime.Now.ToString()).ToString("dd MMMM yyyy");
        string cashier = invoiceData["account"]["name"]?.ToString() ?? "";
        string customerName = invoiceData["customer"]["name"]?.ToString() ?? "";
        string customerPhone = invoiceData["customer"]["phone"]?.ToString() ?? "";
        string customerAddress = invoiceData["customer"]["address"]?.ToString() ?? "";

        Console.WriteLine("debug mulai.");
        Console.WriteLine($"priceType: {priceType}");
        Console.WriteLine("debug selesai.");


        if (PageWidth < 500f)
        {
            if (isPrintTransport) {
                PrintCenterText(g, "SURAT JALAN", FontLarge, ref x, ref y, lineHeight, PageWidth);
                y += lineHeight;
            }
            g.DrawString(invoiceId, FontBold, BrushDefault, x, y);
            y += lineHeight;
            g.DrawString(dateTime, FontBold, BrushDefault, x, y);
            y += lineHeight;
            if (!isSupplier) {
                g.DrawString($"Kasir: {cashier}", FontBold, BrushDefault, x, y);
                y += lineHeight;
            }
            g.DrawString($"{customerName} {customerPhone}", FontBold, BrushDefault, x, y);
            y += lineHeight; 
            LeftAlignText(g, customerAddress, FontBold, BrushDefault, x, ref y, PageWidth);
            // g.DrawString(customerAddress, FontBold, BrushDefault, x, y);
            // y += lineHeight; 
        } else {
             string paymentMethod = "";
             bool hasCash = false;
             bool hasTransfer = false;
             foreach (var payment in invoiceData["payments"]) {
                 string method = payment["method"]?.ToString()?.ToLower() ?? "";
                 if (method == "cash") hasCash = true;
                 if (method == "transfer") hasTransfer = true;
             }
             paymentMethod = hasCash && hasTransfer ? "Cash dan Transfer" :
                            hasCash ? "Cash" :
                            hasTransfer ? "Transfer" : "";
             
            // g.DrawString($"Kasir: {cashier}", FontBold, BrushDefault, x, y);
            // DrawReceiptInfo(g, "No. Invoice", $": {invoiceId}", $"Kepada Yth.\n{customerName} {customerPhone}", FontBold, x, ref y, PageWidth, lineHeight);
            // g.DrawString($"Kasir: {cashier}", FontBold, BrushDefault, x, y);
            DrawReceiptInfo(g, "No. Invoice", $": {invoiceId}", isSupplier ? "Supplier" : "Kepada Yth.", FontBold, x, ref y, PageWidth, lineHeight);
            DrawReceiptInfo(g, "Tanggal", $": {dateTime}", $"{customerName} {customerPhone}", FontBold, x, ref y, PageWidth, lineHeight);
            DrawReceiptInfo(g, "Jenis Transaksi", $": {paymentMethod}", customerAddress, FontBold, x, ref y, PageWidth, lineHeight);
            // DrawReceiptInfo(g, "No. Invoice\nTanggal\nJenis Transaksi", $": {invoiceId}\n: {dateTime}\n: {paymentMethod}", $"Kepada Yth.\n{customerName} {customerPhone} \nALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT ALAMAT", FontBold, x, ref y, PageWidth, lineHeight);
            // DrawReceiptInfo(g, "Tanggal\nKasir", $": {dateTime}\n: {cashier}", customerAddress, FontBold, x, ref y, PageWidth, lineHeight);\n{customerAddress}
        }
    }

    private static void PrintItemList(Graphics g, JObject invoiceData, JObject storeData, string subTotalBill, string totalDiscount, string totalOtherCosts, ref float x, ref float y, float lineHeight, float PageWidth, string remainingDebtKey, string remainingDebtValue, bool isPrintTransport, bool isSupplier)
    {
        if (PageWidth < 500f)
        {
            DrawTextWithSpacing(g, "No Nama Barang", isPrintTransport ? "Qty" : "Harga", FontBold, x, ref y, PageWidth, lineHeight);
            y += 5;
            g.DrawLine(Pens.Black, x, y, PageWidth, y);
            y += 5;

            int index = 1;
            foreach (var item in invoiceData["purchase_list"]["items"])
            {
                var product = item["product"];
                string productName = product["product_name"]?.ToString() ?? "Unknown";
                string unit = product["unit"]?.ToString() ?? "";
                double priceType = invoiceData["price_type"]?.ToObject<double>() ?? 1;
                Console.WriteLine($"priceType real: {priceType}");
                double costPrice = product["cost_price"]?.ToObject<double>() ?? 0;
                double sellPrice1 = product["sell_price1"]?.ToObject<double>() ?? 0;
                double sellPrice2 = product["sell_price2"]?.ToObject<double>() ?? 0;
                double sellPrice3 = product["sell_price3"]?.ToObject<double>() ?? 0;
                
                double price = isSupplier ? costPrice :
                              priceType == 1 ? sellPrice1 :
                              priceType == 2 ? (sellPrice2 > 0 ? sellPrice2 : sellPrice1) :
                              priceType == 3 ? (sellPrice3 > 0 ? sellPrice3 : sellPrice1) : 0;

                double quantity = item["quantity"]?.ToObject<double>() ?? 1;
                double total = price * quantity;

                if (quantity >0) {
                DrawTextWithSpacing(g, $"{index} {productName}", isPrintTransport ? $"{quantity} {unit}" : "", FontBold, x, ref y, PageWidth, lineHeight);
                // DrawTextWithSpacing(g, $"{index} {productName}", "Harga", FontBold, x, ref y, PageWidth, lineHeight);
                // g.DrawString($"{index}", FontBold, BrushDefault, x, y);
                // g.DrawString($"{productName}", FontBold, BrushDefault, x + 20, y);
                // y += lineHeight;
                // g.DrawString($"{price:N0} x {quantity} pcs", FontBold, BrushDefault, x + 20);
                if (!isPrintTransport) {
                    DrawTextWithSpacing(g, $"    {price:N0} x {quantity} {unit}", $"{total:N0}", FontBold, x, ref y, PageWidth, lineHeight);
                };

                // g.DrawString($"{total:N0}", FontBold, BrushDefault, PageWidth - 50, y);
                // y += lineHeight; // Tambahkan jarak antar baris yang lebih besar untuk item list
                index++;
                }
            }
            y += 5;
            g.DrawLine(Pens.Black, x, y, PageWidth, y);
            y += 5;
            if (!isPrintTransport) {
                PrintTotal(g, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, ref x, ref y, lineHeight, PageWidth, remainingDebtKey, remainingDebtValue, isSupplier);
            };
        } else {
            // Header Kolom
            string[] headers = { "No", "Nama Barang", "Uk", "Qty", "Harga", "Jumlah" };
            // string[] headers = { "No", "Nama Barang", "Qty", isPrintTransport ? "" : "Diskon", isPrintTransport ? "" : "Harga", isPrintTransport ? "" : "Jumlah" };

            // Persentase dari lebar kertas
            float[] columnWidthsHeader = {
                PageWidth * 0.04f,  // No (8%)
                PageWidth * 0.43f,  // Nama Barang (35%)
                PageWidth * 0.10f,  // Uk (12%)
                PageWidth * 0.10f,  // Qty (12%)
                PageWidth * 0.15f,  // Harga (15%)
                PageWidth * 0.18f   // Jumlah (18%)
            };
            // float[] columnWidthsHeader = {
            //     PageWidth * 0.04f,  // No (8%)
            //     PageWidth * 0.39f,  // Nama Barang (35%)
            //     PageWidth * 0.12f,  // Qty (12%)
            //     PageWidth * 0.12f,  // Diskon (12%)
            //     PageWidth * 0.15f,  // Harga (15%)
            //     PageWidth * 0.18f   // Jumlah (18%)
            // };

            float xPos = x;

            // Gambar Header
            for (int i = 0; i < headers.Length; i++)
            {
                StringFormat rightAlign = new StringFormat();
                if (i == 3 || i == 4 || i == 5) {
                    rightAlign.Alignment = StringAlignment.Far;
                    g.DrawString(headers[i], FontBold, BrushDefault, xPos + columnWidthsHeader[i], y, rightAlign);
                } else {
                g.DrawString(headers[i], FontBold, BrushDefault, xPos, y, rightAlign);
                }
                xPos += columnWidthsHeader[i];
            }

            // Garis pemisah
            y += lineHeight;
            y += 5;
            g.DrawLine(Pens.Black, x, y, x + PageWidth, y);

            int itemNumber = 1;

            // Persentase dari lebar kertas untuk item list
            float[] columnWidths = columnWidthsHeader;

            // Ambil daftar item dari invoice
            JArray itemsArray = new JArray(invoiceData["purchase_list"]?["items"]
                ?.Cast<JObject>() // Konversi ke IEnumerable<JObject>
                .Where(item => item["quantity"]?.ToObject<double>() > 0));

            int itemCount = itemsArray.Count;

            for (int i = 0; i < itemCount; i++)
            {
                var item = itemsArray[i] as JObject ?? new JObject();
                var product = item["product"] as JObject ?? new JObject();

                string productName = product["product_name"]?.ToString() ?? "Unknown";
                string unit = product["unit"]?.ToString() ?? "";

                double priceType = invoiceData["price_type"]?.ToObject<double>() ?? 1;
                Console.WriteLine($"priceType real: {priceType}");
                double costPrice = product["cost_price"]?.ToObject<double>() ?? 0;
                double sellPrice1 = product["sell_price1"]?.ToObject<double>() ?? 0;
                double sellPrice2 = product["sell_price2"]?.ToObject<double>() ?? 0;
                double sellPrice3 = product["sell_price3"]?.ToObject<double>() ?? 0;
                
                double price = isSupplier ? costPrice :
                              priceType == 1 ? sellPrice1 :
                              priceType == 2 ? (sellPrice2 > 0 ? sellPrice2 : sellPrice1) :
                              priceType == 3 ? (sellPrice3 > 0 ? sellPrice3 : sellPrice1) : 0;

                double quantity = item["quantity"]?.ToObject<double>() ?? 1;
                double discount = item["discount"]?.ToObject<double>() ?? 0;
                double total = price * quantity - discount;

                float xPosItem = x;

                // Menampilkan nomor item
                g.DrawString(itemNumber.ToString(), FontBold, BrushDefault, xPosItem, y);
                xPosItem += columnWidths[0];

                // Menampilkan nama barang, menangani jika teks melebihi lebar kolom
                string[] productNameLines = productName.Split('\n');
                foreach (string line in productNameLines)
                {
                    if (g.MeasureString(line, FontBold).Width > columnWidths[1])
                    {
                        string[] words = line.Split(' ');
                        string currentLine = "";
                        foreach (string word in words)
                        {
                            if (g.MeasureString(currentLine + (currentLine.Length > 0 ? " " : "") + word, FontBold).Width <= columnWidths[1])
                            {
                                currentLine += (currentLine.Length > 0 ? " " : "") + word;
                            }
                            else
                            {
                                g.DrawString(currentLine, FontBold, BrushDefault, xPosItem, y);
                                y += lineHeight;
                                currentLine = word;
                            }
                        }
                        g.DrawString(currentLine, FontBold, BrushDefault, xPosItem, y);
                        y += lineHeight;
                    }
                    else
                    {
                        g.DrawString(line, FontBold, BrushDefault, xPosItem, y);
                        y += lineHeight;
                    }
                }
                y -= lineHeight; // Adjust y position after handling multiple lines
                xPosItem += columnWidths[1];

                // Menampilkan kuantitas
                g.DrawString($"{unit}", FontBold, BrushDefault, xPosItem, y);
                // g.DrawString($"{quantity} {unit}", FontBold, BrushDefault, xPosItem, y);
                xPosItem += columnWidths[2];

                // Menampilkan diskon, align kanan
                StringFormat rightAlign = new StringFormat();
                rightAlign.Alignment = StringAlignment.Far;
                g.DrawString($"{quantity}", FontBold, BrushDefault, xPosItem + columnWidths[3], y, rightAlign);
                xPosItem += columnWidths[3];
                // g.DrawString(isPrintTransport ? "" : $"{discount:N0}", FontBold, BrushDefault, xPosItem + columnWidths[3], y, rightAlign);
                // xPosItem += columnWidths[3];

                // Menampilkan harga, align kanan
                g.DrawString(isPrintTransport ? "" : $"{price:N0}", FontBold, BrushDefault, xPosItem + columnWidths[4], y, rightAlign);
                xPosItem += columnWidths[4];

                // Menampilkan jumlah, align kanan
                g.DrawString(isPrintTransport ? "" : $"{total:N0}", FontBold, BrushDefault, xPosItem + columnWidths[5], y, rightAlign);

                y += lineHeight;
                itemNumber++;
            }
            y += 5;
            g.DrawLine(Pens.Black, x, y, PageWidth, y);
            y += 5;
            if (!isPrintTransport) {
                PrintTotal(g, invoiceData, storeData, subTotalBill, totalDiscount, totalOtherCosts, ref x, ref y, lineHeight, PageWidth, remainingDebtKey, remainingDebtValue, isSupplier);
            }
            // Tambahkan baris kosong jika item kurang dari 14
            int emptyLinesNeeded = 7 - itemCount;
            for (int i = 0; i < emptyLinesNeeded; i++)
            {
                y += lineHeight;
            }
        }
    
    }

    private static void PrintTotal(Graphics g, JObject invoiceData, JObject storeData, string subTotalBill, string totalDiscount, string totalOtherCosts, ref float x, ref float y, float lineHeight, float PageWidth, string remainingDebtKey, string remainingDebtValue, bool isSupplier)
    {
        float totalPaid = 0;
        foreach (var payment in invoiceData["payments"])
        {
            totalPaid += payment["amount"]?.ToObject<float>() ?? 0;
        }
        
        if (PageWidth < 500f)
        {
            DrawTextWithSpacing(g, "SUBTOTAL:", subTotalBill, FontBold, x, ref y, PageWidth, lineHeight);
            if (!string.IsNullOrEmpty(totalDiscount))
            {
                DrawTextWithSpacing(g, "Total Diskon:", totalDiscount, FontBold, x, ref y, PageWidth, lineHeight);
            }
            if (!string.IsNullOrEmpty(totalOtherCosts))
            {
                DrawTextWithSpacing(g, "Biaya Lainnya:", totalOtherCosts, FontBold, x, ref y, PageWidth, lineHeight);
            }

            // double totalPayment = 0;
            foreach (var payment in invoiceData["payments"])
            {
                double amountPaid = payment["amount_paid"]?.ToObject<double>() ?? 0;
                double finalAmountPaid = payment["final_amount_paid"]?.ToObject<double>() ?? 0;
                // double nextTotal = totalPayment + amountPaid;
                // totalPayment += amountPaid;

                DrawTextWithSpacing(g, $"Pembayaran {payment["method"]?.ToString() ?? ""}", $"{amountPaid:N0}", FontBold, x, ref y, PageWidth, lineHeight);
            }
            // DrawTextWithSpacing(g, "TOTAL:", $"{totalPayment:N0}", FontBold, x, ref y, PageWidth, lineHeight);
        } else {
            float leftColumnWidth = PageWidth * 0.65f;
            // float centerColumnWidth = PageWidth * 0.2f;
            float rightColumnWidth = PageWidth * 0.35f;
            float xRight = x + leftColumnWidth + 5; // Tambahkan sedikit jarak antara kolom

            JArray textPrintArray = storeData["text_print"] as JArray ?? new JArray();
            float initialY = y; // Simpan posisi y awal
            if (!isSupplier) {
                for (int i = 0; i < textPrintArray.Count; i++)
                {
                    string text = textPrintArray[i]?.ToString() ?? "-";
                    SizeF textSize = g.MeasureString(text, FontBold);
                    if (textSize.Width > leftColumnWidth)
                    {
                        StringFormat format = new StringFormat();
                        format.Alignment = StringAlignment.Near;
                        format.LineAlignment = StringAlignment.Near;
                        format.Trimming = StringTrimming.EllipsisCharacter;
                        g.DrawString(text, FontNormal, BrushDefault, x, y, format);
                    }
                    else
                    {
                        g.DrawString(text, FontNormal, BrushDefault, x, y);
                    }
                    y += lineHeight;
                }
            }
            y = initialY; // Kembalikan posisi y ke awal

            DrawTextWithSpacing(g, "Grand Total:", subTotalBill, FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            foreach (var payment in invoiceData["payments"])
            {
                double amountPaid = payment["amount_paid"]?.ToObject<double>() ?? 0;
                double finalAmountPaid = payment["final_amount_paid"]?.ToObject<double>() ?? 0;
                // double nextTotal = totalPayment + amountPaid;
                // totalPayment += amountPaid;
                DrawTextWithSpacing(g, $"Pembayaran {payment["method"]?.ToString() ?? ""}", $"{finalAmountPaid:N0}", FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            }
            // if (!string.IsNullOrEmpty(totalDiscount))
            // {
            //     DrawTextWithSpacing(g, "Total Diskon :", totalDiscount, FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            // }
            // if (!string.IsNullOrEmpty(totalOtherCosts))
            // {
            //     DrawTextWithSpacing(g, "Biaya Lainnya :", totalOtherCosts, FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            // }
            // DrawTextWithSpacing(g, "Bayar :", $"{totalPaid:N0}", FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            // DrawTextWithSpacing(g, "", "-------------", FontBold, xRight, ref y, rightColumnWidth, lineHeight);
            // DrawTextWithSpacing(g, remainingDebtKey, remainingDebtValue, FontBold, xRight, ref y, rightColumnWidth, lineHeight);

            // Menyesuaikan posisi y untuk kolom kanan agar sejajar
            y = initialY;
            for (int i = 0; i < textPrintArray.Count; i++) {
                y += lineHeight;
            }

            // Menambahkan kolom kanan
            DrawTextWithSpacing(g, "", "", FontBold, xRight, ref y, rightColumnWidth, lineHeight);


        }

    }


    private static void DrawTextWithSpacing(Graphics g, string leftText, string rightText, Font font, float x, ref float y, float width, float lineHeight)
    {
        SizeF leftSize = g.MeasureString(leftText, font);
        SizeF rightSize = g.MeasureString(rightText, font);

        float rightX = x + width - rightSize.Width - 5;

        g.DrawString(leftText, font, BrushDefault, x, y);
        g.DrawString(rightText, font, BrushDefault, rightX, y);
        y += lineHeight; // Menggunakan lineHeight untuk jarak antar baris
    }

    private static void DrawReceiptInfo(Graphics g, string leftText, string midText, string rightText, Font font, float x, ref float y, float width, float lineHeight)
    {
        string[] texts = { leftText, midText, rightText };
        float[] columnWidth = {
            width * 0.15f,
            width * 0.35f,
            width * 0.50f
        };
        float xPos = x;
        float maxHeight = 0;
        for (int i = 0; i < texts.Length; i++)
        {
            string text = texts[i];
            SizeF textSize = g.MeasureString(text, font);
            maxHeight = Math.Max(maxHeight, textSize.Height);
            if (textSize.Width > columnWidth[i])
            {
                string[] words = text.Split(' ');
                StringBuilder currentLine = new StringBuilder();
                float currentLineWidth = 0;
                for (int j = 0; j < words.Length; j++)
                {
                    string word = words[j];
                    SizeF wordSize = g.MeasureString(word, font);
                    if (currentLineWidth + wordSize.Width <= columnWidth[i])
                    {
                        currentLine.Append(currentLine.Length > 0 ? " " : "").Append(word);
                        currentLineWidth += wordSize.Width + (currentLine.Length > 1 ? g.MeasureString(" ", font).Width : 0);
                    }
                    else
                    {
                        g.DrawString(currentLine.ToString(), font, BrushDefault, xPos, y);
                        y += lineHeight;
                        currentLine.Clear();
                        currentLine.Append(word);
                        currentLineWidth = wordSize.Width;
                    }
                }
                if (currentLine.Length > 0)
                {
                    g.DrawString(currentLine.ToString(), font, BrushDefault, xPos, y);
                }
            }
            else
            {
                g.DrawString(text, font, BrushDefault, xPos, y);
            }
            xPos += columnWidth[i];
        }
        y += maxHeight;
    }

    private static void DrawTripleText(Graphics g, string leftText, string midText, string rightText, Font font, float x, ref float y, float width, float lineHeight)
    {
        float leftWidth = width / 3;
        float midWidth = width / 3;
        float rightWidth = width / 3;

        float midX = x + leftWidth;
        float rightX = x + leftWidth + midWidth;

        StringFormat centerFormat = new StringFormat
        {
            Alignment = StringAlignment.Center,
            LineAlignment = StringAlignment.Center
        };

        RectangleF leftRect = new RectangleF(x, y, leftWidth, lineHeight);
        RectangleF midRect = new RectangleF(midX, y, midWidth, lineHeight);
        RectangleF rightRect = new RectangleF(rightX, y, rightWidth, lineHeight);

        g.DrawString(leftText, font, BrushDefault, leftRect, centerFormat);
        g.DrawString(midText, font, BrushDefault, midRect, centerFormat);
        g.DrawString(rightText, font, BrushDefault, rightRect, centerFormat);

        y += lineHeight;
    }

   private static void CenterText(Graphics g, string text, Font font, Brush brush, float x, ref float y, float width)
    {
        StringFormat format = new StringFormat
        {
            Alignment = StringAlignment.Center,
            FormatFlags = StringFormatFlags.NoClip
        };

        float lineHeight = g.MeasureString("A", font).Height; // Menggunakan tinggi huruf "A" sebagai referensi
        List<string> lines = new List<string>(); // Menampung teks yang sudah dibagi ke dalam beberapa baris
        StringBuilder currentLine = new StringBuilder();
        string[] words = text.Split(' ');

        foreach (var word in words)
        {
            string testLine = (currentLine.Length > 0 ? currentLine + " " : "") + word;
            SizeF textSize = g.MeasureString(testLine, font);

            if (textSize.Width > width && currentLine.Length > 0)
            {
                lines.Add(currentLine.ToString()); // Tambahkan baris sebelumnya ke dalam daftar
                currentLine.Clear();
                currentLine.Append(word);
            }
            else
            {
                currentLine.Append((currentLine.Length > 0 ? " " : "") + word);
            }
        }

        if (currentLine.Length > 0)
            lines.Add(currentLine.ToString());

        foreach (var line in lines)
        {
            float centerX = x + (width / 2);
            g.DrawString(line, font, brush, new PointF(centerX, y), format);
            y += lineHeight; // Pindah ke baris berikutnya
        }
    }

   private static void LeftAlignText(Graphics g, string text, Font font, Brush brush, float x, ref float y, float width)
    {
        StringFormat format = new StringFormat
        {
            Alignment = StringAlignment.Near, // Mengubah rata kiri
            FormatFlags = StringFormatFlags.NoClip
        };

        float lineHeight = g.MeasureString("A", font).Height;
        List<string> lines = new List<string>();
        StringBuilder currentLine = new StringBuilder();
        string[] words = text.Split(' ');

        foreach (var word in words)
        {
            string testLine = (currentLine.Length > 0 ? currentLine + " " : "") + word;
            SizeF textSize = g.MeasureString(testLine, font);

            if (textSize.Width > width && currentLine.Length > 0)
            {
                lines.Add(currentLine.ToString());
                currentLine.Clear();
                currentLine.Append(word);
            }
            else
            {
                currentLine.Append((currentLine.Length > 0 ? " " : "") + word);
            }
        }

        if (currentLine.Length > 0)
            lines.Add(currentLine.ToString());

        foreach (var line in lines)
        {
            g.DrawString(line, font, brush, new PointF(x, y), format); // Tidak menggunakan centerX
            y += lineHeight;
        }
    }
}
