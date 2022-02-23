import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/cart.dart';
import 'package:taruna_birla/config/course.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/models/selected_value.dart';
import 'package:taruna_birla/pages/each_course.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';

class CoursePage extends StatefulWidget {
  const CoursePage({Key? key}) : super(key: key);

  @override
  _CoursePageState createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String selected = '';
  List courselist = [];
  bool isLoading = false;
  int offset = 0;
  String user_id = '';
  List list = ['Online', 'Offline', 'Free'];

  updateSelected(String value) {
    // print(value);
    setState(() {
      Provider.of<SelectedValue>(context, listen: false)
          .setSelectedValue(value);
      selected = value;
      isLoading = false;
    });
    getCourses();
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

  Future<void> getCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final phonenumber = prefs.getString('phonenumber') ?? '';
    setState(() {
      user_id = userId;
      selected = Provider.of<SelectedValue>(context, listen: false)
          .current_selected_value;
    });
    // print(user_id);
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: selected == 'All'
          ? 'https://dashboard.cheftarunabirla.com/getUserCourse/$user_id'
          : 'https://dashboard.cheftarunabirla.com/getCategoryCourse/${selected.toLowerCase()}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      courselist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        courselist.add(
          Course(
              id: _data['data'][i]['id'].toString(),
              title: _data['data'][i]['title'].toString(),
              description: _data['data'][i]['description'].toString(),
              promo_video: _data['data'][i]['promo_video'].toString(),
              price: _data['data'][i]['price'].toString(),
              discount_price: _data['data'][i]['discount_price'].toString(),
              days: _data['data'][i]['days'],
              category: _data['data'][i]['category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              count: _data['data'][i]['count'],
              subscribed: _data['data'][i]['subscribed']),
        );
      }
      setState(() {
        isLoading = true;
      });
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getSearchedCourses(value) async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.GET,
        url:
            'https://dashboard.cheftarunabirla.com/getSearchedCourse/${value}/$user_id');

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      courselist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        courselist.add(
          Course(
              id: _data['data'][i]['id'].toString(),
              title: _data['data'][i]['title'].toString(),
              description: _data['data'][i]['description'].toString(),
              promo_video: _data['data'][i]['promo_video'].toString(),
              price: _data['data'][i]['price'].toString(),
              discount_price: _data['data'][i]['discount_price'].toString(),
              days: _data['data'][i]['days'],
              category: _data['data'][i]['category'].toString(),
              image_path: _data['data'][i]['image_path'].toString(),
              count: _data['data'][i]['count'],
              subscribed: _data['data'][i]['subscribed']),
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
        getCourses();
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
      getCourses();
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
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          const SizedBox(
            height: 20.0,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
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
              child: TextField(
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      selected = 'Online';
                      isLoading = false;
                    });
                    getSearchedCourses(value);
                  } else {
                    setState(() {
                      selected = 'Online';
                      isLoading = false;
                    });
                    getCourses();
                  }
                },
                // controller: phoneController,
                style: const TextStyle(
                  fontFamily: 'EuclidCircularA Regular',
                ),
                autofocus: false,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    MdiIcons.magnify,
                  ),
                  counterText: "",
                  hintText: "Search Courses",
                  focusColor: Palette.contrastColor,
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xffffffff),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xffffffff), width: 1.0),
                      borderRadius: BorderRadius.circular(10.0)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  filled: true,
                  fillColor: const Color(0xffffffff),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          SizedBox(
            height: 50.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                // print(selected);
                // print(list[index]);
                return GestureDetector(
                  onTap: () => {updateSelected(list[index])},
                  child: Container(
                    margin: index == 0
                        ? EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 0.0)
                        : EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                    child: Chip(
                      labelPadding:
                          EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                      label: Text(
                        list[index],
                        style: TextStyle(
                          color: selected == list[index]
                              ? Colors.white
                              : Palette.secondaryColor,
                          fontSize: 12.0,
                          fontFamily: 'EuclidCircularA Regular',
                        ),
                      ),
                      backgroundColor: selected == list[index]
                          ? Palette.secondaryColor
                          : Colors.white,
                      elevation: 10.0,
                      shadowColor: selected == list[index]
                          ? Palette.shadowColor.withOpacity(0.3)
                          : Palette.shadowColor.withOpacity(0.3),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
          Padding(
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
                  : LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
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
                          itemCount: courselist.length,
                          itemBuilder: (context, index) {
                            int counter = 0;
                            Provider.of<CartItems>(context, listen: false)
                                .current_cart
                                .forEach((element) {
                              if (element.id == courselist[index].id &&
                                  element.category == 'course') {
                                counter++;
                              }
                            });
                            // print(counter);
                            return Container(
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
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EachCourse(
                                            id: courselist[index].id,
                                            title: courselist[index].title,
                                            category:
                                                courselist[index].category,
                                            description:
                                                courselist[index].description,
                                            price: courselist[index].price,
                                            discount_price: courselist[index]
                                                .discount_price,
                                            days: courselist[index]
                                                .days
                                                .toString(),
                                            promo_video:
                                                courselist[index].promo_video,
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
                                              'https://dashboard.cheftarunabirla.com${courselist[index].image_path}',
                                          // placeholder: (context, url) =>
                                          //     const Center(
                                          //         child:
                                          //             CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          // fadeOutDuration:
                                          //     const Duration(milliseconds: 500),
                                          // fadeInDuration:
                                          //     const Duration(milliseconds: 500),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 120.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0.0, horizontal: 10.0),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EachCourse(
                                                id: courselist[index].id,
                                                title: courselist[index].title,
                                                category:
                                                    courselist[index].category,
                                                description: courselist[index]
                                                    .description,
                                                price: courselist[index].price,
                                                discount_price:
                                                    courselist[index]
                                                        .discount_price,
                                                days: courselist[index]
                                                    .days
                                                    .toString(),
                                                promo_video: courselist[index]
                                                    .promo_video,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          courselist[index].title.length > 30
                                              ? '${courselist[index].title.substring(0, 30)}...'
                                              : courselist[index].title,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontFamily:
                                                'EuclidCircularA Regular',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 0.0,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              courselist[index].category ==
                                                      'free'
                                                  ? 'Free'
                                                  : 'Rs ${courselist[index].discount_price}',
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
                                              if (courselist[index].category ==
                                                  'free') {
                                                // print('its free');
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EachCourse(
                                                      id: courselist[index].id,
                                                      title: courselist[index]
                                                          .title,
                                                      category:
                                                          courselist[index]
                                                              .category,
                                                      description:
                                                          courselist[index]
                                                              .description,
                                                      price: courselist[index]
                                                          .price,
                                                      discount_price:
                                                          courselist[index]
                                                              .discount_price,
                                                      days: courselist[index]
                                                          .days
                                                          .toString(),
                                                      promo_video:
                                                          courselist[index]
                                                              .promo_video,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                if (courselist[index]
                                                        .subscribed ==
                                                    0) {
                                                  setState(() {
                                                    if (counter >= 1) {
                                                      Provider.of<CartItems>(
                                                              context,
                                                              listen: false)
                                                          .current_cart
                                                          .removeWhere((element) =>
                                                              element.id ==
                                                                  courselist[
                                                                          index]
                                                                      .id &&
                                                              element.category ==
                                                                  'course');
                                                      context
                                                          .read<CartItems>()
                                                          .setCart(Provider.of<
                                                                      CartItems>(
                                                                  context,
                                                                  listen: false)
                                                              .current_cart);
                                                      updateCart(
                                                          courselist[index].id,
                                                          'remove');
                                                    } else {
                                                      var newObject = Cart(
                                                        id: courselist[index]
                                                            .id,
                                                        category: 'course',
                                                      );
                                                      Provider.of<CartItems>(
                                                              context,
                                                              listen: false)
                                                          .current_cart
                                                          .add(newObject);
                                                      context
                                                          .read<CartItems>()
                                                          .setCart(Provider.of<
                                                                      CartItems>(
                                                                  context,
                                                                  listen: false)
                                                              .current_cart);
                                                      updateCart(
                                                          courselist[index].id,
                                                          'add');
                                                    }
                                                  });
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EachCourse(
                                                        id: courselist[index]
                                                            .id,
                                                        title: courselist[index]
                                                            .title,
                                                        category:
                                                            courselist[index]
                                                                .category,
                                                        description:
                                                            courselist[index]
                                                                .description,
                                                        price: courselist[index]
                                                            .price,
                                                        discount_price:
                                                            courselist[index]
                                                                .discount_price,
                                                        days: courselist[index]
                                                            .days
                                                            .toString(),
                                                        promo_video:
                                                            courselist[index]
                                                                .promo_video,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            child: courselist[index]
                                                        .subscribed ==
                                                    1
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
                                                            'Open',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12.0,
                                                              fontFamily:
                                                                  'EuclidCircularA Regular',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          Palette.contrastColor,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                8.0),
                                                        topRight:
                                                            Radius.circular(
                                                                0.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                0.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10.0),
                                                      ),
                                                    ),
                                                  )
                                                : counter == 0
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
                                                            children: [
                                                              Text(
                                                                courselist[index]
                                                                            .category ==
                                                                        'free'
                                                                    ? 'Read'
                                                                    : 'Add',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular',
                                                                ),
                                                              ),
                                                              const Icon(
                                                                Icons.add,
                                                                color: Colors
                                                                    .white,
                                                                size: 16.0,
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Palette
                                                              .contrastColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0),
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
                                                                courselist[index]
                                                                            .category ==
                                                                        'free'
                                                                    ? 'Read'
                                                                    : 'Remove',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      12.0,
                                                                  fontFamily:
                                                                      'EuclidCircularA Regular',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Palette
                                                              .contrastColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    8.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    0.0),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10.0),
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
