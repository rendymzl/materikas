class PrintColumn {
  String text;
  int width;
  String align;
  bool bold;
  String size;
  List<int>? image;

  PrintColumn({
    required this.text,
    required this.width,
    this.align = 'left', 
    this.bold = false,
    this.size = 'small',
    this.image,
  });
}
