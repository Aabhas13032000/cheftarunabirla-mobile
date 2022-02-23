import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/cart_item.dart';
import 'package:taruna_birla/config/coupon.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/models/current_index.dart';
import 'package:taruna_birla/pages/cart_payment_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import '../main.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
  String user_id = '';
  String phoneNumber = '';
  List cartlist = [];
  double total_price = 0;
  double total_course_price = 0;
  double total_book_price = 0;
  double total_product_price = 0;
  double actual_total_price = 0;
  double actual_total_cartvise = 0;
  double actual_total_product = 0;
  double actual_total_book = 0;
  double actual_total_course = 0;
  double payable_price = 0;
  int number_of_courses = 0;
  int number_of_products = 0;
  int number_of_books = 0;
  int number_of_ebooks = 0;
  List price = [];
  List quantity = [];
  List couponList = [];
  String course_coupon = '';
  String product_coupon = '';
  String book_coupon = '';
  String cartvise_coupon = '';
  int course_dis = 0;
  int book_dis = 0;
  int product_dis = 0;
  int cartvise_dis = 0;
  final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  int shippingCharges = 0;
  // List<Cart> cart = [];

  Future<void> updateCart(id, value, category) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? 'https://dashboard.cheftarunabirla.com/users/addtocart'
          : 'https://dashboard.cheftarunabirla.com/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': category,
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // print(_data);
      setState(() {
        total_price = 0;
        total_course_price = 0;
        total_book_price = 0;
        total_product_price = 0;
        actual_total_price = 0;
        actual_total_cartvise = 0;
        actual_total_product = 0;
        actual_total_book = 0;
        actual_total_course = 0;
        number_of_courses = 0;
        number_of_products = 0;
        number_of_books = 0;
        price = [];
        quantity = [];
        couponList = [];
        course_coupon = '';
        product_coupon = '';
        book_coupon = '';
        cartvise_coupon = '';
        course_dis = 0;
        book_dis = 0;
        product_dis = 0;
        cartvise_dis = 0;
        number_of_ebooks = 0;
        payable_price = 0;
      });
      getUserCart();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> updateCartQuantity(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? 'https://dashboard.cheftarunabirla.com/users/updatecartquantity'
          : 'https://dashboard.cheftarunabirla.com/users/subtractcartquantity',
      body: {
        'id': id,
      },
    );

    bool _status = _updateCart['status'];
    var _data = _updateCart['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // print(_data);
      setState(() {
        total_price = 0;
        total_course_price = 0;
        total_book_price = 0;
        total_product_price = 0;
        actual_total_price = 0;
        actual_total_cartvise = 0;
        actual_total_product = 0;
        actual_total_book = 0;
        actual_total_course = 0;
        number_of_courses = 0;
        number_of_products = 0;
        number_of_books = 0;
        price = [];
        quantity = [];
        couponList = [];
        course_coupon = '';
        product_coupon = '';
        book_coupon = '';
        cartvise_coupon = '';
        course_dis = 0;
        book_dis = 0;
        product_dis = 0;
        cartvise_dis = 0;
        number_of_ebooks = 0;
        payable_price = 0;
      });
      getUserCart();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> _showErrorDialog(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          // content: SingleChildScrollView(
          //   child: ListBody(
          //     children: const <Widget>[
          //       Text('Contact Support for this !!'),
          //       Text('Call on: 8619810907'),
          //     ],
          //   ),
          // ),
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

  void openBottompopup() {
    if (number_of_products > 0 || number_of_ebooks > 0) {
      if (pincodeController.text != '311001') {
        payable_price = actual_total_price + shippingCharges;
      } else {
        payable_price = actual_total_price;
      }
    } else {
      payable_price = actual_total_price;
    }
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: 200,
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 30.0,
                                width: 30.0,
                                decoration: BoxDecoration(
                                  color: Palette.secondaryColor,
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // const Padding(
                      //   padding: EdgeInsets.symmetric(
                      //       vertical: 0.0, horizontal: 24.0),
                      //   child: Text(
                      //     'Address',
                      //     style: TextStyle(
                      //       color: Colors.black,
                      //       fontSize: 16.0,
                      //       fontFamily: 'EuclidCircularA Medium',
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 20.0,
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       top: 0.0,
                      //       right: 24.0,
                      //       left: 24.0,
                      //       bottom: MediaQuery.of(context).viewInsets.bottom),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //       color: Colors.black12,
                      //       border:
                      //           Border.all(color: Colors.black38, width: 1.0),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: const Color(0xffFFF0D0).withOpacity(0.0),
                      //           blurRadius: 30.0, // soften the shadow
                      //           spreadRadius: 0.0, //extend the shadow
                      //           offset: const Offset(
                      //             0.0, // Move to right 10  horizontally
                      //             0.0, // Move to bottom 10 Vertically
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     child: TextField(
                      //       onChanged: (value) {},
                      //       keyboardType: TextInputType.multiline,
                      //       minLines: 1,
                      //       maxLines: 5,
                      //       controller: addressController,
                      //       style: const TextStyle(
                      //         fontFamily: 'EuclidCircularA Regular',
                      //       ),
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         prefixIcon: const Icon(
                      //           MdiIcons.mapMarkerOutline,
                      //         ),
                      //         counterText: "",
                      //         hintText: "Enter your address",
                      //         focusColor: Palette.contrastColor,
                      //         focusedBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //               color: Color(0xffffffff),
                      //               width: 1.3,
                      //             ),
                      //             borderRadius: BorderRadius.circular(10.0)),
                      //         enabledBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: Color(0xffffffff), width: 1.0),
                      //             borderRadius: BorderRadius.circular(10.0)),
                      //         contentPadding: const EdgeInsets.symmetric(
                      //             vertical: 8.0, horizontal: 16.0),
                      //         filled: true,
                      //         fillColor: const Color(0xffffffff),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 20.0,
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //       top: 0.0,
                      //       right: 24.0,
                      //       left: 24.0,
                      //       bottom: MediaQuery.of(context).viewInsets.bottom),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //       color: Colors.black12,
                      //       border:
                      //           Border.all(color: Colors.black38, width: 1.0),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: const Color(0xffFFF0D0).withOpacity(0.0),
                      //           blurRadius: 30.0, // soften the shadow
                      //           spreadRadius: 0.0, //extend the shadow
                      //           offset: const Offset(
                      //             0.0, // Move to right 10  horizontally
                      //             0.0, // Move to bottom 10 Vertically
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //     child: TextField(
                      //       onChanged: (value) {
                      //         if (number_of_products > 0 ||
                      //             number_of_ebooks > 0) {
                      //           if (value.length == 6) {
                      //             if (value != '311001') {
                      //               setState(() {
                      //                 payable_price =
                      //                     actual_total_price + shippingCharges;
                      //               });
                      //             } else {
                      //               setState(() {
                      //                 payable_price = actual_total_price;
                      //               });
                      //             }
                      //           } else {
                      //             setState(() {
                      //               payable_price = actual_total_price;
                      //             });
                      //           }
                      //         }
                      //       },
                      //       keyboardType: TextInputType.number,
                      //       inputFormatters: <TextInputFormatter>[
                      //         FilteringTextInputFormatter.digitsOnly
                      //       ],
                      //       controller: pincodeController,
                      //       style: const TextStyle(
                      //         fontFamily: 'EuclidCircularA Regular',
                      //       ),
                      //       autofocus: false,
                      //       decoration: InputDecoration(
                      //         prefixIcon: const Icon(
                      //           MdiIcons.mapMarkerOutline,
                      //         ),
                      //         counterText: "",
                      //         hintText: "Enter your pincode",
                      //         focusColor: Palette.contrastColor,
                      //         focusedBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //               color: Color(0xffffffff),
                      //               width: 1.3,
                      //             ),
                      //             borderRadius: BorderRadius.circular(10.0)),
                      //         enabledBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: Color(0xffffffff), width: 1.0),
                      //             borderRadius: BorderRadius.circular(10.0)),
                      //         contentPadding: const EdgeInsets.symmetric(
                      //             vertical: 8.0, horizontal: 16.0),
                      //         filled: true,
                      //         fillColor: const Color(0xffffffff),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 10.0, horizontal: 24.0),
                      //   child: Column(
                      //     children: [
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           const Text(
                      //             'Shipping Charges',
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 14.0,
                      //               fontFamily: 'EuclidCircularA Medium',
                      //             ),
                      //           ),
                      //           SizedBox(
                      //             width: 10.0,
                      //           ),
                      //           Text(
                      //             'Rs. ${number_of_products > 0 || number_of_ebooks > 0 ? pincodeController.text != '311001' ? shippingCharges : 0 : 0}',
                      //             style: TextStyle(
                      //               color: Palette.secondaryColor,
                      //               fontSize: 14.0,
                      //               fontFamily: 'EuclidCircularA Medium',
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       const SizedBox(
                      //         height: 10.0,
                      //       ),
                      //       const Divider(
                      //         height: 2.0,
                      //         color: Colors.black38,
                      //         indent: 0.0,
                      //       ),
                      //       const SizedBox(
                      //         height: 5.0,
                      //       ),
                      //       Row(
                      //         mainAxisAlignment: MainAxisAlignment.end,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           const Text(
                      //             'Total',
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 16.0,
                      //               fontFamily: 'EuclidCircularA Medium',
                      //             ),
                      //           ),
                      //           SizedBox(
                      //             width: 10.0,
                      //           ),
                      //           Text(
                      //             'Rs. ${payable_price}',
                      //             style: const TextStyle(
                      //               color: Palette.secondaryColor,
                      //               fontSize: 16.0,
                      //               fontFamily: 'EuclidCircularA Medium',
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(
                      //   height: 10.0,
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 24.0),
                        child: GestureDetector(
                          onTap: () {
                            // print('hello');
                            // if (addressController.text.isEmpty) {
                            //   _showErrorDialog('Enter the Address!');
                            //   // final snackBar = SnackBar(
                            //   //   content: const Text('Enter the Address!'),
                            //   //   action: SnackBarAction(
                            //   //     label: 'Undo',
                            //   //     onPressed: () {
                            //   //       // Some code to undo the change.
                            //   //     },
                            //   //   ),
                            //   // );
                            //   //
                            //   // // Find the ScaffoldMessenger in the widget tree
                            //   // // and use it to show a SnackBar.
                            //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            // } else if (pincodeController.text.length < 6) {
                            //   _showErrorDialog('Enter the pincode correctly!');
                            //   // final snackBar = SnackBar(
                            //   //   content: const Text('Enter the pincode correctly!'),
                            //   //   action: SnackBarAction(
                            //   //     label: 'Undo',
                            //   //     onPressed: () {
                            //   //       // Some code to undo the change.
                            //   //     },
                            //   //   ),
                            //   // );
                            //
                            //   // Find the ScaffoldMessenger in the widget tree
                            //   // and use it to show a SnackBar.
                            //   // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            // } else
                            if (phoneNumber.isEmpty) {
                              context.read<CurrentIndex>().setIndex(4);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainContainer(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } else {
                              // if (Platform.isIOS) {
                              //   // Navigator.push(
                              //   //   context,
                              //   //   MaterialPageRoute(
                              //   //     builder: (context) =>
                              //   //         AppleCartPaymentPage(),
                              //   //   ),
                              //   // );
                              //   _openPaymentDialog();
                              // } else {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => CartPaymentPage(
                              //           url:
                              //               'https://dashboard.cheftarunabirla.com/cartsubscription/$total_price/$payable_price/${addressController.text}/$phoneNumber/${pincodeController.text}/$user_id/$number_of_courses'),
                              //     ),
                              //   );
                              // }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CartPaymentPage(
                                    // url:
                                    //     'https://dashboard.cheftarunabirla.com/cartsubscription/$total_price/$payable_price/${addressController.text}/$phoneNumber/${pincodeController.text}/$user_id/$number_of_courses'),
                                    url:
                                        'https://dashboard.cheftarunabirla.com/cartsubscription/$total_price/$payable_price/test/$phoneNumber/311001/$user_id/$number_of_courses',
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Palette.contrastColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xffFFF0D0).withOpacity(0.0),
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
                                children: [
                                  const Expanded(
                                    child: Center(
                                      child: Text(
                                        'Pay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontFamily: 'EuclidCircularA Medium',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
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
                                        'Rs ${payable_price}',
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
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<void> _openPaymentDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Method!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // Text('Please Connect to internet'),
                ElevatedButton(
                    onPressed: () => {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => AppleCartPaymentPage(),
                          //   ),
                          // )
                        },
                    child: const Text('In App Pay')),
                ElevatedButton(
                    onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartPaymentPage(
                                  url:
                                      'https://dashboard.cheftarunabirla.com/cartsubscription/$total_price/$payable_price/${addressController.text}/$phoneNumber/${pincodeController.text}/$user_id/$number_of_courses'),
                            ),
                          )
                        },
                    child: const Text('Razorpay')),
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

  Future<void> getCoupons() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCoupons',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        shippingCharges = int.parse(_data['data'][0]['shipping'].toString());
        for (var i = 0; i < _data['data'].length; i++) {
          if (_data['data'][i]['linked_category'].toString() == 'cartvise') {
            if (total_price >=
                    int.parse(_data['data'][i]['minimum'].toString()) &&
                total_price <=
                    int.parse(_data['data'][i]['maximum'].toString())) {
              cartvise_dis = int.parse(_data['data'][i]['dis'].toString());
              cartvise_coupon = _data['data'][i]['ccode'].toString();
              // print(actual_total_price);
              actual_total_cartvise = total_price -
                  ((total_price *
                          int.parse(_data['data'][i]['dis'].toString())) /
                      100);
            }
          }
          if (_data['data'][i]['linked_category'].toString() == 'product') {
            if (number_of_products >=
                    int.parse(_data['data'][i]['minimum'].toString()) &&
                number_of_products <=
                    int.parse(_data['data'][i]['maximum'].toString())) {
              product_dis = int.parse(_data['data'][i]['dis'].toString());
              product_coupon = _data['data'][i]['ccode'].toString();
              actual_total_product = total_product_price -
                  ((total_product_price *
                          int.parse(_data['data'][i]['dis'].toString())) /
                      100);
              // print(actual_total_price);
            }
          }
          if (_data['data'][i]['linked_category'].toString() == 'course') {
            if (number_of_courses >=
                    int.parse(_data['data'][i]['minimum'].toString()) &&
                number_of_courses <=
                    int.parse(_data['data'][i]['maximum'].toString())) {
              course_dis = int.parse(_data['data'][i]['dis'].toString());
              course_coupon = _data['data'][i]['ccode'].toString();
              actual_total_course = total_course_price -
                  ((total_course_price *
                          int.parse(_data['data'][i]['dis'].toString())) /
                      100);
              // print(actual_total_price);
            }
          }
          if (_data['data'][i]['linked_category'].toString() == 'book') {
            if (number_of_books >=
                    int.parse(_data['data'][i]['minimum'].toString()) &&
                number_of_books <=
                    int.parse(_data['data'][i]['maximum'].toString())) {
              book_dis = int.parse(_data['data'][i]['dis'].toString());
              book_coupon = _data['data'][i]['ccode'].toString();
              actual_total_book = total_book_price -
                  ((total_book_price *
                          int.parse(_data['data'][i]['dis'].toString())) /
                      100);
              // print(actual_total_price);
            }
          }
          couponList.add(
            Coupon(
              id: _data['data'][i]['id'].toString(),
              ccode: _data['data'][i]['ccode'].toString(),
              dis: int.parse(_data['data'][i]['dis'].toString()),
              minimum: int.parse(_data['data'][i]['minimum'].toString()),
              maximum: int.parse(_data['data'][i]['maximum'].toString()),
              category: _data['data'][i]['linked_category'].toString(),
            ),
          );
        }
        if (cartvise_coupon.isNotEmpty) {
          // print(cartvise_dis);
          actual_total_price = ((actual_total_course == 0
                      ? total_course_price
                      : actual_total_course) +
                  (actual_total_product == 0
                      ? total_product_price
                      : actual_total_product) +
                  (actual_total_book == 0
                      ? total_book_price
                      : actual_total_book)) -
              ((((actual_total_course == 0
                              ? total_course_price
                              : actual_total_course) +
                          (actual_total_product == 0
                              ? total_product_price
                              : actual_total_product) +
                          (actual_total_book == 0
                              ? total_book_price
                              : actual_total_book)) *
                      cartvise_dis) /
                  100);
        } else {
          actual_total_price = (actual_total_course == 0
                  ? total_course_price
                  : actual_total_course) +
              (actual_total_product == 0
                  ? total_product_price
                  : actual_total_product) +
              (actual_total_book == 0 ? total_book_price : actual_total_book);
        }
      } else {
        actual_total_product = total_product_price;
        actual_total_book = total_book_price;
        actual_total_course = total_course_price;
        actual_total_price =
            actual_total_product + actual_total_book + actual_total_course;
      }
      // print(actual_total_price);
      // print(actual_total_product);
      // print(actual_total_book);
      // print(actual_total_course);
      // print(total_book_price);
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getUserCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final add = prefs.getString('address') ?? '';
    final pincode = prefs.getString('pincode') ?? '';
    final phonenumber = prefs.getString('phonenumber') ?? '';
    setState(() {
      user_id = userId;
      addressController.text = add;
      pincodeController.text = pincode;
      phoneNumber = phonenumber;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/users/getUserCart/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      cartlist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        total_price = total_price +
            (int.parse(_data['data'][i]['quantity'].toString())) *
                (int.parse(_data['data'][i]['price'].toString()));
        price.add(int.parse(_data['data'][i]['price'].toString()));
        quantity.add(int.parse(_data['data'][i]['quantity'].toString()));
        if (_data['data'][i]['category'].toString() == 'course') {
          total_course_price = total_course_price +
              (int.parse(_data['data'][i]['quantity'].toString())) *
                  (int.parse(_data['data'][i]['price'].toString()));
          number_of_courses++;
          cartlist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              id: _data['data'][i]['course_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: _data['data'][i]['price'].toString(),
              category: _data['data'][i]['category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['item_category'].toString(),
            ),
          );
        }
        if (_data['data'][i]['category'].toString() == 'product') {
          total_product_price = total_product_price +
              (int.parse(_data['data'][i]['quantity'].toString())) *
                  (int.parse(_data['data'][i]['price'].toString()));
          number_of_products++;
          cartlist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              id: _data['data'][i]['product_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: _data['data'][i]['price'].toString(),
              category: _data['data'][i]['category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['item_category'].toString(),
            ),
          );
        }
        if (_data['data'][i]['category'].toString() == 'book') {
          total_book_price = total_book_price +
              (int.parse(_data['data'][i]['quantity'].toString())) *
                  (int.parse(_data['data'][i]['price'].toString()));
          number_of_books++;
          if (_data['data'][i]['item_category'].toString() == 'e_book') {
            number_of_ebooks++;
          }
          cartlist.add(
            CartItem(
              cart_id: _data['data'][i]['id'].toString(),
              id: _data['data'][i]['book_id'].toString(),
              name: _data['data'][i]['name'].toString(),
              price: _data['data'][i]['price'].toString(),
              category: _data['data'][i]['category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              quantity: int.parse(
                _data['data'][i]['quantity'].toString(),
              ),
              item_category: _data['data'][i]['item_category'].toString(),
            ),
          );
        }
      }
      print(number_of_ebooks);
      getCoupons();
      // setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getUserCart();
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
      getUserCart();
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
          'Cart',
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
          : cartlist.isEmpty
              ? const Center(
                  child: Text(
                    'No items in cart right now!!',
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
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Add More +',
                              style: TextStyle(
                                color: Palette.secondaryColor,
                                fontSize: 16.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 00.0, horizontal: 24.0),
                        child: ListView.builder(
                          itemCount: cartlist.length,
                          itemBuilder: (BuildContext context, int index) {
                            // var paying_price
                            String print_coupon = '';
                            int applied_dis = 0;
                            if (cartlist[index].category == 'product') {
                              if (product_coupon.isNotEmpty) {
                                print_coupon =
                                    'Coupon Applied: $product_coupon';
                                applied_dis = product_dis;
                              }
                            } else if (cartlist[index].category == 'course') {
                              if (course_coupon.isNotEmpty) {
                                print_coupon = 'Coupon Applied: $course_coupon';
                                applied_dis = course_dis;
                              }
                            } else if (cartlist[index].category == 'book') {
                              if (book_coupon.isNotEmpty) {
                                print_coupon = 'Coupon Applied: $book_coupon';
                                applied_dis = book_dis;
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5.0,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 80.0,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: Image.network(
                                                  'https://dashboard.cheftarunabirla.com${cartlist[index].image_path}',
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(0.0),
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
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 0.0,
                                                        horizontal: 10.0),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        right:
                                                                            8.0),
                                                                child: Text(
                                                                  cartlist[
                                                                          index]
                                                                      .name
                                                                      .toString(),
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          14.0,
                                                                      fontFamily:
                                                                          'EuclidCircularA Medium'),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              cartlist[index]
                                                                          .category
                                                                          .toString() ==
                                                                      'product'
                                                                  ? ''
                                                                  : '',
                                                              style: TextStyle(
                                                                  color: Palette
                                                                      .contrastColor,
                                                                  fontSize: cartlist[index]
                                                                              .category
                                                                              .toString() ==
                                                                          'product'
                                                                      ? 14.0
                                                                      : 0.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular'),
                                                            )
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Text(
                                                          cartlist[index]
                                                              .category,
                                                          style: const TextStyle(
                                                              color: Palette
                                                                  .contrastColor,
                                                              fontSize: 14.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Regular'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height:
                                          print_coupon.isNotEmpty ? 5.0 : 0.0,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 5.0),
                                      child: Text(
                                        print_coupon.isNotEmpty
                                            ? print_coupon
                                            : '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: print_coupon.isNotEmpty
                                                ? 14.0
                                                : 0.0,
                                            fontFamily:
                                                'EuclidCircularA Regular'),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: cartlist[index].category ==
                                                  'course' ||
                                              cartlist[index].item_category ==
                                                  'e_book'
                                          ? Row(
                                              children: [
                                                Expanded(
                                                  child: print_coupon.isNotEmpty
                                                      ? Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Rs. ${(double.parse(cartlist[index].price.toString()) - ((double.parse(cartlist[index].price.toString()) * applied_dis) / 100)) * int.parse(cartlist[index].quantity.toString())}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      18.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Medium'),
                                                            ),
                                                            const SizedBox(
                                                              width: 5.0,
                                                            ),
                                                            Text(
                                                              '${cartlist[index].price}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular',
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          'Rs. ${cartlist[index].price * cartlist[index].quantity}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium'),
                                                        ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      Provider.of<CartItems>(
                                                              context,
                                                              listen: false)
                                                          .current_cart
                                                          .removeWhere((element) =>
                                                              element.id ==
                                                                  cartlist[
                                                                          index]
                                                                      .id &&
                                                              element.category ==
                                                                  cartlist[
                                                                          index]
                                                                      .category);
                                                      context
                                                          .read<CartItems>()
                                                          .setCart(Provider.of<
                                                                      CartItems>(
                                                                  context,
                                                                  listen: false)
                                                              .current_cart);
                                                      updateCart(
                                                          cartlist[index].id,
                                                          'remove',
                                                          cartlist[index]
                                                              .category);
                                                      isLoading = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Palette
                                                            .secondaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0)),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5.0,
                                                              horizontal: 8.0),
                                                      child: Text(
                                                        'Remove',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14.0,
                                                            fontFamily:
                                                                'EuclidCircularA Regular'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Expanded(
                                                  child: print_coupon.isNotEmpty
                                                      ? Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Rs. ${(double.parse(cartlist[index].price.toString()) - ((double.parse(cartlist[index].price.toString()) * applied_dis) / 100)) * int.parse(cartlist[index].quantity.toString())}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      18.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Medium'),
                                                            ),
                                                            const SizedBox(
                                                              width: 5.0,
                                                            ),
                                                            Text(
                                                              '${cartlist[index].price}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular',
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough),
                                                            ),
                                                          ],
                                                        )
                                                      : Text(
                                                          'Rs. ${double.parse(cartlist[index].price.toString()) * cartlist[index].quantity}',
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 18.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Medium'),
                                                        ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    if (cartlist[index]
                                                            .quantity <=
                                                        1) {
                                                      Provider.of<CartItems>(
                                                              context,
                                                              listen: false)
                                                          .current_cart
                                                          .removeWhere((element) =>
                                                              element.id ==
                                                                  cartlist[
                                                                          index]
                                                                      .id &&
                                                              element.category ==
                                                                  cartlist[
                                                                          index]
                                                                      .category);
                                                      context
                                                          .read<CartItems>()
                                                          .setCart(Provider.of<
                                                                      CartItems>(
                                                                  context,
                                                                  listen: false)
                                                              .current_cart);
                                                      updateCart(
                                                          cartlist[index].id,
                                                          'remove',
                                                          cartlist[index]
                                                              .category);
                                                    } else {
                                                      updateCartQuantity(
                                                          cartlist[index]
                                                              .cart_id,
                                                          'subtract');
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 30.0,
                                                    width: 30.0,
                                                    decoration: BoxDecoration(
                                                      color: Palette
                                                          .secondaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        MdiIcons.minus,
                                                        color: Colors.white,
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text(
                                                  cartlist[index]
                                                      .quantity
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 16.0,
                                                      fontFamily:
                                                          'EuclidCircularA Medium'),
                                                ),
                                                const SizedBox(
                                                  width: 10.0,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                    updateCartQuantity(
                                                        cartlist[index].cart_id,
                                                        'add');
                                                  },
                                                  child: Container(
                                                    height: 30.0,
                                                    width: 30.0,
                                                    decoration: BoxDecoration(
                                                      color: Palette
                                                          .secondaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50.0),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 20.0,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
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
                            color: Palette.shadowColor.withOpacity(0.0),
                            blurRadius: 30.0, // soften the shadow
                            spreadRadius: 0.0, //extend the shadow
                            offset: const Offset(
                              0.0, // Move to right 10  horizontally
                              0.0, // Move to bottom 10 Vertically
                            ),
                          ),
                        ],
                      ),
                      child: cartlist.isEmpty
                          ? const Center()
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 24.0),
                              child: GestureDetector(
                                onTap: () {
                                  openBottompopup();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Palette.contrastColor,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffFFF0D0)
                                            .withOpacity(0.0),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              'Proceed',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Padding(
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
                                              'Rs ${actual_total_price == 0 ? total_price : actual_total_price}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
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
    );
  }
}
