import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'apple_cart_payment_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool isLoading = false;
  String phoneNumber = '';
  String wallet = '';
  final moneyController = TextEditingController();

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phonenumber = prefs.getString('phonenumber') ?? '';
    // print();
    setState(() {
      phoneNumber = phonenumber;
    });

    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/getUserDetails/$phoneNumber',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        wallet = _data['data'][0]['wallet'].toString();
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
        getUserDetails();
      }
    } on SocketException catch (_) {
      print('not connected');
      _showMyDialog();
    }
  }

  @override
  void initState() {
    // _filterRetriever();
    if (!kIsWeb) {
      _filterRetriever();
    } else {
      getUserDetails();
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
          'Wallet',
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
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  Container(
                    width: double.infinity,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 12.0),
                      child: Text(
                        'Rs. $wallet',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                            fontFamily: 'EuclidCircularA Medium'),
                      ),
                    ),
                  ),
                  // const SizedBox(
                  //   height: 20.0,
                  // ),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10.0),
                  //     color: Colors.white,
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: const Color(0xffFFF0D0).withOpacity(0.5),
                  //         blurRadius: 30.0, // soften the shadow
                  //         spreadRadius: 0.0, //extend the shadow
                  //         offset: const Offset(
                  //           0.0, // Move to right 10  horizontally
                  //           0.0, // Move to bottom 10 Vertically
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  //   child: TextField(
                  //     maxLength: 6,
                  //     keyboardType: TextInputType.number,
                  //     inputFormatters: <TextInputFormatter>[
                  //       FilteringTextInputFormatter.digitsOnly
                  //     ],
                  //     controller: moneyController,
                  //     style: const TextStyle(
                  //         fontFamily: 'EuclidCircularA Regular'),
                  //     autofocus: false,
                  //     decoration: InputDecoration(
                  //       prefixIcon: const Icon(
                  //         MdiIcons.currencyInr,
                  //       ),
                  //       counterText: "",
                  //       hintText: "Enter price to add",
                  //       focusedBorder: OutlineInputBorder(
                  //           borderSide: const BorderSide(
                  //             color: Palette.secondaryColor,
                  //             width: 1.3,
                  //           ),
                  //           borderRadius: BorderRadius.circular(8.0)),
                  //       enabledBorder: OutlineInputBorder(
                  //           borderSide: const BorderSide(
                  //               color: Color(0xffffffff), width: 1.0),
                  //           borderRadius: BorderRadius.circular(8.0)),
                  //       contentPadding: const EdgeInsets.symmetric(
                  //           vertical: 8.0, horizontal: 16.0),
                  //       filled: true,
                  //       fillColor: const Color(0xffffffff),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      // if(addressController.text.isNotEmpty)
                      // setState(() {
                      //   isLoading = false;
                      // });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppleCartPaymentPage(),
                        ),
                      );
                    },
                    child: Container(
                      height: 48.0,
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
                      child: const Center(
                        child: Text(
                          'Add Money',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Medium',
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
