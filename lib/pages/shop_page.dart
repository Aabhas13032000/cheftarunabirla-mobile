import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/config/products.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/pages/each_product.dart';
import 'package:taruna_birla/pages/product_buy_page.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  String selected = 'All';
  List<String> list = [];
  List productlist = [];
  bool isLoading = false;
  bool isProductLoading = false;
  int offset = 0;
  String user_id = '';
  List cart_array = [];

  updateSelected(String value) {
    // print(value);
    setState(() {
      selected = value;
      isProductLoading = false;
    });
    getProducts();
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
      print(_data);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getProducts() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: selected == 'All'
          ? 'https://dashboard.cheftarunabirla.com/getUserProduct/$user_id'
          : 'https://dashboard.cheftarunabirla.com/getCategoryProduct/${selected}/$user_id',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      productlist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        productlist.add(
          Products(
            id: _data['data'][i]['id'].toString(),
            name: _data['data'][i]['name'].toString(),
            description: _data['data'][i]['description'].toString(),
            c_name: _data['data'][i]['c_name'].toString(),
            category_id: _data['data'][i]['category_id'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            stock: _data['data'][i]['stock'],
            image_path: _data['data'][i]['image_path'].toString(),
            count: _data['data'][i]['count'],
          ),
        );
      }
      setState(() => isProductLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getSearchedProducts(value) async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.GET,
        url: 'https://dashboard.cheftarunabirla.com/getSearchedProduct/${value}/$user_id');

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      productlist.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        productlist.add(
          Products(
            id: _data['data'][i]['id'].toString(),
            name: _data['data'][i]['name'].toString(),
            description: _data['data'][i]['description'].toString(),
            c_name: _data['data'][i]['c_name'].toString(),
            category_id: _data['data'][i]['category_id'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            stock: _data['data'][i]['stock'],
            image_path: _data['data'][i]['image_path'].toString(),
            count: _data['data'][i]['count'],
          ),
        );
      }
      setState(() => isProductLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> getCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    // print();
    setState(() {
      user_id = userId;
      cart_array = Provider.of<CartItems>(context, listen: false).current_cart;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getProductCategories',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      list.add(
        'All',
      );
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          _data['data'][i]['name'].toString(),
        );
      }
      setState(() => isLoading = true);
      getProducts();
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getCategories();
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
      getCategories();
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
                      selected = 'All';
                      isProductLoading = false;
                    });
                    getSearchedProducts(value);
                  } else {
                    setState(() {
                      selected = 'All';
                      isProductLoading = false;
                    });
                    getProducts();
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
                  hintText: "Search Products",
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
            child: !isLoading
                ? Center()
                : SizedBox(
                    height: 50.0,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => {updateSelected(list[index])},
                          child: Container(
                            margin: index == 0
                                ? EdgeInsets.fromLTRB(24.0, 0.0, 20.0, 0.0)
                                : EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                            child: Chip(
                              labelPadding: EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 20.0),
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
                              elevation: 5.0,
                              shadowColor: selected == list[index]
                                  ? Palette.shadowColor.withOpacity(0.3)
                                  : Palette.shadowColor.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
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
              child: !isProductLoading
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
                          itemCount: productlist.length,
                          itemBuilder: (context, index) {
                            // int counter = 0;
                            // Provider.of<CartItems>(context, listen: false)
                            //     .current_cart
                            //     .forEach((element) {
                            //   if (element.id == productlist[index].id &&
                            //       element.category == 'product') {
                            //     counter++;
                            //   }
                            // });
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
                                          builder: (context) => EachProduct(
                                            id: productlist[index].id,
                                            name: productlist[index].name,
                                            description:
                                                productlist[index].description,
                                            category: productlist[index].c_name,
                                            price: productlist[index].price,
                                            discount_price: productlist[index]
                                                .discount_price,
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
                                              'https://dashboard.cheftarunabirla.com${productlist[index].image_path}',
                                          // placeholder: (context, url) =>
                                          //     const Center(
                                          //         child:
                                          //             CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          // fadeOutDuration:
                                          //     const Duration(seconds: 1),
                                          // fadeInDuration:
                                          //     const Duration(seconds: 1),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: 120.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EachProduct(
                                              id: productlist[index].id,
                                              name: productlist[index].name,
                                              description: productlist[index]
                                                  .description,
                                              category:
                                                  productlist[index].c_name,
                                              price: productlist[index].price,
                                              discount_price: productlist[index]
                                                  .discount_price,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 0.0, horizontal: 10.0),
                                        child: Text(
                                          productlist[index].name.length > 30
                                              ? '${productlist[index].name.substring(0, 30)}...'
                                              : productlist[index].name,
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
                                              'Rs ${productlist[index].discount_price}',
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
                                              // setState(() {
                                              //
                                              // });
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductBuyPage(
                                                            price: productlist[
                                                                    index]
                                                                .discount_price,
                                                            id: productlist[
                                                                    index]
                                                                .id)),
                                              );
                                            },
                                            child:
                                                // counter == 0
                                                // ? Container(
                                                //     height: double.infinity,
                                                //     child: Center(
                                                //       child: Row(
                                                //         crossAxisAlignment:
                                                //             CrossAxisAlignment
                                                //                 .center,
                                                //         mainAxisAlignment:
                                                //             MainAxisAlignment
                                                //                 .center,
                                                //         children: const [
                                                //           Text(
                                                //             'Add',
                                                //             style: TextStyle(
                                                //               color: Colors.white,
                                                //               fontSize: 12.0,
                                                //               fontFamily:
                                                //                   'EuclidCircularA Regular',
                                                //             ),
                                                //           ),
                                                //           Icon(
                                                //             Icons.add,
                                                //             color: Colors.white,
                                                //             size: 16.0,
                                                //           )
                                                //         ],
                                                //       ),
                                                //     ),
                                                //     decoration: BoxDecoration(
                                                //       color: Palette.contrastColor,
                                                //       borderRadius:
                                                //           BorderRadius.only(
                                                //         topLeft:
                                                //             Radius.circular(8.0),
                                                //         topRight:
                                                //             Radius.circular(0.0),
                                                //         bottomLeft:
                                                //             Radius.circular(0.0),
                                                //         bottomRight:
                                                //             Radius.circular(10.0),
                                                //       ),
                                                //     ),
                                                //   )
                                                Container(
                                              height: double.infinity,
                                              child: Center(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Text(
                                                      'Buy Now',
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
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(8.0),
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
