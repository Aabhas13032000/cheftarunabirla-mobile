import 'package:flutter/material.dart';
import 'package:taruna_birla/widgets/video_player.dart';
import 'package:taruna_birla/widgets/widgets.dart';

class VideoPage extends StatefulWidget {
  final String url;
  const VideoPage({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: const Icon(
        //       Icons.arrow_back_ios,
        //       color: Colors.white,
        //       size: 18.0,
        //     ),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        //   title: const Text(
        //     '',
        //     style: TextStyle(
        //       color: Colors.black,
        //       fontSize: 18.0,
        //       fontFamily: 'EuclidCircularA Medium',
        //     ),
        //   ),
        //   backgroundColor: Colors.black,
        //   elevation: 0.0,
        //   shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
        //   centerTitle: true,
        // ),
        body: Center(
          child: widget.url.contains('youtube')
              ? YoutubePlayerPage(
                  url: widget.url.split('v=')[1],
                  fullScreen: true,
                )
              : VideoPlayerPage(
                  url: widget.url,
                  fullScreen: true,
                  page: 'full_video',
                ),
        ),
      ),
    );
  }
}
