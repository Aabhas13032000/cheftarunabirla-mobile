import 'dart:convert';

class Cart {
  late final String id;
  late final String category;

  Cart({required this.id, required this.category});

  factory Cart.fromJson(Map<String, dynamic> jsonData) {
    return Cart(
      id: jsonData['id'],
      category: jsonData['category'],
    );
  }

  static Map<String, dynamic> toMap(Cart cart) => {
        'id': cart.id,
        'category': cart.category,
      };

  static String encode(List<Cart> cart) => json.encode(
        cart
            .map<Map<String, dynamic>>(
                (encoded_news) => Cart.toMap(encoded_news))
            .toList(),
      );

  static List<Cart> decode(String cart) => (json.decode(cart) as List<dynamic>)
      .map<Cart>((item) => Cart.fromJson(item))
      .toList();
}
