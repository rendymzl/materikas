// using System;
// using System.Drawing;
// using System.Drawing.Printing;

// class PrintSmallDocumentExample
// {
//     public static void Main(string[] args)
//     {
//         if (args.Length < 2)
//         {
//             Console.WriteLine("Usage: PrintImage.exe <image_path> <printer_name> [store_name] [store_address] [store_phone]");
//             return;
//         }

//         string imagePath = args[0];
//         string printerName = args[1];
//         string storeName = args.Length > 2 ? args[2] : null;
//         string storeAddress = args.Length > 3 ? args[3] : null;
//         string storePhone = args.Length > 4 ? args[4] : null;

//         PrintDocument pd = new PrintDocument();
//         if (!string.IsNullOrEmpty(printerName))
//         {
//             pd.PrinterSettings.PrinterName = printerName;
//         }

//         // Tentukan ukuran kertas: 76mm lebar jika storeName tidak ada, 100 tinggi tetap
//         int paperWidth = string.IsNullOrEmpty(storeName) ? 250 : 1000;
//         int paperHeight = string.IsNullOrEmpty(storeName) ? 110 : 110;
//         PaperSize customSize = new PaperSize("Custom", paperWidth, paperHeight);
//         pd.DefaultPageSettings.PaperSize = customSize;

//         pd.PrintPage += (sender, e) => PrintPageHandler(sender, e, imagePath, storeName, storeAddress, storePhone);

//         try
//         {
//             pd.Print();
//         }
//         catch (Exception ex)
//         {
//             Console.WriteLine($"Error printing: {ex.Message}");
//         }
//     }

//     private static void PrintPageHandler(object sender, PrintPageEventArgs e, string imagePath, string storeName, string storeAddress, string storePhone)
//     {
//         try
//         {
//             if (!string.IsNullOrEmpty(imagePath))
//             {
//                 Image img = Image.FromFile(imagePath);
//                 int paperWidth = e.PageBounds.Width;
//                 int paperHeight = e.PageBounds.Height;
                
//                 if (string.IsNullOrEmpty(storeName))
//                 {
//                     // Cetak gambar di tengah jika storeName kosong
//                     float xPos = (paperWidth - img.Width) / 2f;
//                     float yPos = (paperHeight - img.Height) / 2f;
//                     e.Graphics.DrawImage(img, xPos, yPos, img.Width, img.Height);
//                 }
//                 else
//                 {
//                     // Cetak gambar dan teks jika storeName ada
//                     e.Graphics.DrawImage(img, 0, 0, img.Width, img.Height);

//                     Font storeNameFont = new Font("Segoe UI", 16, FontStyle.Bold);
//                     Font otherFont = new Font("Segoe UI", 10, FontStyle.Bold);
//                     Brush brush = Brushes.Black;
//                     float xTextPos = 10 + img.Width;
//                     float yTextPos = 0;
                    
//                     string storeNameInvoice = $"{storeName}                                     INVOICE";
//                     string[] lines = { storeNameInvoice, storeAddress, storePhone };
//                     e.Graphics.DrawString(lines[0], storeNameFont, brush, xTextPos, yTextPos);
//                     yTextPos += storeNameFont.Height;
//                     e.Graphics.DrawString(lines[1], otherFont, brush, xTextPos, yTextPos);
//                     yTextPos += otherFont.Height;
//                     e.Graphics.DrawString(lines[2], otherFont, brush, xTextPos, yTextPos);
//                 }
//             }
//         }
//         catch (Exception ex)
//         {
//             Console.WriteLine($"Error in PrintPageHandler: {ex.Message}");
//         }
//     }
// }
