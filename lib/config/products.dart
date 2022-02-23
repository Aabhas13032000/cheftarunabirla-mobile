class Products {
  late final String id;
  late final String name;
  late final String description;
  late final String c_name;
  late final String category_id;
  late final String price;
  late final String discount_price;
  late final int stock;
  late final String image_path;
  late final int count;

  Products({
    required this.id,
    required this.name,
    required this.description,
    required this.c_name,
    required this.category_id,
    required this.price,
    required this.discount_price,
    required this.stock,
    required this.image_path,
    required this.count,
  });
}
