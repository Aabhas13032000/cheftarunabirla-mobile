class Course {
  late final String id;
  late final String title;
  late final String description;
  late final String promo_video;
  late final String price;
  late final String discount_price;
  late final int days;
  late final String category;
  late final String image_path;
  late final int count;
  late final int subscribed;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.promo_video,
    required this.price,
    required this.discount_price,
    required this.days,
    required this.category,
    required this.image_path,
    required this.count,
    required this.subscribed,
  });
}
