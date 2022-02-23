import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:url_launcher/url_launcher.dart';

class SharePdf extends StatefulWidget {
  final String path;
  const SharePdf({required this.path, Key? key}) : super(key: key);

  @override
  _SharePdfState createState() => _SharePdfState();
}

class _SharePdfState extends State<SharePdf> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  String remotePDFpath = "";
  late bool isLoading;
  bool _allowWriteFile = false;
  String progress = "";
  late final String path;
  bool downloading = true;
  String downloadingStr = "No data";
  final debug = true;

  requestWritePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        _allowWriteFile = true;
      });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
    }
  }

  // void _onShare(BuildContext context) async {
  //   // A builder is used to retrieve the context immediately
  //   // surrounding the ElevatedButton.
  //   //
  //   // The context's `findRenderObject` returns the first
  //   // RenderObject in its descendent tree when it's not
  //   // a RenderObjectWidget. The ElevatedButton's RenderObject
  //   // has its position and size after it's built.
  //   final box = context.findRenderObject() as RenderBox?;
  //   await Share.shareFiles(
  //     [widget.path],
  //     sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
  //   );
  // }

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = widget.path;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }
    await FlutterDownloader.initialize(debug: debug);

    return completer.future;
  }

  Future<void> downloadPdf() async {
    if (!_allowWriteFile) {
      requestWritePermission();
    }
    // final dir =
    //     await getApplicationDocumentsDirectory(); //From path_provider package
    // var _localPath = dir.path + 'download.pdf';
    // final savedDir = Directory(_localPath);
    // await savedDir.create(recursive: true).then((value) async {
    //   String? _taskid = await FlutterDownloader.enqueue(
    //     url: widget.path,
    //     fileName: 'download.pdf',
    //     savedDir: _localPath,
    //     showNotification: true,
    //     openFileFromNotification: true,
    //   );
    //   print(_taskid);
    // });
    ////
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(widget.path)) {
        await launch(widget.path, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("Not able to download")));
      }
    } else {
      // android , web
      if (await canLaunch(widget.path)) {
        await launch(widget.path);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: new Text("Not able to download")));
      }
    }
    ////
    // var dio = Dio();
    // final url = widget.path;
    // final filename = url.substring(url.lastIndexOf("/") + 1);
    // var dir = await getApplicationDocumentsDirectory();
    // File f = File("${dir.path}/$filename");
    // String savePath = await getFilePath(filename);
    // print("${dir.path}/$filename");
    // try {
    //   ProgressDialog progressDialog = ProgressDialog(context,
    //       dialogTransitionType: DialogTransitionType.Bubble,
    //       title: Text("Downloading File"));
    //
    //   progressDialog.show();
    //
    //   // await dio.download(widget.path, savePath,
    //   //     onReceiveProgress: (rec, total) {
    //   //   setState(() {
    //   //     isLoading = true;
    //   //     progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
    //   //     progressDialog.setMessage(Text("Dowloading $progress"));
    //   //   });
    //   // });
    //   final response = await dio.get(widget.path,
    //       options: Options(
    //           responseType: ResponseType.bytes,
    //           followRedirects: false,
    //           receiveTimeout: 0));
    //   final raf = f.openSync(mode: FileMode.write);
    //   raf.writeFromSync(response.data);
    //   await raf.close();
    //
    //   OpenFile.open(f.path);
    //
    //   progressDialog.dismiss();
    // } catch (e) {
    //   print(e.toString());
    // }
    ////
    // print('inside pdf');
    // Response response;
    //
    // response = await dio.download(widget.path, "${dir.path}/$filename",
    //     onReceiveProgress: (rec, total) {});
    //
    // print(response);

    // return f;
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName';

    return path;
  }

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        remotePDFpath = f.path;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
          actions: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      downloadPdf();
                    },
                    child: Text(
                      'Download Pdf',
                      style: TextStyle(
                        color: Palette.secondaryColor,
                        fontSize: 14.0,
                        fontFamily: 'EuclidCircularA Medium',
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        body: remotePDFpath.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  PDFView(
                    filePath: remotePDFpath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: false,
                    pageFling: true,
                    pageSnap: true,
                    defaultPage: currentPage!,
                    fitPolicy: FitPolicy.BOTH,
                    preventLinkNavigation:
                        false, // if set to true the link is handled in flutter
                    onRender: (_pages) {
                      setState(() {
                        pages = _pages;
                        isReady = true;
                      });
                    },
                    onError: (error) {
                      setState(() {
                        errorMessage = error.toString();
                      });
                      print(error.toString());
                    },
                    onPageError: (page, error) {
                      setState(() {
                        errorMessage = '$page: ${error.toString()}';
                      });
                      print('$page: ${error.toString()}');
                    },
                    onViewCreated: (PDFViewController pdfViewController) {
                      _controller.complete(pdfViewController);
                    },
                    onLinkHandler: (String? uri) {
                      // print('goto uri: $uri');
                    },
                    onPageChanged: (int? page, int? total) {
                      print('page change: $page/$total');
                      setState(() {
                        currentPage = page;
                      });
                    },
                  ),
                  errorMessage.isEmpty
                      ? !isReady
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : Container()
                      : Center(
                          child: Text(errorMessage),
                        )
                ],
              ),
        // floatingActionButton: FutureBuilder<PDFViewController>(
        //   future: _controller.future,
        //   builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
        //     if (snapshot.hasData) {
        //       return FloatingActionButton.extended(
        //         label: Text("Go to ${pages! ~/ 2}"),
        //         onPressed: () async {
        //           await snapshot.data!.setPage(pages! ~/ 2);
        //         },
        //       );
        //     }
        //
        //     return Container();
        //   },
        // ),
      ),
    );
  }
}
