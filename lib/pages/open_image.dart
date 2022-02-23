import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class OpenImage extends StatefulWidget {
  final String url;
  const OpenImage({Key? key, required this.url}) : super(key: key);

  @override
  _OpenImageState createState() => _OpenImageState();
}

class _OpenImageState extends State<OpenImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontFamily: 'EuclidCircularA Medium',
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0.0,
        shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
        centerTitle: true,
      ),
      body: Center(
        child: CachedNetworkImage(
          imageUrl: widget.url,
          // placeholder: (context, url) =>
          //     const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          // fadeOutDuration: const Duration(seconds: 1),
          // fadeInDuration: const Duration(seconds: 1),
          fit: BoxFit.cover,
        ),
        // Image.network(
        //   widget.url,
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}
