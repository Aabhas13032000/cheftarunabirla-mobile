import 'package:flutter/material.dart';
import 'package:taruna_birla/config/palette.dart';

class InshopPage extends StatefulWidget {
  const InshopPage({Key? key}) : super(key: key);

  @override
  _InshopPageState createState() => _InshopPageState();
}

class _InshopPageState extends State<InshopPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 18.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '',
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
      body: Center(
        child: Image.asset(
          'assets/images/coming-soon.png',
          width: 200.0,
        ),
      ),
    );
  }
}
