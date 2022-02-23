class Book {
  late final String id;
  late final String title;
  late final String description;
  late final String price;
  late final String discount_price;
  late final int days;
  late final String category;
  late final String image_path;
  late final String pdflink;
  late final int count;

  Book({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.discount_price,
    required this.days,
    required this.category,
    required this.image_path,
    required this.pdflink,
    required this.count,
  });
}
