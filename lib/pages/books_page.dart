import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/book.dart';
import 'package:taruna_birla/config/cart.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/pages/each_book.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({Key? key}) : super(key: key);

  @override
  _BooksPageState createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  List booklist = [];
  bool isLoading = false;
  int offset = 0;
  String user_id = '';

  Future<void> updateCart(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? 'https://dashboard.cheftarunabirla.com/users/addtocart'
          : 'https://dashboard.cheftarunabirla.com/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': 'book',
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // print(_data);
      if (value == 'add') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CartPage(),
          ),
        );
      }
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getUserBook/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data['data'].length);
    if (_status) {
      booklist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        booklist.add(
          Book(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            count: _data['data'][i]['count'],
            pdflink: _data['data'][i]['pdf'].toString() == 'null'
                ? ''
                : _data['data'][i]['pdf'].toString(),
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
        getBooks();
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
      getBooks();
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
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 18.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Books',
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
      ),
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0),
              child: Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        int counter = 0;
                        Provider.of<CartItems>(context, listen: false)
                            .current_cart
                            .forEach((element) {
                          if (element.id == booklist[index].id &&
                              element.category == 'book') {
                            counter++;
                          }
                        });
                        return Container(
                          margin: EdgeInsets.fromLTRB(
                              index == 0 ? 24.0 : 0.0, 0.0, 20.0, 0.0),
                          width: 320.0,
                          // height: 400.0,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EachBook(
                                            name: booklist[index].title,
                                            description:
                                                booklist[index].description,
                                            id: booklist[index].id,
                                            price: booklist[index].price,
                                            category: booklist[index].category,
                                            discount_price:
                                                booklist[index].discount_price,
                                            pdflink: booklist[index].pdflink),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            'https://dashboard.cheftarunabirla.com${booklist[index].image_path}',
                                        // placeholder: (context, url) =>
                                        //     const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                        // fadeOutDuration: const Duration(seconds: 1),
                                        // fadeInDuration: const Duration(seconds: 1),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                      // Image.network(
                                      //   'https://dashboard.cheftarunabirla.com${booklist[index].image_path}',
                                      //   // height: 140.0,
                                      //   fit: BoxFit.cover,
                                      //   width: double.infinity,
                                      // ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: ClipRRect(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EachBook(
                                                  name: booklist[index].title,
                                                  description: booklist[index]
                                                      .description,
                                                  id: booklist[index].id,
                                                  price: booklist[index].price,
                                                  category:
                                                      booklist[index].category,
                                                  discount_price:
                                                      booklist[index]
                                                          .discount_price,
                                                  pdflink:
                                                      booklist[index].pdflink,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${booklist[index].title} (${booklist[index].category})',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 20.0,
                                                fontFamily: 'CenturyGothic'),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15.0,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => EachBook(
                                                    name: booklist[index].title,
                                                    description: booklist[index]
                                                        .description,
                                                    id: booklist[index].id,
                                                    price:
                                                        booklist[index].price,
                                                    category: booklist[index]
                                                        .category,
                                                    discount_price:
                                                        booklist[index]
                                                            .discount_price,
                                                    pdflink: booklist[index]
                                                        .pdflink),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            '${booklist[index].description.substring(0, 250)}...',
                                            style: const TextStyle(
                                                color: Colors.black38,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Regular'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Rs ${booklist[index].discount_price}',
                                          style: const TextStyle(
                                            color: Palette.contrastColor,
                                            fontSize: 16.0,
                                            fontFamily:
                                                'EuclidCircularA Medium',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (booklist[index].category ==
                                              'free') {
                                            print('its free');
                                          } else {
                                            setState(() {
                                              if (counter >= 1) {
                                                Provider.of<CartItems>(context,
                                                        listen: false)
                                                    .current_cart
                                                    .removeWhere((element) =>
                                                        element.id ==
                                                            booklist[index]
                                                                .id &&
                                                        element.category ==
                                                            'book');
                                                context
                                                    .read<CartItems>()
                                                    .setCart(
                                                        Provider.of<CartItems>(
                                                                context,
                                                                listen: false)
                                                            .current_cart);
                                                updateCart(booklist[index].id,
                                                    'remove');
                                              } else {
                                                var newObject = Cart(
                                                  id: booklist[index].id,
                                                  category: 'book',
                                                );
                                                Provider.of<CartItems>(context,
                                                        listen: false)
                                                    .current_cart
                                                    .add(newObject);
                                                context
                                                    .read<CartItems>()
                                                    .setCart(
                                                        Provider.of<CartItems>(
                                                                context,
                                                                listen: false)
                                                            .current_cart);
                                                updateCart(
                                                    booklist[index].id, 'add');
                                              }
                                            });
                                          }
                                        },
                                        child: counter == 0
                                            ? Container(
                                                height: double.infinity,
                                                child: Center(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Text(
                                                        'Add',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.0,
                                                          fontFamily:
                                                              'EuclidCircularA Regular',
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 16.0,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Palette.contrastColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(0.0),
                                                    bottomLeft:
                                                        Radius.circular(0.0),
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                height: double.infinity,
                                                child: Center(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12.0,
                                                          fontFamily:
                                                              'EuclidCircularA Regular',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Palette.contrastColor,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(0.0),
                                                    bottomLeft:
                                                        Radius.circular(0.0),
                                                    bottomRight:
                                                        Radius.circular(10.0),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      itemCount: booklist.length,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
//
// class BookCard extends StatelessWidget {
//   final String name;
//   final String image;
//   final String description;
//   final double marginleft;
//   final double marginRight;
//   final String price;
//   final String id;
//   const BookCard(
//       {Key? key,
//       required this.name,
//       required this.image,
//       required this.description,
//       required this.marginleft,
//       required this.marginRight,
//       required this.price,
//       required this.id})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(marginleft, 0.0, marginRight, 0.0),
//       width: 320.0,
//       // height: 400.0,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10.0),
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Color(0xffFFF0D0).withOpacity(0.9),
//             blurRadius: 30.0, // soften the shadow
//             spreadRadius: 0.0, //extend the shadow
//             offset: const Offset(
//               4.0, // Move to right 10  horizontally
//               8.0, // Move to bottom 10 Vertically
//             ),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 8,
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(8.0),
//                 child: Image.network(
//                   'https://dashboard.cheftarunabirla.com${image}',
//                   // height: 140.0,
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 5,
//             child: ClipRRect(
//               child: Padding(
//                 padding: const EdgeInsets.all(10.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 24.0,
//                           fontFamily: 'CenturyGothic'),
//                     ),
//                     SizedBox(
//                       height: 15.0,
//                     ),
//                     Text(
//                       '${description.substring(0, 250)}...',
//                       style: TextStyle(
//                           color: Colors.black38,
//                           fontSize: 16.0,
//                           fontFamily: 'EuclidCircularA Regular'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 1,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Expanded(
//                   child: Center(
//                     child: GestureDetector(
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => EachBook(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Rs ${price}',
//                         style: TextStyle(
//                           color: Palette.contrastColor,
//                           fontSize: 16.0,
//                           fontFamily: 'EuclidCircularA Medium',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Container(
//                     height: double.infinity,
//                     child: Center(
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: const [
//                           Text(
//                             'Add to cart',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14.0,
//                               fontFamily: 'EuclidCircularA Regular',
//                             ),
//                           ),
//                           // Icon(
//                           //   Icons.add,
//                           //   color: Colors.white,
//                           //   size: 16.0,
//                           // )
//                         ],
//                       ),
//                     ),
//                     decoration: const BoxDecoration(
//                       color: Palette.contrastColor,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(8.0),
//                         topRight: Radius.circular(0.0),
//                         bottomLeft: Radius.circular(0.0),
//                         bottomRight: Radius.circular(10.0),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
