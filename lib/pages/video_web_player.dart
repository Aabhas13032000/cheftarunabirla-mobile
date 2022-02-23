import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taruna_birla/widgets/load_web_page.dart';
import 'package:taruna_birla/widgets/video_player.dart';
import 'package:taruna_birla/widgets/webviewx_page.dart';
import 'package:taruna_birla/widgets/youtube_player_page.dart';
import 'package:wakelock/wakelock.dart';

class VideoWebPage extends StatefulWidget {
  final String url;
  const VideoWebPage({Key? key, required this.url}) : super(key: key);

  @override
  State<VideoWebPage> createState() => _VideoWebPageState();
}

class _VideoWebPageState extends State<VideoWebPage> {
  @override
  void initState() {
    super.initState();
    // if (isFullscreen) {
    // setLandscape();
    // } else {
    //   setAllOrientation();
    // }
  }

  Future setLandscape() async {
    // await SystemChrome.setEnabledSystemUIOverlays([]);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await Wakelock.enable();
  }

  @override
  void dispose() {
    setAllOrientation();
    super.dispose();
  }

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      //     'Course Payment',
      //     style: TextStyle(
      //       color: Colors.black,
      //       fontSize: 18.0,
      //       fontFamily: 'EuclidCircularA Medium',
      //     ),
      //   ),
      //   backgroundColor: Palette.appBarColor,
      //   elevation: 10.0,
      //   shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
      //   centerTitle: true,
      // ),
      body: widget.url.contains('youtube')
          ? YoutubePlayerPage(
              url: widget.url.split('v=')[1],
              fullScreen: true,
            )
          : widget.url.contains('vimeo')
              ? kIsWeb
                  ? WebviewXPage(
                      url: widget.url,
                      fullScreen: false,
                    )
                  : LoadWebPage(
                      url: widget.url,
                      fullScreen: true,
                    )
              : VideoPlayerPage(
                  url: widget.url,
                  fullScreen: true,
                  page: 'full_video',
                ),
    );
  }
}
