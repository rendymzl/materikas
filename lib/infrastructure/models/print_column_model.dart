class PrintColumn {
  String text;
  int width;
  String align;
  bool bold;
  String size;

  PrintColumn({
    required this.text,
    required this.width,
    this.align = 'left',
    this.bold = false,
    this.size = 'normal',
  });
}
