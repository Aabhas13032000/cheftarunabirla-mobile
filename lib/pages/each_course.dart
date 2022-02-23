import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/src/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/cart.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/pages/open_image.dart';
import 'package:taruna_birla/pages/reviews_page.dart';
import 'package:taruna_birla/pages/video_web_player.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';
import 'package:taruna_birla/widgets/load_web_page.dart';
import 'package:taruna_birla/widgets/video_player.dart';
import 'package:taruna_birla/widgets/webviewx_page.dart';
import 'package:taruna_birla/widgets/youtube_player_page.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import 'cart_page.dart';

class EachCourse extends StatefulWidget {
  final String id;
  final String title;
  final String category;
  final String description;
  final String price;
  final String discount_price;
  final String days;
  final String promo_video;
  const EachCourse({
    Key? key,
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.price,
    required this.discount_price,
    required this.days,
    required this.promo_video,
  }) : super(key: key);

  @override
  _EachCourseState createState() => _EachCourseState();
}

class _EachCourseState extends State<EachCourse> {
  List<Widget> list = [];
  List<Widget> videos = [];
  bool isLoading = false;
  bool isSubscriptionLoading = false;
  bool isVideoLoading = false;
  bool isPDFLoading = false;
  int subscribed = 0;
  String user_id = '';
  int counter = 0;
  int number_of_pdf = 0;
  String pdf_url = '';
  String remotePDFpath = "";
  String imagePath = "";
  String title = '';
  String category = '';
  String description = '';
  String price = '';
  String discount_price = '';
  String days = '';
  String promo_video = '';
  String daysLeft = '';

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
          '$title ($category) Watch promo here $promo_video \n\n to explore more courses click on the link given below\n\n👇https://play.google.com/store/apps/details?id=com.cheftarunbirla',
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
        'category': 'course',
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

  Future<void> updateCourseSubscription() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/updateCourseSubscription/${widget.id}/$user_id',
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

  Future<void> getCourseSubscription() async {
    // print('yessss');
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/users/getCourseSubscription/${widget.id}/$user_id',
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
          updateCourseSubscription();
          _showDialog();
        } else if (diff.inDays > 0) {
          subscribed = 1;
          setState(() {
            daysLeft = diff.inDays.toString();
            isSubscriptionLoading = true;
          });
          getCoursePDF();
        }
      } else {
        subscribed = 0;
        setState(() => isSubscriptionLoading = true);
      }
      if (category == 'online') {
        getCourseVideos();
      }
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getCourseVideos() async {
    // print('entered');
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCourseVideos/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      for (var i = 0; i < _data['data'].length; i++) {
        videos.add(
          GestureDetector(
            onTap: () {
              if (subscribed == 1) {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         VideoPage(url: _data['data'][i]['path'].toString()),
                //   ),
                // );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoWebPage(url: _data['data'][i]['path'].toString()),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 24.0,
              ),
              child: Container(
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 23.0, horizontal: 15.0),
                        child: Row(
                          children: [
                            Text(
                              '${_data['data'][i]['name'].toString().length >= 20 ? _data['data'][i]['name'].toString().substring(0, 20) : _data['data'][i]['name'].toString()}...',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 10.0),
                      child: subscribed == 0
                          ? Center()
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: 18.0,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      setState(() => isVideoLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getCourseImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCourseImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      imagePath =
          'https://dashboard.cheftarunabirla.com${_data['data'][0]['path'].toString()}';
      if (promo_video.isNotEmpty) {
        print(promo_video);
        list.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              // child: VideoPlayerPage(
              //   url: promo_video,
              //   fullScreen: false,
              //   page: 'promo',
              // ),
              child: promo_video.contains('youtube')
                  ? YoutubePlayerPage(
                      url: promo_video.split('v=')[1],
                      fullScreen: false,
                    )
                  : promo_video.contains('vimeo')
                      ? kIsWeb
                          ? WebviewXPage(
                              url: promo_video,
                              fullScreen: false,
                            )
                          : LoadWebPage(
                              url: promo_video,
                              fullScreen: false,
                            )
                      : VideoPlayerPage(
                          url: promo_video,
                          fullScreen: false,
                          page: 'promo',
                        ),
            ),
          ),
        );
      }
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OpenImage(
                        url:
                            'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}')),
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
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
      if (category == 'free') {
        setState(() {
          subscribed = 1;
          isSubscriptionLoading = true;
        });
        getCourseVideos();
        getCoursePDF();
      } else {
        getCourseSubscription();
      }
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getCoursePDF() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCoursePdf/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      if (_data['data'].length != 0) {
        number_of_pdf = _data['data'].length;
        pdf_url =
            'https://dashboard.cheftarunabirla.com${_data['data'][0]['pdflink'].toString()}';
      }
      setState(() => isPDFLoading = true);
      // getCourseSubscription();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getCourse() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    setState(() {
      user_id = userId;
    });
    // print(user_id);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url:
          'https://dashboard.cheftarunabirla.com/getUserCourseById/${widget.id}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      setState(() {
        title = _data['data'][0]['title'].toString();
        description = _data['data'][0]['description'].toString();
        category = _data['data'][0]['category'].toString();
        price = _data['data'][0]['price'].toString();
        discount_price = _data['data'][0]['discount_price'].toString();
        days = _data['data'][0]['days'].toString();
        promo_video = _data['data'][0]['promo_video'].toString();
      });
      // setState(() {
      //   isLoading = true;
      // });
      getCourseImages();
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        if (widget.title.isEmpty) {
          getCourse();
        } else {
          title = widget.title;
          description = widget.description;
          category = widget.category;
          price = widget.price;
          discount_price = widget.discount_price;
          days = widget.days;
          promo_video = widget.promo_video;
          getCourseImages();
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
      if (widget.title.isEmpty) {
        getCourse();
      } else {
        title = widget.title;
        description = widget.description;
        category = widget.category;
        price = widget.price;
        discount_price = widget.discount_price;
        days = widget.days;
        promo_video = widget.promo_video;
        getCourseImages();
      }
    }
    super.initState();

    Provider.of<CartItems>(context, listen: false)
        .current_cart
        .forEach((element) {
      if (element.id == widget.id && element.category == 'course') {
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

  Future<void> _showDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Subscription Ended!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Please purchase again to access this course!!'),
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

  openPdf(String path) async {
    if (kIsWeb) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => SharePdf(path: path),
      //   ),
      // );
      html.window.open(path, "_blank");
      html.Url.revokeObjectUrl(path);
    } else {
      if (Platform.isIOS) {
        // for iOS phone only
        if (await canLaunch(path)) {
          await launch(path, forceSafariVC: false);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("Not able to download")));
        }
      } else {
        // android , web
        if (await canLaunch(path)) {
          await launch(path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: new Text("Not able to download")));
        }
      }
    }
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
                      child:
                          // widget.promo_video.isNotEmpty
                          //     ? Container(
                          //         margin: const EdgeInsets.symmetric(
                          //             vertical: 0.0, horizontal: 8.0),
                          //         child: ClipRRect(
                          //           borderRadius: BorderRadius.circular(10.0),
                          //           child: VideoPlayerPage(url: widget.promo_video),
                          //         ),
                          //       )
                          list.isEmpty
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              category == 'free'
                                  ? title
                                  : '$title ($days days course)',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30.0,
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
                                category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontFamily: 'EuclidCircularA Regular'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: category == 'free'
                          ? Text('')
                          : subscribed != 0
                              ? Text(
                                  subscribed != 0 ? '$daysLeft days left' : '',
                                  style: TextStyle(
                                      color: subscribed != 0
                                          ? int.parse(daysLeft) > 7
                                              ? Colors.green
                                              : Colors.redAccent
                                          : Colors.black,
                                      fontSize: subscribed != 0 ? 16.0 : 0.0,
                                      fontFamily: 'EuclidCircularA Medium'),
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${subscribed != 0 ? '' : 'Rs $discount_price'}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 24.0,
                                              fontFamily:
                                                  'EuclidCircularA Medium',
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 3.0),
                                            child: price == discount_price
                                                ? const Text('')
                                                : Text(
                                                    price,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontFamily:
                                                            'EuclidCircularA Regular',
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              subscribed != 0 ? 10.0 : 0.0,
                                          horizontal: 0.0),
                                      child: Text(
                                        '${subscribed != 0 ? '$daysLeft days left' : ''}',
                                        style: TextStyle(
                                            color: subscribed != 0
                                                ? int.parse(daysLeft) > 7
                                                    ? Colors.green
                                                    : Colors.redAccent
                                                : Colors.black,
                                            fontSize:
                                                subscribed != 0 ? 16.0 : 0.0,
                                            fontFamily:
                                                'EuclidCircularA Medium'),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                    SizedBox(
                      height: category == 'free'
                          ? 0.0
                          : subscribed == 0
                              ? 0.0
                              : !isPDFLoading
                                  ? 0.0
                                  : number_of_pdf == 0
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
                                  : GestureDetector(
                                      onTap: () => {
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(
                                        //     builder: (context) =>
                                        //         SharePdf(path: pdf_url),
                                        //   ),
                                        // )
                                        openPdf(pdf_url)
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
                                                  'Open PDF',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: number_of_pdf == 0
                                                        ? 0.0
                                                        : 16.0,
                                                    fontFamily:
                                                        'EuclidCircularA Medium',
                                                  ),
                                                ),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 0.0,
                                                    horizontal: 0.0),
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 18.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xffFFF0D0)
                                                    .withOpacity(0.6),
                                                blurRadius:
                                                    30.0, // soften the shadow
                                                spreadRadius:
                                                    0.0, //extend the shadow
                                                offset: const Offset(
                                                  4.0, // Move to right 10  horizontally
                                                  8.0, // Move to bottom 10 Vertically
                                                ),
                                              ),
                                            ]),
                                      ),
                                    ),
                    ),
                    SizedBox(
                      height: category == 'online' ? 0.0 : 15.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: category == 'online'
                          ? Text('')
                          : category == 'free'
                              ? Text('')
                              : Text(
                                  description,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontFamily: 'EuclidCircularA Regular'),
                                ),
                    ),
                    SizedBox(
                      height: category == 'free' ? 0.0 : 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 00.0, horizontal: 24.0),
                      child: category == 'offline'
                          ? Container()
                          : const Text(
                              'Videos',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontFamily: 'EuclidCircularA Medium'),
                            ),
                    ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    for (var i in videos) i,
                    const SizedBox(
                      height: 10.0,
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
                                  category: 'course', item_id: widget.id),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (counter >= 1) {
                                        Provider.of<CartItems>(context,
                                                listen: false)
                                            .current_cart
                                            .removeWhere((element) =>
                                                element.id == widget.id &&
                                                element.category == 'course');
                                        context.read<CartItems>().setCart(
                                            Provider.of<CartItems>(context,
                                                    listen: false)
                                                .current_cart);
                                        updateCart(widget.id, 'remove');
                                        counter = 0;
                                      } else {
                                        var newObject = Cart(
                                          id: widget.id,
                                          category: 'course',
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
                                      // color: Palette.primaryColor,
                                      color: Palette.contrastColor,
                                      border: Border.all(
                                          color: Palette.contrastColor,
                                          width: 1.5),
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
                                      child: Text(
                                        counter == 0 ? 'Add to cart' : 'Remove',
                                        style: const TextStyle(
                                          // color: Palette.contrastColor,
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontFamily: 'EuclidCircularA Medium',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // const SizedBox(
                              //   width: 10.0,
                              // ),
                              // Expanded(
                              //   child: GestureDetector(
                              //     onTap: () {
                              //       Navigator.push(
                              //         context,
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               const CourseCartPage(),
                              //         ),
                              //       );
                              //     },
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(10),
                              //         color: Palette.contrastColor,
                              //         boxShadow: [
                              //           BoxShadow(
                              //             color: const Color(0xffFFF0D0)
                              //                 .withOpacity(0.0),
                              //             blurRadius: 30.0, // soften the shadow
                              //             spreadRadius: 0.0, //extend the shadow
                              //             offset: const Offset(
                              //               0.0, // Move to right 10  horizontally
                              //               0.0, // Move to bottom 10 Vertically
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //       child: const Center(
                              //         child: Text(
                              //           'Buy Now',
                              //           style: TextStyle(
                              //             color: Colors.white,
                              //             fontSize: 16.0,
                              //             fontFamily: 'EuclidCircularA Medium',
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
