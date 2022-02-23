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
import 'package:taruna_birla/config/order.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/pages/cart_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  List list = [];
  bool isLoading = false;
  String user_id = '';

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

  Future<void> getUserOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/getUserOrders/${user_id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data);
    if (_status) {
      // data loaded
      for (var i = 0; i < _data['data'].length; i++) {
        var item_category = _data['data'][i]['category'].toString();
        list.add(
          Orders(
            id: _data['data'][i]['id'].toString(),
            name: _data['data'][i]['name'].toString(),
            date: _data['data'][i]['date_purchased'].toString(),
            item_id: item_category == 'course'
                ? _data['data'][i]['course_id'].toString()
                : item_category == 'product'
                    ? _data['data'][i]['product_id'].toString()
                    : item_category == 'book'
                        ? _data['data'][i]['book_id'].toString()
                        : '',
            category: _data['data'][i]['category'].toString(),
            paid_price: _data['data'][i]['paid_price'].toString(),
            price: _data['data'][i]['price'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            order_image: _data['data'][i]['order_image'].toString(),
            quantity: int.parse(
                _data['data'][i]['quantity'].toString() == 'null'
                    ? '0'
                    : _data['data'][i]['quantity'].toString()),
            payment_status: _data['data'][i]['payment_status'].toString(),
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
        getUserOrders();
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
      getUserOrders();
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
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontFamily: 'EuclidCircularA Medium',
          ),
        ),
        backgroundColor: Palette.appBarColor,
        elevation: 10.0,
        shadowColor: Palette.shadowColor.withOpacity(0.1),
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
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : list.isEmpty
              ? const Center(
                  child: Text(
                    'No orders right now!!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontFamily: 'EuclidCircularA Medium',
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 00.0, horizontal: 24.0),
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
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
                                      color:
                                          Palette.shadowColor.withOpacity(0.1),
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
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: CachedNetworkImage(
                                            imageUrl: list[index]
                                                        .order_image
                                                        .toString() !=
                                                    'null'
                                                ? list[index].order_image
                                                : 'https://dashboard.cheftarunabirla.com${list[index].image_path}',
                                            // placeholder: (context, url) =>
                                            //     const Center(child: CircularProgressIndicator()),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            // fadeOutDuration: const Duration(seconds: 1),
                                            // fadeInDuration: const Duration(seconds: 1),
                                            fit: BoxFit.cover,
                                            height: 80.0,
                                            width: double.infinity,
                                          ),
                                          // Image.network(
                                          //
                                          //   height: 80.0,
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 0.0,
                                                      horizontal: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${list[index].name}',
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium'),
                                                  ),
                                                  const SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Rs. ${list[index].price}',
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 16.0,
                                                            fontFamily:
                                                                'EuclidCircularA Medium'),
                                                      ),
                                                      Text(
                                                        '${list[index].date.toString().substring(0, 10)}',
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 12.0,
                                                            fontFamily:
                                                                'EuclidCircularA Regular'),
                                                      ),
                                                      // GestureDetector(
                                                      //   onTap: () {
                                                      //
                                                      //   },
                                                      //   child: Container(
                                                      //     decoration: BoxDecoration(
                                                      //         color: Palette
                                                      //             .contrastColor,
                                                      //         borderRadius:
                                                      //         BorderRadius
                                                      //             .circular(
                                                      //             5.0)),
                                                      //     child: Padding(
                                                      //       padding:
                                                      //       const EdgeInsets
                                                      //           .symmetric(
                                                      //           vertical:
                                                      //           5.0,
                                                      //           horizontal:
                                                      //           8.0),
                                                      //       child: Text(
                                                      //         'Remove',
                                                      //         style: const TextStyle(
                                                      //             color: Colors
                                                      //                 .white,
                                                      //             fontSize:
                                                      //             14.0,
                                                      //             fontFamily:
                                                      //             'EuclidCircularA Regular'),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
