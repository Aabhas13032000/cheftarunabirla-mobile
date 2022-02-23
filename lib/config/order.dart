class Orders {
  late final String id;
  late final String name;
  late final String date;
  late final String item_id;
  late final String category;
  late final String paid_price;
  late final String price;
  late final String image_path;
  late final String order_image;
  late final int quantity;
  late final String payment_status;

  Orders({
    required this.id,
    required this.name,
    required this.date,
    required this.item_id,
    required this.category,
    required this.paid_price,
    required this.price,
    required this.image_path,
    required this.order_image,
    required this.quantity,
    required this.payment_status,
  });
}
