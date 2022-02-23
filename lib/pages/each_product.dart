import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/pages/product_buy_page.dart';
import 'package:taruna_birla/pages/reviews_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';
import 'open_image.dart';

class EachProduct extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String category;
  final String price;
  final String discount_price;
  const EachProduct(
      {Key? key,
      required this.id,
      required this.name,
      required this.description,
      required this.category,
      required this.price,
      required this.discount_price})
      : super(key: key);

  @override
  _EachProductState createState() => _EachProductState();
}

class _EachProductState extends State<EachProduct> {
  bool isLoading = false;
  List<Widget> list = [];
  String remotePDFpath = "";
  String imagePath = "";
  String name = '';
  String description = '';
  String category = '';
  String price = '';
  String discount_price = '';
  String user_id = '';

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
          '${name} (${category}) to explore more products click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
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
        'category': 'product',
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

  Future<void> getProductImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/getProductImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // list.add(
      //   'All',
      // );
      imagePath =
          'https://dashboard.cheftarunabirla.com${_data['data'][0]['path'].toString()}';
      for (var i = 0; i < _data['data'].length; i++) {
        // list.add(
        //   _data['data'][i]['name'].toString(),
        // );
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
                    // placeholder: (context, url) =>
                    //     const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    // fadeOutDuration: const Duration(seconds: 1),
                    // fadeInDuration: const Duration(seconds: 1),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300.0,
                  ),
                  // Image.network(
                  //   'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}',
                  //   fit: BoxFit.cover,
                  //   height: 300.0,
                  //   alignment: Alignment.topCenter,
                  // ),
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isLoading = true);
      // getProducts();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getProduct() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    // print(user_id);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/getUserProductById/${widget.id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      setState(() {
        name = _data['data'][0]['name'].toString();
        description = _data['data'][0]['description'].toString();
        category = _data['data'][0]['category'].toString();
        price = _data['data'][0]['price'].toString();
        discount_price = _data['data'][0]['discount_price'].toString();
      });
      // setState(() {
      //   isLoading = true;
      // });
      getProductImages();
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        // print(widget.discount_price);
        // print(widget.price);
        if (widget.name.isEmpty) {
          getProduct();
        } else {
          name = widget.name;
          // description = widget.description;
          category = widget.category;
          price = widget.price.isEmpty ? '0' : widget.price;
          discount_price =
              widget.discount_price.isEmpty ? '0' : widget.discount_price;
          getProductImages();
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
        getProduct();
      } else {
        name = widget.name;
        // description = widget.description;
        category = widget.category;
        price = widget.price.isEmpty ? '0' : widget.price;
        discount_price =
            widget.discount_price.isEmpty ? '0' : widget.discount_price;
        getProductImages();
      }
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
      body: SafeArea(
        child: Column(
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
                              height: 200.0,
                              width: double.infinity,
                              child: !isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 1 / 1,
                                        autoPlay: false,
                                        viewportFraction: 0.9,
                                        autoPlayAnimationDuration:
                                            const Duration(milliseconds: 1000),
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
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${name}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Palette.secondaryColor,
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              child: Text(
                                '${category}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontFamily: 'CenturyGothic'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: price == discount_price ? 0.0 : 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: price == discount_price
                          ? const Text('')
                          : Text(
                              price,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Regular',
                                  decoration: TextDecoration.lineThrough),
                            ),
                      // int.parse(discount_price) >= int.parse(price)
                      //     ? Container()
                      //     : Row(
                      //         children: [
                      //           Text(
                      //             'Rs. ${discount_price}',
                      //             style: const TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 18.0,
                      //               fontFamily: 'EuclidCircularA Medium',
                      //             ),
                      //           ),
                      //           const SizedBox(
                      //             width: 20.0,
                      //           ),
                      //           Text(
                      //             'Rs. ${price}',
                      //             style: const TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 18.0,
                      //               fontFamily: 'EuclidCircularA Regular',
                      //               decoration: TextDecoration.lineThrough,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Html(
                      data: widget.description.toString(),
                      // data: '<p> Hello </p>',
                      style: {
                        'p': Style(
                          fontSize: FontSize(16.0),
                          padding: EdgeInsets.all(0.0),
                        ),
                        'body': Style(
                          padding: EdgeInsets.all(0.0),
                        )
                      },
                      customImageRenders: {
                        networkSourceMatcher(domains: ["flutter.dev"]):
                            (context, attributes, element) {
                          return FlutterLogo(size: 36);
                        },
                        networkSourceMatcher(domains: ["mydomain.com"]):
                            networkImageRender(
                          headers: {"Custom-Header": "some-value"},
                          altWidget: (alt) => Text(alt ?? ""),
                          loadingWidget: () => Text("Loading..."),
                        ),
                        // On relative paths starting with /wiki, prefix with a base url
                        (attr, _) =>
                                attr["src"] != null &&
                                attr["src"]!.startsWith("/wiki"):
                            networkImageRender(
                                mapUrl: (url) =>
                                    "https://upload.wikimedia.org" + url!),
                        // Custom placeholder image for broken links
                        networkSourceMatcher():
                            networkImageRender(altWidget: (_) => FlutterLogo()),
                      },
                      onLinkTap: (url, _, __, ___) {
                        print("Opening $url...");
                      },
                      onImageTap: (src, _, __, ___) {
                        print(src);
                      },
                      onImageError: (exception, stackTrace) {
                        print(exception);
                      },
                      onCssParseError: (css, messages) {
                        print("css that errored: $css");
                        print("error messages:");
                        messages.forEach((element) {
                          print(element);
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: Text(
                        description,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Regular'),
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewsPage(
                                  category: 'product', item_id: widget.id),
                            ),
                          )
                        },
                        child: Container(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 23.0, horizontal: 15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Reviews',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontFamily: 'EuclidCircularA Medium',
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 0.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.6),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                  ],
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
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 24.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductBuyPage(
                              price: discount_price, id: widget.id)),
                    );
                  },
                  child: Container(
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
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Buy Now',
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
                                'Rs ${discount_price}',
                                style: const TextStyle(
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
            ),
          ],
        ),
      ),
    );
  }
}
