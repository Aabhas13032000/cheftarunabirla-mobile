import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taruna_birla/pages/video_page.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoPlayerPage extends StatefulWidget {
  final String url;
  final bool fullScreen;
  final String page;
  const VideoPlayerPage(
      {Key? key,
      required this.url,
      required this.fullScreen,
      required this.page})
      : super(key: key);

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;
  late bool isFullscreen;

  @override
  void initState() {
    super.initState();
    // print(widget.url);
    controller = VideoPlayerController.network(
      // 'https://tarunabirlavidios.s3.us-east-2.amazonaws.com/010+VERRY+BERRY+COOKIES.mp4',
      widget.url,
      // videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    // _initializeVideoPlayerFuture = controller.initialize();
    controller.addListener(() {
      setState(() {});
    });
    controller.setLooping(true);
    controller.initialize().then((_) => setState(() {}));
    controller.play();
    controller.setVolume(20.0);
    isFullscreen = widget.fullScreen;
    if (isFullscreen) {
      setLandscape();
    } else {
      setAllOrientation();
    }
  }

  Future setLandscape() async {
    // await SystemChrome.setEnabledSystemUIOverlays([]);
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await Wakelock.enable();
  }

  @override
  void dispose() {
    controller.dispose();
    setAllOrientation();
    super.dispose();
  }

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await Wakelock.disable();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OrientationBuilder(
        builder: (context, orientation) {
          final isPotrait = orientation == Orientation.portrait;
          return Container(
            // height: 200.0,
            width: double.infinity,
            child: controller != null && controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    // Use the VideoPlayer widget to display the video.
                    child: Stack(
                      // fit: isPotrait ? StackFit.loose : StackFit.expand,
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        VideoPlayer(controller),
                        _ControlsOverlay(controller: controller),
                        Container(
                          // height: 18.0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.black.withOpacity(0.0),
                                // Colors.black.withOpacity(0.1),
                                // Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5.0, horizontal: 0.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: VideoProgressIndicator(
                                    controller,
                                    allowScrubbing: true,
                                    // colors: VideoProgressColors(
                                    //
                                    // ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (widget.page == 'promo') {
                                      setState(() {
                                        // controller.dispose();
                                        controller == null;
                                        setAllOrientation();
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPage(url: widget.url),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        if (isFullscreen) {
                                          isFullscreen = false;
                                          setAllOrientation();
                                        } else {
                                          // setAllOrientation();
                                          isFullscreen = true;
                                          setLandscape();
                                        }
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.fullscreen,
                                    size: 24.0,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          );
        },
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const _examplePlaybackRates = [
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: Duration(milliseconds: 50),
          reverseDuration: Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton<double>(
        //     initialValue: controller.value.playbackSpeed,
        //     tooltip: 'Playback speed',
        //     onSelected: (speed) {
        //       controller.setPlaybackSpeed(speed);
        //     },
        //     itemBuilder: (context) {
        //       return [
        //         for (final speed in _examplePlaybackRates)
        //           PopupMenuItem(
        //             value: speed,
        //             child: Text('${speed}x'),
        //           )
        //       ];
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //         // Using less vertical padding as the text is also longer
        //         // horizontally, so it feels like it would need more spacing
        //         // horizontally (matching the aspect ratio of the video).
        //         vertical: 12,
        //         horizontal: 16,
        //       ),
        //       child: Text('${controller.value.playbackSpeed}x'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
