import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class ReviewsPage extends StatefulWidget {
  final String category;
  final String item_id;
  const ReviewsPage({Key? key, required this.category, required this.item_id})
      : super(key: key);

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  List<Widget> list = [];
  bool isLoading = false;
  String user_id = '';
  final reviewController = TextEditingController();

  Future<void> addReviewsByCategory() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: 'https://dashboard.cheftarunabirla.com/addReviews',
      body: {
        'user_id': user_id,
        'message': reviewController.text,
        'item_id': widget.item_id,
        'category': widget.category
      },
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data);
    if (_status) {
      // data loaded
      setState(() {
        reviewController.text = '';
      });
      getReviewsByCategory();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getReviewsByCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/getReviewsByItem/${widget.category}/${widget.item_id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data['data'][i]['username'].toString() != 'null'
                          ? _data['data'][i]['username'].toString()
                          : 'User',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                        fontFamily: 'EuclidCircularA Medium',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      _data['data'][i]['message'].toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0,
                        fontFamily: 'EuclidCircularA REgular',
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _data['data'][i]['date'].toString().substring(0, 10),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.0,
                            fontFamily: 'EuclidCircularA REgular',
                          ),
                        ),
                      ],
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
        getReviewsByCategory();
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
      getReviewsByCategory();
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
          'Reviews',
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black12,
                          border: Border.all(color: Colors.black38, width: 0.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffFFF0D0).withOpacity(0.6),
                              blurRadius: 30.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: const Offset(
                                0.0, // Move to right 10  horizontally
                                0.0, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {},
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          controller: reviewController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.messageTextOutline,
                            ),
                            counterText: "",
                            hintText: "Write your review",
                            focusColor: Palette.contrastColor,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xffffffff),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Color(0xffffffff), width: 1.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            filled: true,
                            fillColor: const Color(0xffffffff),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        // print('send mesage');
                        setState(() {
                          isLoading = false;
                        });
                        addReviewsByCategory();
                      },
                      child: Container(
                        height: 48.0,
                        width: 48.0,
                        decoration: BoxDecoration(
                          color: Palette.secondaryColor,
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.send_outlined,
                            size: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
