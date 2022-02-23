//Dart Packages
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

//Flutter Third-Party Packages
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
//Application Files
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/models/selected_value.dart';
import 'package:taruna_birla/pages/blog_page.dart';
import 'package:taruna_birla/pages/cart_page.dart';
import 'package:taruna_birla/pages/course_page.dart';
import 'package:taruna_birla/pages/home_page.dart';
import 'package:taruna_birla/pages/profile_page.dart';
import 'package:taruna_birla/pages/shop_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config/cart.dart';
import 'constant_function.dart';
import 'models/models.dart';

//Main Function
Future<void> main() async {
  //Firebase initialisation
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp();
    }
  }
  //Provider Definition
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CurrentIndex()),
      // ChangeNotifierProvider(create: (_) => ProductCategories()),
      // ChangeNotifierProvider(create: (_) => CourseCategories()),
      ChangeNotifierProvider(create: (_) => CartItems()),
      ChangeNotifierProvider(create: (_) => SelectedValue()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> blockScreenRecording() async {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
  }

  @override
  void initState() {
    super.initState();
    blockScreenRecording();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return MaterialApp(
      title: 'Taruna Birla',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Palette.scaffoldColor,
      ),
      home: Material(
        child: kIsWeb
            ? const MainContainer()
            : AnimatedSplashScreen(
                splash: Image.asset(
                  'assets/images/splash.jpeg',
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                nextScreen: const MainContainer(),
                splashTransition: SplashTransition.fadeTransition,
                splashIconSize: double.infinity,
                curve: Curves.easeIn,
                duration: 2000,
              ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainContainer extends StatefulWidget {
  const MainContainer({Key? key}) : super(key: key);

  @override
  _MainContainerState createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  //Local Variables
  bool isLoading = false;
  int _pState = 0;
  int _cState = 0;
  //Local Variables
  bool initialized = false;
  bool error = false;
  bool isCartLoading = false;
  List cart = [];
  // List productCategories = [];
  // List courseCategories = [];
  String user_id = '';
  String token = '';
  String phoneNumber = '';

  //Package Info
  PackageInfo _packageInfo = PackageInfo(
    appName: '',
    packageName: '',
    version: '',
    buildNumber: '',
  );

  //Screens Array
  final screens = [
    const HomePage(),
    const BlogPage(),
    const CoursePage(),
    const ShopPage(),
    const ProfilePage(),
  ];

  //Constant Function Object
  var constantFunctions = ConstantFunction();

  //Get Cart Function
  Future<void> getCart() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/users/getCart/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      // data loaded
      cart.clear();
      // productCategories.clear();
      // courseCategories.clear();
      // for (var i = 0; i < _data['product_categories'].length; i++) {
      //   productCategories.add(
      //     ProductCategory(
      //       id: _data['product_categories'][i]['id'].toString(),
      //       name: _data['product_categories'][i]['name'].toString(),
      //     ),
      //   );
      // }
      // for (var i = 0; i < _data['course_categories'].length; i++) {
      //   courseCategories.add(
      //     CourseCategory(
      //       id: _data['course_categories'][i]['id'].toString(),
      //       name: _data['course_categories'][i]['name'].toString(),
      //       image_path: _data['course_categories'][i]['path'].toString(),
      //     ),
      //   );
      // }
      for (var i = 0; i < _data['cart'].length; i++) {
        if (_data['cart'][i]['category'].toString() == 'product') {
          cart.add(Cart(
            id: _data['cart'][i]['product_id'].toString(),
            category: _data['cart'][i]['category'].toString(),
          ));
        }
        if (_data['cart'][i]['category'].toString() == 'course') {
          cart.add(Cart(
            id: _data['cart'][i]['course_id'].toString(),
            category: _data['cart'][i]['category'].toString(),
          ));
        }
        if (_data['cart'][i]['category'].toString() == 'book') {
          cart.add(Cart(
            id: _data['cart'][i]['book_id'].toString(),
            category: _data['cart'][i]['category'].toString(),
          ));
        }
      }
      context.read<CartItems>().setCart(cart);
      // context.read<ProductCategories>().setProductCategories(productCategories);
      // context.read<CourseCategories>().setCourseCategories(courseCategories);
      setState(() => isCartLoading = true);
      checkVersion();
    } else {
      // print('Something went wrong.');
    }
  }

  //Save Token Function
  Future<void> saveToken(String token) async {
    Map<String, dynamic> _saveDeviceTokenData = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: 'https://dashboard.cheftarunabirla.com/users/create_user',
      body: {
        'token': token,
      },
    );

    bool _status = _saveDeviceTokenData['status'];
    var _data = _saveDeviceTokenData['data'];

    if (_status) {
      // print(_data);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      if (_data['message'].toString() != 'some_error_occured') {
        prefs.setString('user_id', _data['message'].toString());
        setState(() {
          user_id = _data['message'].toString();
        });
      }
      getCart();
    } else {
      // print('Something went wrong while saving token.');
    }
  }

  // Check User Info Function
  Future<void> checkUserInfo() async {
    Map<String, dynamic> _saveDeviceTokenData = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: 'https://dashboard.cheftarunabirla.com/users/checkUserInfo',
      body: {
        'token': token,
        'phoneNumber': phoneNumber,
      },
    );

    bool _status = _saveDeviceTokenData['status'];
    var _data = _saveDeviceTokenData['data'];

    if (_status) {
      print(_data);
      if (_data['message'].toString() == 'user_dont_match') {
        _showMyErrorDialog();
      } else {
        getCart();
        // cart.clear();
        // productCategories.clear();
        // courseCategories.clear();
        // for (var i = 0; i < _data['product_categories'].length; i++) {
        //   productCategories.add(
        //     ProductCategory(
        //       id: _data['product_categories'][i]['id'].toString(),
        //       name: _data['product_categories'][i]['name'].toString(),
        //     ),
        //   );
        // }
        // for (var i = 0; i < _data['course_categories'].length; i++) {
        //   courseCategories.add(
        //     CourseCategory(
        //       id: _data['course_categories'][i]['id'].toString(),
        //       name: _data['course_categories'][i]['name'].toString(),
        //       image_path: _data['course_categories'][i]['path'].toString(),
        //     ),
        //   );
        // }
        // for (var i = 0; i < _data['cart'].length; i++) {
        //   if (_data['cart'][i]['category'].toString() == 'product') {
        //     cart.add(Cart(
        //       id: _data['cart'][i]['product_id'].toString(),
        //       category: _data['cart'][i]['category'].toString(),
        //     ));
        //   }
        //   if (_data['cart'][i]['category'].toString() == 'course') {
        //     cart.add(Cart(
        //       id: _data['cart'][i]['course_id'].toString(),
        //       category: _data['cart'][i]['category'].toString(),
        //     ));
        //   }
        //   if (_data['cart'][i]['category'].toString() == 'book') {
        //     cart.add(Cart(
        //       id: _data['cart'][i]['book_id'].toString(),
        //       category: _data['cart'][i]['category'].toString(),
        //     ));
        //   }
        // }
        // context.read<CartItems>().setCart(cart);
        // context
        //     .read<ProductCategories>()
        //     .setProductCategories(productCategories);
        // context.read<CourseCategories>().setCourseCategories(courseCategories);
        // setState(() => isCartLoading = true);
      }
      checkVersion();
    } else {
      // print('Something went wrong while saving token.');
    }
  }

  //Show error dialog for login
  Future<void> _showMyErrorDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Looks like you already have an account running on another device!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Logout from this device !!'),
                // Text('Call on: 8619810907'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => logout(),
              child: const Text('logout'),
            ),
          ],
        );
      },
    );
  }

  //Logout Function
  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('phonenumber', '');
    prefs.setString('user_id', '');
    saveToken(token);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainContainer(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  // Define an async function to initialize FlutterFire
  void initializeFlutterFire() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedToken = prefs.getString('token') ?? '';
    String savedUserId = prefs.getString('user_id') ?? '';
    String savedPhoneNumber = prefs.getString('phonenumber') ?? '';
    if (savedToken.isNotEmpty) {
      // saveToken(token);
      setState(() {
        user_id = savedUserId;
        token = savedToken;
        phoneNumber = savedPhoneNumber;
      });
      if (phoneNumber.isNotEmpty) {
        // print('hello');
        checkUserInfo();
      } else {
        getCart();
      }
    } else {
      // if (!kIsWeb) {
      String? _token;
      try {
        setState(() {
          initialized = true;
        });
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        // if (!kIsWeb) {
        _token = await messaging.getToken();
        if (_token != null) {
          saveToken(_token);
        }
        // } else {
        //   NotificationSettings settings = await messaging.requestPermission(
        //     alert: true,
        //     announcement: false,
        //     badge: true,
        //     carPlay: false,
        //     criticalAlert: false,
        //     provisional: false,
        //     sound: true,
        //   );
        //
        //   print('User granted permission: ${settings.authorizationStatus}');
        //   _token = await messaging.getToken(
        //     vapidKey:
        //         "BOMRALI1_zWixzo7J0K8eyQJfyDH5nacSQkfw6v9f6IRaxp_1rRl1sYcskKqryEu9kFcygjShvp8DFuiXGYVwqU",
        //   );
        //   if (_token != null) {
        //     saveToken(_token);
        //   }
        // }
      } catch (e) {
        setState(() {
          error = true;
        });
      }
      // } else {
      //   DateTime now = DateTime.now();
      //   String isoDate = now.toIso8601String();
      //   Random random = Random();
      //   int randomNumber = random.nextInt(100000) + 1000000;
      //   String token = isoDate + randomNumber.toString();
      //   saveToken(token);
      // }
    }
  }

  //Check Version Function
  Future<void> checkVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/check_version',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    if (_status) {
      if (_data['version'] != _packageInfo.version) {
        constantFunctions.updateApplicationDialog(context);
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isLoading = true;
        });
      }
      // data loaded
    } else {
      print('Something went wrong.');
    }
  }

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Sharing Function
  void _onShare(BuildContext context) async {
    final ByteData bytes = await rootBundle.load('assets/images/logo.png');
    final Uint8List list = bytes.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.jpg').create();
    file.writeAsBytesSync(list);
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareFiles(
      [(file.path)],
      text:
          'To explore more products and courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  //Open Whatsapp
  openwhatsapp() async {
    var whatsapp = "+918619810907";
    var whatsappURl_android = "whatsapp://send?phone=" + whatsapp + "";
    var whatappURL_ios = "https://wa.me/$whatsapp";
    if (Platform.isIOS) {
      // for iOS phone only
      if (await canLaunch(whatappURL_ios)) {
        await launch(whatappURL_ios, forceSafariVC: false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp not installed")));
      }
    } else {
      // android , web
      if (await canLaunch(whatsappURl_android)) {
        await launch(whatsappURl_android);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: new Text("whatsapp not installed")));
      }
    }
  }

  //Go back to home page
  changetab(index) {
    context.watch<CurrentIndex>().setIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    _cState = context.watch<CurrentIndex>().current_index;
    return WillPopScope(
      onWillPop: () async {
        setState(() {
          context.read<CurrentIndex>().setIndex(_pState);
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/images/white_logo.png',
            width: 70.0,
          ),
          centerTitle: false,
          backgroundColor: Palette.appBarColor,
          elevation: 5.0,
          shadowColor: Palette.shadowColor.withOpacity(1.0),
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
                    color: Palette.appBarIconsColor,
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 10,
                  child: !isCartLoading
                      ? const Center()
                      : context.watch<CartItems>().current_cart.isNotEmpty
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
                color: Palette.appBarIconsColor,
              ),
            ),
          ],
        ),
        body: !isCartLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : screens[context.watch<CurrentIndex>().current_index],
        floatingActionButton: GestureDetector(
          onTap: () {
            openwhatsapp();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: const Color(0xff25D366),
              border: Border.all(color: const Color(0xff25D366)),
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
            child: FloatingActionButton(
              onPressed: () {
                openwhatsapp();
              },
              child: const Icon(
                MdiIcons.whatsapp,
                size: 25.0,
                // color: Palette.secondaryColor,
              ),
              backgroundColor: const Color(0xff25D366),
              // focusColor: Palette.contrastColor,
              elevation: 0.0,
            ),
          ),
        ),
        // : const Center(),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Palette.shadowColor.withOpacity(0.06),
                blurRadius: 5.0, // soften the shadow
                spreadRadius: 0.0, //extend the shadow
                offset: const Offset(
                  0.0, // Move to right 10  horizontally
                  -0.0, // Move to bottom 10 Vertically
                ),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: context.watch<CurrentIndex>().current_index,
            onTap: (index) {
              Provider.of<CurrentIndex>(context, listen: false).setIndex(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(MdiIcons.homeVariantOutline),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(MdiIcons.newspaperVariantOutline),
                ),
                label: 'Blogs',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(MdiIcons.playCircleOutline),
                ),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(MdiIcons.storeOutline),
                ),
                label: 'Shop',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(MdiIcons.accountOutline),
                ),
                label: 'Profile',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Palette.contrastColor,
            backgroundColor: const Color(0xffffffff),
            unselectedItemColor: const Color(0xff8e8e8e),
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            elevation: 20.0,
          ),
        ),
      ),
    );
  }
}
