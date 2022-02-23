import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/cart.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/pages/share_pdf.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';
import 'open_image.dart';

class EachBook extends StatefulWidget {
  final String name;
  final String description;
  final String id;
  final String price;
  final String discount_price;
  final String category;
  final String pdflink;
  const EachBook({
    Key? key,
    required this.name,
    required this.description,
    required this.id,
    required this.price,
    required this.category,
    required this.discount_price,
    required this.pdflink,
  }) : super(key: key);

  @override
  _EachBookState createState() => _EachBookState();
}

class _EachBookState extends State<EachBook> {
  List<Widget> list = [];
  bool isLoading = false;
  bool isSubscriptionLoading = false;
  bool isPDFLoading = false;
  int subscribed = 0;
  String user_id = '';
  int number_of_pdf = 0;
  String pdf_url = '';
  int counter = 0;
  String remotePDFpath = "";
  String imagePath = "";
  String name = '';
  String description = '';
  String price = '';
  String discount_price = '';
  String category = '';
  String pdflink = '';
  // final GlobalKey<ExpansionTile> expansionTile = new GlobalKey();

  Future<File> createFileOfPdfUrl() async {
    Completer<File> completer = Completer();
    print("Start download file from internet!");
    try {
      // "https://berlin2017.droidcon.cod.newthinking.net/sites/global.droidcon.cod.newthinking.net/files/media/documents/Flutter%20-%2060FPS%20UI%20of%20the%20future%20%20-%20DroidconDE%2017.pdf";
      // final url = "https://pdfkit.org/docs/guide.pdf";
      final url = imagePath;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      print("Download files");
      print("${dir.path}/$filename");
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;
    await Share.shareFiles(
      [remotePDFpath],
      text:
          '${name} to explore more books click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

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

  Future<void> updateBookSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/updateBookSubscription/${widget.id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      setState(() => isSubscriptionLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getBookSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/getBookSubscription/${widget.id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        var start_date = DateTime.now();
        var end_date = DateTime.parse(_data['data'][0]['end_date'].toString());
        var diff = end_date.difference(start_date);
        // print(diff.inDays);
        if (diff.inDays <= 0) {
          subscribed = 0;
          updateBookSubscription();
        } else if (diff.inDays > 0) {
          subscribed = 1;
          number_of_pdf = 1;
          pdf_url = pdflink;
        }
      } else {
        subscribed = 0;
        setState(() => isSubscriptionLoading = true);
      }
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getBookImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      imagePath =
          'https://dashboard.cheftarunabirla.com${_data['data'][0]['path'].toString()}';
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OpenImage(
                          url:
                              'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}')),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 300.0,
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}',
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    fadeOutDuration: const Duration(seconds: 1),
                    fadeInDuration: const Duration(seconds: 1),
                    fit: BoxFit.cover,
                    // width: double.infinity,
                    height: 300.0,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
      getBookSubscription();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getBook() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    // print(user_id);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/getUserBookbyId/${widget.id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      setState(() {
        name = _data['data'][0]['title'].toString();
        description = _data['data'][0]['description'].toString();
        category = _data['data'][0]['category'].toString();
        price = _data['data'][0]['price'].toString();
        discount_price = _data['data'][0]['discount_price'].toString();
        pdflink = _data['data'][0]['pdf'].toString();
      });
      // setState(() {
      //   isLoading = true;
      // });
      getBookImages();
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        if (widget.name.isEmpty) {
          getBook();
        } else {
          name = widget.name;
          description = widget.description;
          price = widget.price;
          discount_price = widget.discount_price;
          category = widget.category;
          pdflink = widget.pdflink;
          getBookImages();
        }
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
      if (widget.name.isEmpty) {
        getBook();
      } else {
        name = widget.name;
        description = widget.description;
        price = widget.price;
        discount_price = widget.discount_price;
        category = widget.category;
        pdflink = widget.pdflink;
        getBookImages();
      }
    }
    super.initState();

    Provider.of<CartItems>(context, listen: false)
        .current_cart
        .forEach((element) {
      if (element.id == widget.id && element.category == 'book') {
        counter++;
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
          '',
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
                  color: Colors.black,
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
              createFileOfPdfUrl().then((f) {
                setState(() {
                  remotePDFpath = f.path;
                });
                _onShare(context);
              });
            },
            icon: const Icon(
              MdiIcons.shareVariant,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: !isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: list.isEmpty
                              ? Container(
                                  height: 0.0,
                                )
                              : SizedBox(
                                  height: 300.0,
                                  width: double.infinity,
                                  child: !isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : CarouselSlider(
                                          options: CarouselOptions(
                                            aspectRatio: 1 / 1,
                                            autoPlay: true,
                                            viewportFraction: 0.9,
                                            autoPlayAnimationDuration:
                                                const Duration(
                                                    milliseconds: 1000),
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
                                ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: Text(
                            '${name} (${category})',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                                fontFamily: 'CenturyGothic'),
                          ),
                        ),
                        SizedBox(
                          height: subscribed == 0
                              ? 0.0
                              : !isPDFLoading
                                  ? 0.0
                                  : number_of_pdf == 0
                                      ? 0.0
                                      : pdf_url.isEmpty
                                          ? 0.0
                                          : 15.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: subscribed == 0
                              ? Container()
                              : !isPDFLoading
                                  ? Container()
                                  : number_of_pdf == 0
                                      ? Container()
                                      : pdf_url.isEmpty
                                          ? Container()
                                          : GestureDetector(
                                              onTap: () => {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SharePdf(path: pdf_url),
                                                  ),
                                                )
                                              },
                                              child: Container(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 8.0,
                                                      horizontal: 20.0),
                                                  child: Text(
                                                    'Open PDF',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontFamily:
                                                          'EuclidCircularA Regular',
                                                    ),
                                                  ),
                                                ),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                    color:
                                                        Palette.secondaryColor),
                                              ),
                                            ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: ExpansionTile(
                              // key: expansionTile,
                              tilePadding: const EdgeInsets.symmetric(
                                  vertical: 00.0, horizontal: 0.0),
                              title: new Text('hello'),
                              collapsedBackgroundColor: Palette.appBarColor,
                              backgroundColor: Palette.appBarColor,
                              children: <Widget>[
                                new ListTile(
                                  title: const Text('One'),
                                  onTap: () {
                                    // setState(() {
                                    //   this.foos = 'One';
                                    //   expansionTile.currentState.collapse();
                                    // });
                                  },
                                ),
                                new ListTile(
                                  title: const Text('Two'),
                                  onTap: () {
                                    // setState(() {
                                    //   this.foos = 'Two';
                                    //   expansionTile.currentState.collapse();
                                    // });
                                  },
                                ),
                                new ListTile(
                                  title: const Text('Three'),
                                  onTap: () {
                                    // setState(() {
                                    //   this.foos = 'Three';
                                    //   expansionTile.currentState.collapse();
                                    // });
                                  },
                                ),
                              ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: Text(
                            description,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontFamily: 'EuclidCircularA Regular'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: subscribed == 1
                      ? category == 'free'
                          ? 0.0
                          : 0.0
                      : 70.0,
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
                  child: subscribed == 1
                      ? Container()
                      : category == 'free'
                          ? Container()
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 24.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (counter >= 1) {
                                      Provider.of<CartItems>(context,
                                              listen: false)
                                          .current_cart
                                          .removeWhere((element) =>
                                              element.id == widget.id &&
                                              element.category == 'book');
                                      context.read<CartItems>().setCart(
                                          Provider.of<CartItems>(context,
                                                  listen: false)
                                              .current_cart);
                                      updateCart(widget.id, 'remove');
                                      counter = 0;
                                    } else {
                                      var newObject = Cart(
                                        id: widget.id,
                                        category: 'book',
                                      );
                                      Provider.of<CartItems>(context,
                                              listen: false)
                                          .current_cart
                                          .add(newObject);
                                      context.read<CartItems>().setCart(
                                          Provider.of<CartItems>(context,
                                                  listen: false)
                                              .current_cart);
                                      updateCart(widget.id, 'add');
                                      counter = 1;
                                    }
                                  });
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
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              counter == 0
                                                  ? 'Add to cart'
                                                  : 'Remove',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 0.0),
                                          child: VerticalDivider(
                                            width: 2.0,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Rs ${discount_price}',
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
