import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/pages/each_blog.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String selected = '';
  List<Widget> bloglist = [];
  String firstimage = '';
  String firsttitle = '';
  String firstdescription = '';
  String firstdate = '';
  String firstid = '';
  bool isLoading = false;
  int offset = 0;

  Future<void> getBlogs() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getBlogs',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      bloglist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        var date = DateTime.parse(_data['data'][i]['created_at'].toString());
        var today = DateTime.now();
        var diff = today.difference(date);
        var message_time = '';
        if (diff.inDays == 0) {
          var hours = diff.inHours;
          if (hours == 0) {
            message_time = '${diff.inMinutes} mins ago';
          } else {
            message_time = '$hours hour ago';
          }
        } else {
          if (diff.inDays < 7) {
            message_time = '${diff.inDays} days ago';
          } else if (diff.inDays <= 28) {
            message_time = '${(diff.inDays / 7).floor()} weeks ago';
          } else if (diff.inDays > 28) {
            message_time = '${(diff.inDays / 28).floor()} month ago';
          }
        }
        if (i == 0) {
          firstimage = _data['data'][i]['image_path'].toString();
          firstdescription = _data['data'][i]['description'].toString();
          firstdate = message_time;
          firsttitle = _data['data'][i]['title'].toString();
          firstid = _data['data'][i]['id'].toString();
        } else {
          bloglist.add(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EachBlog(
                      title: _data['data'][i]['title'].toString(),
                      description: _data['data'][i]['description'].toString(),
                      id: _data['data'][i]['id'].toString(),
                      time: message_time,
                    ),
                  ),
                );
              },
              child: BlogCard(
                image: _data['data'][i]['image_path'].toString(),
                title: _data['data'][i]['title'].toString(),
                date: message_time,
              ),
            ),
          );
        }
      }
      setState(() {
        isLoading = true;
      });
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getSearchedBlogs(value) async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.GET,
        url: 'https://dashboard.cheftarunabirla.com/getSearchedBlogs/${value}');

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      bloglist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        var date = DateTime.parse(_data['data'][i]['created_at'].toString());
        var today = DateTime.now();
        var diff = today.difference(date);
        var message_time = '';
        if (diff.inDays == 0) {
          var hours = diff.inHours;
          if (hours == 0) {
            message_time = '${diff.inMinutes} mins ago';
          } else {
            message_time = '$hours hour ago';
          }
        } else {
          if (diff.inDays < 7) {
            message_time = '${diff.inDays} days ago';
          } else if (diff.inDays <= 28) {
            message_time = '${(diff.inDays / 7).floor()} weeks ago';
          } else if (diff.inDays > 28) {
            message_time = '${(diff.inDays / 28).floor()} month ago';
          }
        }
        if (i == 0) {
          firstimage = _data['data'][i]['image_path'].toString();
          firstdescription = _data['data'][i]['description'].toString();
          firstdate = message_time;
          firsttitle = _data['data'][i]['title'].toString();
          firstid = _data['data'][i]['id'].toString();
        } else {
          bloglist.add(
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EachBlog(
                      title: _data['data'][i]['title'].toString(),
                      description: _data['data'][i]['description'].toString(),
                      id: _data['data'][i]['id'].toString(),
                      time: message_time,
                    ),
                  ),
                );
              },
              child: BlogCard(
                image: _data['data'][i]['image_path'].toString(),
                title: _data['data'][i]['title'].toString(),
                date: message_time,
              ),
            ),
          );
        }
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
        getBlogs();
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
      getBlogs();
    }
    // _filterRetriever();
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Palette.shadowColor.withOpacity(0.1),
                          blurRadius: 5.0, // soften the shadow
                          spreadRadius: 0.0, //extend the shadow
                          offset: const Offset(
                            0.0, // Move to right 10  horizontally
                            0.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          isLoading = false;
                        });
                        if (value.isNotEmpty) {
                          // setState(() {
                          // firsttitle = '';
                          // firstdate = '';
                          // firstdescription = '';
                          // firstimage = '';
                          // isLoading = false;
                          // });
                          getSearchedBlogs(value);
                        } else {
                          // setState(() {
                          // firsttitle = '';
                          // firstdate = '';
                          // firstdescription = '';
                          // firstimage = '';
                          // isLoading = false;
                          // });
                          getBlogs();
                        }
                      },
                      // controller: phoneController,
                      style: const TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                      ),
                      autofocus: false,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          MdiIcons.magnify,
                        ),
                        counterText: "",
                        hintText: "Search Blogs",
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
                  height: 24.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 24.0,
                  ),
                  child: firsttitle.isEmpty
                      ? Center(
                          child: Container(),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EachBlog(
                                  title: firsttitle,
                                  description: firstdescription,
                                  id: firstid,
                                  time: firstdate,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.shadowColor.withOpacity(0.1),
                                  blurRadius: 5.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://dashboard.cheftarunabirla.com$firstimage',
                                      // placeholder: (context, url) =>
                                      //     const Center(
                                      //         child:
                                      //             CircularProgressIndicator()),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                      // fadeOutDuration:
                                      //     const Duration(seconds: 1),
                                      // fadeInDuration:
                                      //     const Duration(seconds: 1),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 10.0),
                                  child: Text(
                                    '$firsttitle',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 10.0),
                                  child: Text(
                                    '${firstdescription.substring(0, 80)}...',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14.0,
                                        fontFamily: 'EuclidCircularA Regular'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 24.0,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        firstdate,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Palette.contrastColor,
                                            fontSize: 14.0,
                                            fontFamily:
                                                'EuclidCircularA Regular'),
                                      ),
                                      SizedBox(
                                        width: 6.0,
                                      ),
                                      // Icon(
                                      //   MdiIcons.circle,
                                      //   size: 8.0,
                                      //   color: Palette.contrastColor,
                                      // ),
                                      // SizedBox(
                                      //   width: 6.0,
                                      // ),
                                      // Text(
                                      //   'Food',
                                      //   textAlign: TextAlign.center,
                                      //   style: TextStyle(
                                      //       color: Palette.contrastColor,
                                      //       fontSize: 14.0,
                                      //       fontFamily: 'EuclidCircularA Regular'),
                                      // ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                for (var i in bloglist) i
              ],
            ),
    );
  }
}

class BlogCard extends StatelessWidget {
  final String image;
  final String title;
  final String date;
  const BlogCard({
    Key? key,
    required this.image,
    required this.title,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Palette.shadowColor.withOpacity(0.1),
              blurRadius: 5.0, // soften the shadow
              spreadRadius: 0.0, //extend the shadow
              offset: const Offset(
                0.0, // Move to right 10  horizontally
                0.0, // Move to bottom 10 Vertically
              ),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedNetworkImage(
                    imageUrl: 'https://dashboard.cheftarunabirla.com$image',
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fadeOutDuration: const Duration(seconds: 1),
                    fadeInDuration: const Duration(seconds: 1),
                    fit: BoxFit.cover,
                    // width: 144.0,
                    height: 70.0,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: Text(
                        '${title.length > 50 ? title.substring(0, 50) : title}..',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Medium'),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$date',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Palette.contrastColor,
                                fontSize: 12.0,
                                fontFamily: 'EuclidCircularA Regular'),
                          ),
                          SizedBox(
                            width: 6.0,
                          ),
                        ],
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
