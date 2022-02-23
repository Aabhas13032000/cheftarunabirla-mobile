//Dart Packages
import 'dart:io';

//Flutter Third Party
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
//Application
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/current_index.dart';
import 'package:taruna_birla/models/selected_value.dart';
import 'package:taruna_birla/pages/gallery_page.dart';
import 'package:taruna_birla/pages/my_books.dart';
import 'package:taruna_birla/pages/video_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';
import 'package:taruna_birla/widgets/widgets.dart';

import 'books_page.dart';
import 'each_book.dart';
import 'each_course.dart';
import 'each_product.dart';
import 'my_courses.dart';
import 'open_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Widget> list = [];
  bool isLoading = false;

  Future<void> getSlider() async {
    // print('hello getslider');
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getSliderByCategory/all',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      for (var i = 0; i < _data['data'].length; i++) {
        if (_data['data'][i]['category'].toString() == 'video') {
          list.add(
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Palette.shadowColor.withOpacity(0.1),
                    blurRadius: 5.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      -0.0, // Move to bottom 10 Vertically
                    ),
                  ),
                ],
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              height: 200.0,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPage(
                        url: _data['data'][i]['path'].toString(),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://dashboard.cheftarunabirla.com${_data['data'][i]['thumbnail'].toString()}',
                        // placeholder: (context, url) =>
                        //     const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        // fadeOutDuration: const Duration(seconds: 1),
                        // fadeInDuration: const Duration(seconds: 1),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.topCenter,
                      ),
                      Container(
                        height: 50.0,
                        width: 50.0,
                        decoration: BoxDecoration(
                          color: Palette.secondaryColor,
                          borderRadius: BorderRadius.circular(50.0),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xff000000).withOpacity(0.2),
                              blurRadius: 10.0, // soften the shadow
                              spreadRadius: 0.0, //extend the shadow
                              offset: const Offset(
                                0.0, // Move to right 10  horizontally
                                0.0, // Move to bottom 10 Vertically
                              ),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          list.add(
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Palette.shadowColor.withOpacity(0.1),
                    blurRadius: 5.0, // soften the shadow
                    spreadRadius: 0.0, //extend the shadow
                    offset: const Offset(
                      0.0, // Move to right 10  horizontally
                      -0.0, // Move to bottom 10 Vertically
                    ),
                  ),
                ],
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  if (_data['data'][i]['linked_array'].toString() ==
                      'no_linked_item') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OpenImage(
                              url:
                                  'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}')),
                    );
                  } else if (_data['data'][i]['linked_array'].toString() ==
                      'multiple') {
                    if (_data['data'][i]['linked_category'].toString() ==
                        'course') {
                      context.read<CurrentIndex>().setIndex(2);
                      Provider.of<SelectedValue>(context, listen: false)
                          .setSelectedValue('All');
                    } else if (_data['data'][i]['linked_category'].toString() ==
                        'product') {
                      context.read<CurrentIndex>().setIndex(3);
                      Provider.of<SelectedValue>(context, listen: false)
                          .setSelectedValue('All');
                    } else if (_data['data'][i]['linked_category'].toString() ==
                        'book') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BooksPage(),
                        ),
                      );
                    }
                  } else {
                    if (_data['data'][i]['linked_category'].toString() ==
                        'course') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachCourse(
                            id: _data['data'][i]['linked_array'].toString(),
                            title: '',
                            category: '',
                            description: '',
                            price: '',
                            discount_price: '',
                            days: '',
                            promo_video: '',
                          ),
                        ),
                      );
                    } else if (_data['data'][i]['linked_category'].toString() ==
                        'product') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachProduct(
                            id: _data['data'][i]['linked_array'].toString(),
                            name: '',
                            description: '',
                            category: '',
                            price: '',
                            discount_price: '',
                          ),
                        ),
                      );
                    } else if (_data['data'][i]['linked_category'].toString() ==
                        'book') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EachBook(
                            name: '',
                            description: '',
                            id: _data['data'][i]['linked_array'].toString(),
                            price: '',
                            category: '',
                            discount_price: '',
                            pdflink: '',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: SizedBox(
                    width: double.infinity,
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
                      width: double.infinity,
                      height: double.infinity,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
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
        getSlider();
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
    // if (kIsWeb) {
    getSlider();
    // } else {
    //   _filterRetriever();
    // }
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: list.isEmpty ? 0.0 : 30.0,
          ),
          Center(
            child: list.isEmpty
                ? Container(
                    height: 0.0,
                  )
                : LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return SizedBox(
                        height: constraints.maxWidth < 576
                            ? 200.0
                            : constraints.maxWidth < 768
                                ? 350.0
                                : constraints.maxWidth < 992
                                    ? 450.0
                                    : 550.0,
                        width: double.infinity,
                        child: !isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  viewportFraction: 0.9,
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 1500),
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
                      );
                    },
                  ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 24.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyCourses(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.contrastColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 0.0),
                            child: Text(
                              'My courses',
                              style: TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyBooks(),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Palette.contrastColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 0.0),
                            child: Text(
                              'My Books',
                              style: TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          const SizedBox(
            height: 20.0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 24.0,
            ),
            child: Text(
              'Find your favourite\ncourses here',
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 24.0,
                color: Palette.secondaryColor,
              ),
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          // const SizedBox(
          //   height: 182.0,
          //   // color: Colors.red,
          //   child: Courses(),
          // ),
          const Courses(),
          const SizedBox(
            height: 34.0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 24.0,
            ),
            child: Text(
              'Our Store',
              style: TextStyle(
                fontFamily: 'CenturyGothic',
                fontSize: 24.0,
                color: Palette.secondaryColor,
              ),
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          const OurStore(),
          const SizedBox(
            height: 30.0,
          ),
          Container(
            color: Palette.contrastColor,
            child: const Books(),
          ),
          const SizedBox(
            height: 30.0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 24.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Our Gallery',
                  style: TextStyle(
                    fontFamily: 'CenturyGothic',
                    fontSize: 24.0,
                    color: Palette.secondaryColor,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryPage(),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 24.0,
                    color: Palette.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25.0,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 0.0,
              horizontal: 24.0,
            ),
            child: Gallery(),
          ),
          const SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
