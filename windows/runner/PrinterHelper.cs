using System;
using System.Drawing.Printing;
using Flutter.Windows;

public class Printer
{
    public void PrintReceipt(string content)
    {
        try
        {
            PrintDocument printDoc = new PrintDocument();
            printDoc.PrintPage += new PrintPageEventHandler((sender, e) =>
            {
                e.Graphics.DrawString(content, new Font("Arial", 12), Brushes.Black, 10, 10);
            });
            printDoc.Print();
        }
        catch (Exception ex)
        {
            Console.WriteLine("Error printing: " + ex.Message);
        }
    }
}
