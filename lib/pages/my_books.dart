import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/book.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';
import 'each_book.dart';

class MyBooks extends StatefulWidget {
  const MyBooks({Key? key}) : super(key: key);

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  List list = [];
  bool isLoading = false;
  String user_id = '';

  Future<void> updateCart(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? 'https://dashboard.cheftarunabirla.com/users/addtocart'
          : 'https://dashboard.cheftarunabirla.com/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': 'course',
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      // data loaded
      print(_data);
    } else {
      print('Something went wrong.');
    }
  }

  void _onShare(BuildContext context) async {
    final ByteData bytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = await new File('${tempDir.path}/image.jpg').create();
    file.writeAsBytesSync(list);
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareFiles(
      ['${file.path}'],
      text:
          'To explore more products and courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> getUserCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/getUserBooks/${user_id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      for (var i = 0; i < _data['data'].length; i++) {
        var item_category = _data['data'][i]['category'].toString();
        // list.add(
        //
        // );
        list.add(
          Book(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['sub_category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            pdflink: _data['data'][i]['pdf'].toString(),
            count: int.parse(
              _data['data'][i]['count'].toString(),
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
        getUserCourses();
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
      getUserCourses();
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
            color: Colors.white,
            size: 18.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Books',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: 'EuclidCircularA Medium',
          ),
        ),
        backgroundColor: Palette.appBarColor,
        elevation: 10.0,
        shadowColor: const Color(0xffFFF0D0).withOpacity(0.2),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  // _saveFilter();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartPage(),
                    ),
                  );
                },
                icon: const Icon(
                  MdiIcons.shoppingOutline,
                  color: Colors.white,
                ),
              ),
              Positioned(
                top: 20,
                right: 10,
                child: context.watch<CartItems>().current_cart.isNotEmpty
                    ? Container(
                        height: 10.0,
                        width: 10.0,
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(50.0)),
                      )
                    : const Center(),
              )
            ],
          ),
          IconButton(
            onPressed: () {
              // _saveFilter();
              _onShare(context);
            },
            icon: const Icon(
              MdiIcons.shareVariant,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
              child: SizedBox(
                // height: 20.0,
                child: !isLoading
                    ? const Text(
                        'Loading...',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'EuclidCircularA Regular',
                        ),
                      )
                    : list.length == 0
                        ? Center(
                            child: Text(
                              Platform.isIOS
                                  ? 'No Books'
                                  : 'Purchase some books first!!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
                              return GridView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: constraints.maxWidth < 576
                                      ? 2
                                      : constraints.maxWidth < 768
                                          ? 3
                                          : constraints.maxWidth < 992
                                              ? 4
                                              : 6,
                                  childAspectRatio: constraints.maxWidth < 576
                                      ? 0.75
                                      : constraints.maxWidth < 768
                                          ? 0.8
                                          : constraints.maxWidth < 992
                                              ? 0.8
                                              : constraints.maxWidth < 1024
                                                  ? 0.7
                                                  : constraints.maxWidth < 1220
                                                      ? 0.7
                                                      : 0.9,
                                  mainAxisSpacing: 18.0,
                                  crossAxisSpacing: 18.0,
                                ),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  // print(counter);
                                  return Container(
                                    // height: 230.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Palette.shadowColor
                                              .withOpacity(0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EachBook(
                                                  id: list[index].id,
                                                  name: list[index].title,
                                                  category:
                                                      list[index].category,
                                                  description:
                                                      list[index].description,
                                                  price: list[index].price,
                                                  discount_price: list[index]
                                                      .discount_price,
                                                  pdflink: list[index].pdflink,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    'https://dashboard.cheftarunabirla.com${list[index].image_path}',
                                                // placeholder: (context, url) =>
                                                //     const Center(child: CircularProgressIndicator()),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                                // fadeOutDuration: const Duration(seconds: 1),
                                                // fadeInDuration: const Duration(seconds: 1),
                                                fit: BoxFit.cover,
                                                height: 192.0,
                                                width: double.infinity,
                                              ),
                                              // Image.network(
                                              //   'https://dashboard.cheftarunabirla.com${list[index].image_path}',
                                              //   height: 192.0,
                                              //   fit: BoxFit.cover,
                                              //   width: double.infinity,
                                              //   // alignment: Alignment.topCenter,
                                              // ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
