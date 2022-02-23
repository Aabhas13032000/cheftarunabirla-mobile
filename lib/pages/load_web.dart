import 'package:flutter/material.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/widgets/load_web_page.dart';

class LoadWeb extends StatefulWidget {
  final String url;
  const LoadWeb({Key? key, required this.url}) : super(key: key);

  @override
  _LoadWebState createState() => _LoadWebState();
}

class _LoadWebState extends State<LoadWeb> {
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
      body: LoadWebPage(
        url: widget.url,
        fullScreen: false,
      ),
    );
  }
}
