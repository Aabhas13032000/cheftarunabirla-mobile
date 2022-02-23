import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webviewx/webviewx.dart';

class WebviewXPage extends StatefulWidget {
  final String url;
  final bool fullScreen;
  const WebviewXPage({Key? key, required this.url, required this.fullScreen})
      : super(key: key);

  @override
  _WebviewXPageState createState() => _WebviewXPageState();
}

class _WebviewXPageState extends State<WebviewXPage> {
  late WebViewXController webviewController;
  late bool isFullscreen;
  Size get screenSize => MediaQuery.of(context).size;

  @override
  void initState() {
    super.initState();
    // setLandscape();
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

  Future setAllOrientation() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    await Wakelock.disable();
  }

  @override
  void dispose() {
    webviewController.dispose();
    setAllOrientation();
    super.dispose();
  }

  void showSnackBar(String content, BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(content),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WebViewX(
          key: const ValueKey('webviewx'),
          initialContent: widget.url,
          initialSourceType: SourceType.url,
          height: screenSize.height,
          width: screenSize.width,
          onWebViewCreated: (controller) => webviewController = controller,
          onPageStarted: (src) =>
              debugPrint('A new page has started loading: $src\n'),
          onPageFinished: (src) =>
              debugPrint('The page has finished loading: $src\n'),
          jsContent: const {
            EmbeddedJsContent(
              js: "function testPlatformIndependentMethod() { console.log('Hi from JS') }",
            ),
            EmbeddedJsContent(
              webJs:
                  "function testPlatformSpecificMethod(msg) { TestDartCallback('Web callback says: ' + msg) }",
              mobileJs:
                  "function testPlatformSpecificMethod(msg) { TestDartCallback.postMessage('Mobile callback says: ' + msg) }",
            ),
          },
          dartCallBacks: {
            DartCallback(
              name: 'TestDartCallback',
              callBack: (msg) => showSnackBar(msg.toString(), context),
            )
          },
          webSpecificParams: const WebSpecificParams(
            printDebugInfo: true,
          ),
          mobileSpecificParams: const MobileSpecificParams(
            androidEnableHybridComposition: true,
          ),
          navigationDelegate: (navigation) {
            debugPrint(navigation.content.sourceType.toString());
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
