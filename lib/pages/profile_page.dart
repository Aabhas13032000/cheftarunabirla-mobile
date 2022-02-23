import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/pages/load_web.dart';
import 'package:taruna_birla/pages/my_courses.dart';
import 'package:taruna_birla/pages/my_orders.dart';
import 'package:taruna_birla/pages/user_account.dart';
import 'package:taruna_birla/pages/wallet_page.dart';

import 'login_page.dart';
import 'my_books.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String phoneNumber = '';
  bool isLoading = false;
  RateMyApp? ratemyapp = RateMyApp();
  static const playstoreId = 'com.cheftarunbirla';
  static const appstoreId = 'com.technotwist.tarunaBirla';
  late Widget Function(RateMyApp) builder;
  late final RateMyAppInitializedCallback onInitialized;
  // late final WidgetBuilder builder;

  Future<RateMyAppBuilder> rateMyApp(BuildContext context) async {
    return RateMyAppBuilder(
      onInitialized: (context, ratemyapp) {
        setState(() {
          this.ratemyapp = ratemyapp;
        });
      },
      builder: (context) => ratemyapp == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : builder(ratemyapp!),
      rateMyApp: RateMyApp(
        preferencesPrefix: 'rateMyApp_',
        minDays: 7,
        minLaunches: 10,
        remindDays: 7,
        remindLaunches: 10,
        googlePlayIdentifier: 'com.cheftarunbirla',
        appStoreIdentifier: 'com.technotwist.tarunaBirla',
      ),
    );
  }

  void openRateDialog(BuildContext context) {
    ratemyapp?.showRateDialog(context);
  }

  _filterRetriever() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phonenumber = prefs.getString('phonenumber') ?? '';
    // print();
    setState(() {
      phoneNumber = phonenumber;
    });
    if (!kIsWeb) {
      try {
        final result = await InternetAddress.lookup('cheftarunabirla.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
        }
      } on SocketException catch (_) {
        print('not connected');
        _showMyDialog();
      }
    }
  }

  @override
  void initState() {
    _filterRetriever();
    super.initState();
    initRateMyApp();
  }

  Future<void> initRateMyApp() async {
    await ratemyapp?.init();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (mounted) {
        onInitialized(context, ratemyapp!);
      }
    });
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
      child: phoneNumber.isEmpty
          ? LoginPage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                // const Padding(
                //   padding: EdgeInsets.symmetric(
                //     vertical: 0.0,
                //     horizontal: 24.0,
                //   ),
                //   child: Text(
                //     'Account',
                //     style: TextStyle(
                //       fontFamily: 'CenturyGothic',
                //       fontSize: 20.0,
                //       color: Palette.secondaryColor,
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 10.0,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserAccount(),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.accountOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Text(
                                'Account',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontFamily: 'EuclidCircularA Medium'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 0.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: Platform.isIOS ? 5.0 : 0.0,
                    horizontal: 24.0,
                  ),
                  child: !Platform.isIOS
                      ? Container()
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WalletPage(),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 0.0),
                                    child: CircleAvatar(
                                      backgroundColor: Palette.secondaryColor,
                                      // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                      radius: 25.0,
                                      child: Icon(
                                        MdiIcons.currencyInr,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 0.0, horizontal: 5.0),
                                    child: Text(
                                      'Wallet',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontFamily: 'EuclidCircularA Medium'),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      size: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                const SizedBox(
                  height: 0.0,
                ),
                // const Padding(
                //   padding: EdgeInsets.symmetric(
                //     vertical: 0.0,
                //     horizontal: 24.0,
                //   ),
                //   child: Text(
                //     'Dashboard',
                //     style: TextStyle(
                //       fontFamily: 'CenturyGothic',
                //       fontSize: 20.0,
                //       color: Palette.secondaryColor,
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 10.0,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrders(),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.cartOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'My Orders',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                  // SizedBox(
                                  //   width: 10.0,
                                  // ),
                                  // Container(
                                  //   // width: 20.0,
                                  //   height: 20.0,
                                  //   child: Center(
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           vertical: 0.0, horizontal: 7.8),
                                  //       child: Text(
                                  //         '1',
                                  //         style: TextStyle(
                                  //           color: Colors.white,
                                  //           fontFamily: 'EuclidCircularA Regular',
                                  //           fontSize: 12.0,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.green,
                                  //       borderRadius:
                                  //           BorderRadius.circular(100.0)),
                                  // )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.playCircleOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'My Courses',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                  // SizedBox(
                                  //   width: 10.0,
                                  // ),
                                  // Container(
                                  //   // width: 20.0,
                                  //   height: 20.0,
                                  //   child: Center(
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           vertical: 0.0, horizontal: 7.8),
                                  //       child: Text(
                                  //         '1',
                                  //         style: TextStyle(
                                  //           color: Colors.white,
                                  //           fontFamily: 'EuclidCircularA Regular',
                                  //           fontSize: 12.0,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.green,
                                  //       borderRadius:
                                  //           BorderRadius.circular(100.0)),
                                  // )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.bookOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'My Books',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                  // SizedBox(
                                  //   width: 10.0,
                                  // ),
                                  // Container(
                                  //   // width: 20.0,
                                  //   height: 20.0,
                                  //   child: Center(
                                  //     child: Padding(
                                  //       padding: const EdgeInsets.symmetric(
                                  //           vertical: 0.0, horizontal: 7.8),
                                  //       child: Text(
                                  //         '1',
                                  //         style: TextStyle(
                                  //           color: Colors.white,
                                  //           fontFamily: 'EuclidCircularA Regular',
                                  //           fontSize: 12.0,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  //   decoration: BoxDecoration(
                                  //       color: Colors.green,
                                  //       borderRadius:
                                  //           BorderRadius.circular(100.0)),
                                  // )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadWeb(
                              url: 'https://www.cheftarunabirla.com/about-us/'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.informationVariant,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'About Us',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      rateMyApp(context);
                      ratemyapp?.showRateDialog(context);
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.starOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Rate Us',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LoadWeb(url: 'https://linktr.ee/cheftarunabirla'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.phone,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Contact Us',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //     vertical: 5.0,
                //     horizontal: 24.0,
                //   ),
                //   child: Container(
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(10.0),
                //       color: Colors.white,
                //       boxShadow: [
                //         BoxShadow(
                //           color: Color(0xffFFF0D0).withOpacity(0.6),
                //           blurRadius: 30.0, // soften the shadow
                //           spreadRadius: 0.0, //extend the shadow
                //           offset: const Offset(
                //             4.0, // Move to right 10  horizontally
                //             8.0, // Move to bottom 10 Vertically
                //           ),
                //         ),
                //       ],
                //     ),
                //     child: Row(
                //       crossAxisAlignment: CrossAxisAlignment.center,
                //       children: [
                //         Expanded(
                //           flex: 2,
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(
                //                 vertical: 10.0, horizontal: 0.0),
                //             child: CircleAvatar(
                //               backgroundColor: Palette.secondaryColor,
                //               // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                //               radius: 25.0,
                //               child: Icon(
                //                 MdiIcons.power,
                //                 color: Colors.white,
                //               ),
                //             ),
                //           ),
                //         ),
                //         Expanded(
                //           flex: 5,
                //           child: Padding(
                //             padding: const EdgeInsets.symmetric(
                //                 vertical: 0.0, horizontal: 5.0),
                //             child: Row(
                //               children: [
                //                 Text(
                //                   'Log-out',
                //                   style: TextStyle(
                //                       color: Colors.black,
                //                       fontSize: 16.0,
                //                       fontFamily: 'EuclidCircularA Medium'),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //         Expanded(
                //           flex: 1,
                //           child: Padding(
                //             padding: const EdgeInsets.all(5.0),
                //             child: Icon(
                //               Icons.arrow_forward_ios,
                //               size: 18.0,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 20.0,
                // ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadWeb(
                              url: 'https://www.cheftarunabirla.com/faq/'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.commentQuestionOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: const [
                                  Text(
                                    'FAQ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoadWeb(
                              url: 'https://www.cheftarunabirla.com/feedback/'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.messageTextOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: const [
                                  Text(
                                    'Feedback',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadWeb(
                              url:
                                  'https://www.cheftarunabirla.com/privacy-policy-2/'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.bookLockOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: const [
                                  Text(
                                    'Privacy Policy',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5.0,
                    horizontal: 24.0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoadWeb(
                              url: 'https://www.cheftarunabirla.com/tnc/'),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 0.0),
                              child: CircleAvatar(
                                backgroundColor: Palette.secondaryColor,
                                // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                                radius: 25.0,
                                child: Icon(
                                  MdiIcons.shieldLockOutline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 5.0),
                              child: Row(
                                children: const [
                                  Text(
                                    'Terms & Conditions',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontFamily: 'EuclidCircularA Medium'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 18.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                )
              ],
            ),
    );
  }
}
