import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'open_image.dart';

class EachBlog extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  final String time;
  const EachBlog({
    Key? key,
    required this.title,
    required this.description,
    required this.id,
    required this.time,
  }) : super(key: key);

  @override
  _EachBlogState createState() => _EachBlogState();
}

class _EachBlogState extends State<EachBlog> {
  List<Widget> list = [];
  bool isLoading = false;
  String remotePDFpath = "";
  String imagePath = "";

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = imagePath;
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

    return completer.future;
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareFiles(
      [remotePDFpath],
      text:
          '${widget.title} to explore more blogs click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> getBlogImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getBlogImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      imagePath =
          'https://dashboard.cheftarunabirla.com${_data['data'][0]['path'].toString()}';
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OpenImage(
                        url:
                            'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}')),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 300.0,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}',
                    // placeholder: (context, url) =>
                    //     const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    // fadeOutDuration: const Duration(seconds: 1),
                    // fadeInDuration: const Duration(seconds: 1),
                    fit: BoxFit.cover,
                    // width: 144.0,
                    height: 200.0,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getBlogImages();
      }
    } on SocketException catch (_) {
      print('not connected');
      _showMyDialog();
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void initState() {
    // _filterRetriever();
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getBlogImages();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please Connect to internet'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

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
        actions: [
          IconButton(
            onPressed: () {
              // _saveFilter();
              createFileOfPdfUrl().then((f) {
                setState(() {
                  remotePDFpath = f.path;
                });
                _onShare(context);
              });
            },
            icon: const Icon(
              MdiIcons.shareVariant,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: list.isEmpty
                        ? Container(
                            height: 0.0,
                          )
                        : SizedBox(
                            height: 200.0,
                            width: double.infinity,
                            child: !isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : CarouselSlider(
                                    options: CarouselOptions(
                                      aspectRatio: 1 / 1,
                                      autoPlay: true,
                                      viewportFraction: 0.9,
                                      autoPlayAnimationDuration:
                                          const Duration(milliseconds: 1000),
                                      enlargeCenterPage: false,
                                      enableInfiniteScroll:
                                          list.length == 1 ? false : true,
                                    ),
                                    items: list
                                        .map(
                                          (item) => item,
                                        )
                                        .toList(),
                                  ),
                          ),
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 00.0, horizontal: 24.0),
                    child: Text(
                      '${widget.title}',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 24.0,
                          fontFamily: 'CenturyGothic'),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 00.0, horizontal: 24.0),
                    child: Text(
                      '${widget.time}',
                      style: TextStyle(
                          color: Palette.contrastColor,
                          fontSize: 14.0,
                          fontFamily: 'CenturyGothic'),
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 00.0, horizontal: 24.0),
                    child: Text(
                      widget.description,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'EuclidCircularA Regular'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
