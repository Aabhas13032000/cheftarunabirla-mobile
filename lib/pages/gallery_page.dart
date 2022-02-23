import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'open_image.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({Key? key}) : super(key: key);

  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<Widget> list = [];
  bool isLoading = false;
  int offset = 0;
  bool isLoadingVertical = false;

  Future<void> getGalleryImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getGalleryImages/$offset',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      list.clear();
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl:
                    'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}',
                // placeholder: (context, url) =>
                //     const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                // fadeOutDuration: const Duration(seconds: 1),
                // fadeInDuration: const Duration(seconds: 1),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        );
      }
      setState(() {
        isLoading = true;
      });
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getMoreGalleryImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getGalleryImages/$offset',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl:
                    'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}',
                // placeholder: (context, url) =>
                //     const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                // fadeOutDuration: const Duration(seconds: 1),
                // fadeInDuration: const Duration(seconds: 1),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        );
      }
      setState(() {
        isLoading = true;
      });
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getGalleryImages();
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
      getGalleryImages();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _loadMoreVertical() async {
    setState(() {
      isLoadingVertical = true;
    });
    print('ended');
    getMoreGalleryImages();
    // Add in an artificial delay
    await new Future.delayed(const Duration(seconds: 1));
    // print('ended after delay');

    setState(() {
      isLoadingVertical = false;
    });
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
    return Material(
      child: SafeArea(
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
              'Gallery',
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
          body: !isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  height: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: LazyLoadScrollView(
                          isLoading: isLoadingVertical,
                          onEndOfPage: () {
                            setState(() {
                              offset = offset + 20;
                            });
                            _loadMoreVertical();
                          },
                          child: Scrollbar(
                            child: GridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 24.0),
                              childAspectRatio: 0.8,
                              children: list,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: !isLoadingVertical
                            ? const Center()
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text('Loading...'),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
