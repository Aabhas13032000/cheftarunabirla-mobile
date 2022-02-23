class Coupon {
  late final String id;
  late final String ccode;
  late final String category;
  late final int dis;
  late final int minimum;
  late final int maximum;

  Coupon(
      {required this.id,
      required this.ccode,
      required this.dis,
      required this.minimum,
      required this.maximum,
      required this.category});
}
