import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/widgets/load_web_page.dart';
import 'package:taruna_birla/widgets/webviewx_page.dart';

class CartPaymentPage extends StatefulWidget {
  final String url;
  const CartPaymentPage({Key? key, required this.url}) : super(key: key);

  @override
  State<CartPaymentPage> createState() => _CartPaymentPageState();
}

class _CartPaymentPageState extends State<CartPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Cart Payment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: 'EuclidCircularA Medium',
          ),
        ),
        backgroundColor: Palette.appBarColor,
        elevation: 10.0,
        shadowColor: Palette.shadowColor.withOpacity(0.1),
        centerTitle: true,
      ),
      body: kIsWeb
          ? WebviewXPage(
              url: widget.url,
              fullScreen: false,
            )
          : LoadWebPage(
              url: widget.url,
              fullScreen: false,
            ),
    );
  }
}
