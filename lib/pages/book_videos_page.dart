import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/pages/video_web_player.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class BookVideosPage extends StatefulWidget {
  final String book_id;
  const BookVideosPage({Key? key, required this.book_id}) : super(key: key);

  @override
  _BookVideosPageState createState() => _BookVideosPageState();
}

class _BookVideosPageState extends State<BookVideosPage> {
  List<Widget> list = [];
  bool isLoading = false;
  String user_id = '';
  final reviewController = TextEditingController();
  int subscribed = 0;

  Future<void> getBookVideos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getBookVideos/${widget.book_id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              if (subscribed == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoWebPage(url: _data['data'][i]['path'].toString()),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 0.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xffFFF0D0).withOpacity(0.6),
                      blurRadius: 30.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: const Offset(
                        4.0, // Move to right 10  horizontally
                        8.0, // Move to bottom 10 Vertically
                      ),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 23.0, horizontal: 15.0),
                        child: Row(
                          children: [
                            Text(
                              '${_data['data'][i]['name'].toString().length >= 20 ? _data['data'][i]['name'].toString().substring(0, 20) : _data['data'][i]['name'].toString()}...',
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      child: subscribed == 0
                          ? const Center()
                          : const Icon(
                              Icons.arrow_forward_ios,
                              size: 18.0,
                            ),
                    ),
                  ],
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
        getBookVideos();
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
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getBookVideos();
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
          'Book Videos',
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 12.0,
                      ),
                      for (var i in list) i,
                    ],
                  ),
                ),
              ),
            ),
            Container(
              height: 70.0,
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  colors: [
                    Palette.primaryColor.withOpacity(0.0),
                    Palette.primaryColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  tileMode: TileMode.clamp,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffFFF0D0).withOpacity(0.0),
                    blurRadius: 30.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      0.0, // Move to bottom 10 Vertically
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 24.0),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Palette.contrastColor,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xffFFF0D0).withOpacity(0.0),
                          blurRadius: 30.0, // soften the shadow
                          spreadRadius: 0.0, //extend the shadow
                          offset: const Offset(
                            0.0, // Move to right 10  horizontally
                            0.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Buy Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 0.0),
                            child: VerticalDivider(
                              width: 2.0,
                              color: Colors.white70,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Rs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
