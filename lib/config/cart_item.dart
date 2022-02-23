class CartItem {
  late final String cart_id;
  late final String name;
  late final String price;
  late final int quantity;
  late final String category;
  late final String image_path;
  late final String id;
  late final String item_category;

  CartItem({
    required this.cart_id,
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image_path,
    required this.quantity,
    required this.item_category,
  });
}
