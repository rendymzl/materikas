using System;
using System.Drawing;
using System.Drawing.Printing;

class Program {
    static void Main(string[] args) {
        if (args.Length == 0) {
            Console.WriteLine("Usage: PrintImage.exe <image_path>");
            return;
        }

        string imagePath = args[0];
        PrintDocument pd = new PrintDocument();
        pd.PrintPage += (sender, ev) => PrintImage(ev, imagePath);
        pd.Print();
    }

    private static void PrintImage(PrintPageEventArgs ev, string imagePath) {
        try {
            Image img = Image.FromFile(imagePath);
            Point loc = new Point(0, 0);
            ev.Graphics.DrawImage(img, loc);
        }
        catch (Exception ex) {
            Console.WriteLine($"Error printing: {ex.Message}");
        }
    }
}
