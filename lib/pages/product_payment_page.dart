import 'package:flutter/material.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/widgets/load_web_page.dart';

class ProductPaymentPage extends StatefulWidget {
  final String total_price;
  final String actual_total_price;
  final String user_id;
  final String coupon_id;
  final String phoneNumber;
  final String quantity;
  final String description;
  final String address;
  final String item_id;
  final String selectedImage;
  final String pincode;
  const ProductPaymentPage({
    Key? key,
    required this.total_price,
    required this.actual_total_price,
    required this.user_id,
    required this.coupon_id,
    required this.phoneNumber,
    required this.quantity,
    required this.description,
    required this.address,
    required this.item_id,
    required this.selectedImage,
    required this.pincode,
  }) : super(key: key);

  @override
  State<ProductPaymentPage> createState() => _ProductPaymentPageState();
}

class _ProductPaymentPageState extends State<ProductPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 18.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Product Payment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontFamily: 'EuclidCircularA Medium',
          ),
        ),
        backgroundColor: Palette.appBarColor,
        elevation: 10.0,
        shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
        centerTitle: true,
      ),
      body: LoadWebPage(
        url:
            'https://dashboard.cheftarunabirla.com/subscription/${widget.total_price}/${widget.actual_total_price}/${widget.user_id}/${widget.item_id}/product/${widget.description}/${widget.coupon_id}/online/${widget.quantity}/${widget.address}/${widget.phoneNumber}/${widget.selectedImage}/${widget.pincode}',
        fullScreen: false,
      ),
    );
  }
}
