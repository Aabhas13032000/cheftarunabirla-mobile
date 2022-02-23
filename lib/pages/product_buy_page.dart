import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/src/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/cart.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/models/cart_items.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import 'cart_page.dart';

class ProductBuyPage extends StatefulWidget {
  final String price;
  final String id;
  const ProductBuyPage({
    Key? key,
    required this.price,
    required this.id,
  }) : super(key: key);

  @override
  State<ProductBuyPage> createState() => _ProductBuyPageState();
}

class _ProductBuyPageState extends State<ProductBuyPage> {
  bool isLoading = false;
  bool isOfferLoading = false;
  String user_id = '';
  int total_price = 0;
  double actual_total_price = 0;
  int number_of_courses = 0;
  String discountpercentage = '';
  String couponcode = '';
  String couponid = '';
  int counter = 0;
  String phoneNumber = '';
  List list = [];
  File? image;
  String address = '';
  String selectedImage = '';
  final quantityController = TextEditingController();
  final descriptionController = TextEditingController();
  // final addressController = TextEditingController();
  final pincodeController = TextEditingController();
  String state = "";
  int shippingCharges = 90;
  // String user

  Future<void> getProductImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    final phonenumber = prefs.getString('phonenumber') ?? '';
    // final add = prefs.getString('address') ?? '';
    final pincode = prefs.getString('pincode') ?? '';
    setState(() {
      user_id = userId;
      phoneNumber = phonenumber;
      // address = add;
      // addressController.text = add;
      quantityController.text = '1';
      pincodeController.text = pincode;
    });
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getProductImages/${widget.id}',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      // list.add(
      //   'All',
      // );
      // imagePath =
      // 'https://dashboard.cheftarunabirla.com${_data['data'][0]['path'].toString()}';
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
            'https://dashboard.cheftarunabirla.com${_data['data'][i]['path'].toString()}');
      }
      setState(() => isLoading = true);
      // getProducts();
      getCouponsByCategory();
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> updateCart(id, value) async {
    Map<String, dynamic> _updateCart = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: value == 'add'
          ? 'https://dashboard.cheftarunabirla.com/users/addproducttocart'
          : 'https://dashboard.cheftarunabirla.com/users/removefromcart',
      body: {
        'user_id': user_id,
        'category': 'product',
        'id': id,
        'description': descriptionController.text.isEmpty
            ? 'nothing'
            : descriptionController.text,
        'image_path': selectedImage,
        'quantity': quantityController.text
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

  Future<void> getCouponsByCategory() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCouponsByCategory/product/single',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    print(_data);
    if (_status) {
      if (_data['data'].length != 0) {
        var discount = int.parse(_data['data'][0]['dis'].toString());
        if (pincodeController.text == '311001') {
          actual_total_price = (int.parse(widget.price) -
              ((int.parse(widget.price) * discount) / 100));
        } else {
          actual_total_price = (int.parse(widget.price) -
                  ((int.parse(widget.price) * discount) / 100)) +
              shippingCharges;
        }
        discountpercentage = _data['data'][0]['dis'].toString();
        couponcode = _data['data'][0]['ccode'].toString();
        couponid = _data['data'][0]['id'].toString();
      } else {
        if (pincodeController.text == '311001') {
          actual_total_price = double.parse(widget.price);
        } else {
          actual_total_price = (double.parse(widget.price) + shippingCharges);
        }
        discountpercentage = '0';
        couponid = '';
        couponcode = '';
      }
      setState(() => isOfferLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  _filterRetriever() async {
    try {
      final result = await InternetAddress.lookup('cheftarunabirla.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        getProductImages();
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
      getProductImages();
    }
    super.initState();

    Provider.of<CartItems>(context, listen: false)
        .current_cart
        .forEach((element) {
      if (element.id == widget.id && element.category == 'product') {
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

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemporary = File(image.path);
      var res = await uploadImage(
          image.path, 'https://dashboard.cheftarunabirla.com/saveUserOrderImage');
      setState(() {
        this.image = imageTemporary;
        state = res!;
        selectedImage = res;
      });
    } on PlatformException catch (e) {
      print('Failed to pick image $e');
    }
  }

  Future<String?> uploadImage(filename, url) async {
    // var dio = Dio();
    // var formData = FormData.fromMap({
    //   'file': await http.MultipartFile.fromPath('picture', filename),
    // });
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('picture', filename));
    var res = await request.send();
    final responseData = await res.stream.toBytes();
    final responseString = String.fromCharCodes(responseData);
    // print(json.decode(responseString)['files'].toString());
    // var response = await dio.post(url, data: request);
    // print(response);
    // print(res.toString());
    return json.decode(responseString)['files'].toString();
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
      ),
      body: !isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: const Text(
                            'Select image from our gallery',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'EuclidCircularA Medium',
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(24.0, 20.0, 0.0, 0.0),
                          height: 150.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  // print(image);
                                  setState(() {
                                    selectedImage = list[index];
                                    image = null;
                                  });
                                },
                                child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(0.0, 0.0, 20.0, 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: selectedImage == list[index]
                                          ? 3.0
                                          : 0.0,
                                      color: Colors.green,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      list[index],
                                      fit: BoxFit.cover,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: Center(
                            child: const Text(
                              'OR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: const Text(
                            'Upload your own image',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                              fontFamily: 'EuclidCircularA Medium',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 00.0, horizontal: 24.0),
                          child: GestureDetector(
                            onTap: () {
                              pickImage();
                            },
                            child: Container(
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Palette.appBarColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xffFFF0D0)
                                        .withOpacity(0.5),
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
                                  children: const [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Pick an image',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0,
                                            fontFamily:
                                                'EuclidCircularA Regular',
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
                        SizedBox(
                          height: image != null ? 10.0 : 0.0,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 00.0,
                              horizontal: image != null ? 24.0 : 0.0),
                          child: image != null
                              ? Center(
                                  child: Container(
                                    height: 150.0,
                                    margin: EdgeInsets.fromLTRB(
                                        0.0, 0.0, 20.0, 0.0),
                                    child: image != null
                                        ? Stack(children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Image.file(
                                                image!,
                                                fit: BoxFit.cover,
                                                height: double.infinity,
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    image = null;
                                                    state = '';
                                                    selectedImage = '';
                                                  });
                                                },
                                                child: Container(
                                                  height: 24.0,
                                                  width: 24.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50.0),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      size: 18.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ])
                                        : Container(),
                                  ),
                                )
                              : Center(),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xffFFF0D0).withOpacity(1.0),
                                  blurRadius: 30.0, // soften the shadow
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
                                    actual_total_price = ((int.parse(
                                                    widget.price) -
                                                ((int.parse(widget.price) *
                                                        int.parse(
                                                            discountpercentage)) /
                                                    100)) +
                                            shippingCharges) *
                                        int.parse(value);
                                  });
                                }
                              },
                              keyboardType: TextInputType.phone,
                              minLines: 1,
                              maxLines: 1,
                              controller: quantityController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                // prefixIcon: const Icon(
                                //   MdiIcons.formatTextVariant,
                                // ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 15.0),
                                  child: Text(
                                    'Q',
                                    style: TextStyle(
                                      fontFamily: 'EuclidCircularA Medium',
                                      fontSize: 18.0,
                                      color: Color(0xff828282),
                                    ),
                                  ),
                                ),
                                counterText: "",
                                hintText: "Enter Quantity",
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
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 24.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xffFFF0D0).withOpacity(1.0),
                                  blurRadius: 30.0, // soften the shadow
                                  spreadRadius: 0.0, //extend the shadow
                                  offset: const Offset(
                                    0.0, // Move to right 10  horizontally
                                    0.0, // Move to bottom 10 Vertically
                                  ),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {},
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: 5,
                              controller: descriptionController,
                              style: const TextStyle(
                                fontFamily: 'EuclidCircularA Regular',
                              ),
                              autofocus: false,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  MdiIcons.formatParagraph,
                                ),
                                counterText: "",
                                hintText: "Enter message",
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
                          height: 20.0,
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 0.0, horizontal: 24.0),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //       color: Colors.white,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color:
                        //               const Color(0xffFFF0D0).withOpacity(1.0),
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
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 0.0, horizontal: 24.0),
                        //   child: Container(
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(10.0),
                        //       color: Colors.white,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color:
                        //               const Color(0xffFFF0D0).withOpacity(1.0),
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
                        //         if (value.length >= 6) {
                        //           setState(() {
                        //             if (value == '311001') {
                        //               shippingCharges = 0;
                        //               actual_total_price =
                        //                   (int.parse(widget.price) -
                        //                       ((int.parse(widget.price) *
                        //                               int.parse(
                        //                                   discountpercentage)) /
                        //                           100));
                        //             } else {
                        //               shippingCharges = 90;
                        //               actual_total_price = (int.parse(
                        //                           widget.price) -
                        //                       ((int.parse(widget.price) *
                        //                               int.parse(
                        //                                   discountpercentage)) /
                        //                           100)) +
                        //                   shippingCharges;
                        //             }
                        //           });
                        //         } else {
                        //           setState(() {
                        //             shippingCharges = 90;
                        //           });
                        //           actual_total_price =
                        //               (int.parse(widget.price) -
                        //                       ((int.parse(widget.price) *
                        //                               int.parse(
                        //                                   discountpercentage)) /
                        //                           100)) +
                        //                   shippingCharges;
                        //         }
                        //       },
                        //       keyboardType: TextInputType.multiline,
                        //       minLines: 1,
                        //       maxLines: 5,
                        //       controller: pincodeController,
                        //       style: const TextStyle(
                        //         fontFamily: 'EuclidCircularA Regular',
                        //       ),
                        //       autofocus: false,
                        //       decoration: InputDecoration(
                        //         prefixIcon: const Icon(
                        //           MdiIcons.formTextboxPassword,
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
                        //   height: 20.0,
                        // ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          height: couponid.isEmpty ? 80.0 : 85.0,
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
                                vertical: 0.0, horizontal: 24.0),
                            child: Center(
                              child: !isOfferLoading
                                  ? Container()
                                  : Column(
                                      children: [
                                        Container(
                                          child: couponid.isEmpty
                                              ? Container()
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      'Applied Offer:',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      '$couponcode $discountpercentage%',
                                                      style: TextStyle(
                                                        color: Palette
                                                            .secondaryColor,
                                                        fontSize: 14.0,
                                                        fontFamily:
                                                            'EuclidCircularA Medium',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Shipping Charges',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                              'Rs. $shippingCharges',
                                              style: TextStyle(
                                                color: Palette.secondaryColor,
                                                fontSize: 14.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10.0,
                                        ),
                                        const Divider(
                                          height: 2.0,
                                          color: Colors.black38,
                                          indent: 0.0,
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'Total',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.0,
                                            ),
                                            Text(
                                              'Rs. $actual_total_price',
                                              style: const TextStyle(
                                                color: Palette.secondaryColor,
                                                fontSize: 16.0,
                                                fontFamily:
                                                    'EuclidCircularA Medium',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10.0,
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
                          child: !isOfferLoading
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
                                                        element.id ==
                                                            widget.id &&
                                                        element.category ==
                                                            'product');
                                                context
                                                    .read<CartItems>()
                                                    .setCart(
                                                        Provider.of<CartItems>(
                                                                context,
                                                                listen: false)
                                                            .current_cart);
                                                updateCart(widget.id, 'remove');
                                                counter = 0;
                                              } else {
                                                if (selectedImage.isEmpty) {
                                                  final snackBar = SnackBar(
                                                    content: const Text(
                                                        'Select the Image or upload it!'),
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      onPressed: () {
                                                        // Some code to undo the change.
                                                      },
                                                    ),
                                                  );

                                                  // Find the ScaffoldMessenger in the widget tree
                                                  // and use it to show a SnackBar.
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else if (quantityController
                                                    .text.isEmpty) {
                                                  final snackBar = SnackBar(
                                                    content: const Text(
                                                        'Enter the quantity!'),
                                                    action: SnackBarAction(
                                                      label: 'Undo',
                                                      onPressed: () {
                                                        // Some code to undo the change.
                                                      },
                                                    ),
                                                  );

                                                  // Find the ScaffoldMessenger in the widget tree
                                                  // and use it to show a SnackBar.
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                } else {
                                                  var newObject = Cart(
                                                    id: widget.id,
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
                                                  updateCart(widget.id, 'add');
                                                  counter = 1;
                                                }
                                              }
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              // color: Palette.primaryColor,
                                              color: Palette.contrastColor,
                                              border: Border.all(
                                                  width: 1.5,
                                                  color: Palette.contrastColor),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xffFFF0D0)
                                                      .withOpacity(0.0),
                                                  blurRadius:
                                                      30.0, // soften the shadow
                                                  spreadRadius:
                                                      0.0, //extend the shadow
                                                  offset: const Offset(
                                                    0.0, // Move to right 10  horizontally
                                                    0.0, // Move to bottom 10 Vertically
                                                  ),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                counter == 0
                                                    ? 'Add to cart'
                                                    : 'Remove',
                                                style: TextStyle(
                                                  // color: Palette.contrastColor,
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                  fontFamily:
                                                      'EuclidCircularA Medium',
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
                                      //       if (phoneNumber.isEmpty) {
                                      //         context
                                      //             .read<CurrentIndex>()
                                      //             .setIndex(4);
                                      //         Navigator.pushAndRemoveUntil(
                                      //           context,
                                      //           MaterialPageRoute(
                                      //             builder: (context) =>
                                      //                 const MainContainer(),
                                      //           ),
                                      //           (Route<dynamic> route) => false,
                                      //         );
                                      //       } else {
                                      //         // if (addressController.text.isEmpty) {
                                      //         //   final snackBar = SnackBar(
                                      //         //     content: const Text(
                                      //         //         'Enter the address!'),
                                      //         //     action: SnackBarAction(
                                      //         //       label: 'Undo',
                                      //         //       onPressed: () {
                                      //         //         // Some code to undo the change.
                                      //         //       },
                                      //         //     ),
                                      //         //   );
                                      //         //
                                      //         //   // Find the ScaffoldMessenger in the widget tree
                                      //         //   // and use it to show a SnackBar.
                                      //         //   ScaffoldMessenger.of(context)
                                      //         //       .showSnackBar(snackBar);
                                      //         // } else
                                      //         if (quantityController
                                      //             .text.isEmpty) {
                                      //           final snackBar = SnackBar(
                                      //             content: const Text(
                                      //                 'Enter the quantity!'),
                                      //             action: SnackBarAction(
                                      //               label: 'Undo',
                                      //               onPressed: () {
                                      //                 // Some code to undo the change.
                                      //               },
                                      //             ),
                                      //           );
                                      //
                                      //           // Find the ScaffoldMessenger in the widget tree
                                      //           // and use it to show a SnackBar.
                                      //           ScaffoldMessenger.of(context)
                                      //               .showSnackBar(snackBar);
                                      //         } else
                                      //         //   if (pincodeController
                                      //         //         .text.length <
                                      //         //     6) {
                                      //         //   final snackBar = SnackBar(
                                      //         //     content: const Text(
                                      //         //         'Enter the pincode!'),
                                      //         //     action: SnackBarAction(
                                      //         //       label: 'Undo',
                                      //         //       onPressed: () {
                                      //         //         // Some code to undo the change.
                                      //         //       },
                                      //         //     ),
                                      //         //   );
                                      //         //
                                      //         //   // Find the ScaffoldMessenger in the widget tree
                                      //         //   // and use it to show a SnackBar.
                                      //         //   ScaffoldMessenger.of(context)
                                      //         //       .showSnackBar(snackBar);
                                      //         // } else
                                      //         if (selectedImage.isEmpty) {
                                      //           final snackBar = SnackBar(
                                      //             content: const Text(
                                      //                 'Select the Image or upload it!'),
                                      //             action: SnackBarAction(
                                      //               label: 'Undo',
                                      //               onPressed: () {
                                      //                 // Some code to undo the change.
                                      //               },
                                      //             ),
                                      //           );
                                      //
                                      //           // Find the ScaffoldMessenger in the widget tree
                                      //           // and use it to show a SnackBar.
                                      //           ScaffoldMessenger.of(context)
                                      //               .showSnackBar(snackBar);
                                      //         } else {
                                      //           // Navigator.push(
                                      //           //   context,
                                      //           //   MaterialPageRoute(
                                      //           //     builder: (context) =>
                                      //           //         ProductPaymentPage(
                                      //           //       total_price: widget.price,
                                      //           //       actual_total_price:
                                      //           //           actual_total_price !=
                                      //           //                   0
                                      //           //               ? actual_total_price
                                      //           //                   .toString()
                                      //           //               : widget.price,
                                      //           //       user_id: user_id,
                                      //           //       coupon_id:
                                      //           //           couponid.isEmpty
                                      //           //               ? 'nothing'
                                      //           //               : couponid,
                                      //           //       phoneNumber: phoneNumber,
                                      //           //       description:
                                      //           //           descriptionController
                                      //           //                   .text.isEmpty
                                      //           //               ? 'nothing'
                                      //           //               : descriptionController
                                      //           //                   .text,
                                      //           //       item_id: widget.id,
                                      //           //       address: addressController
                                      //           //               .text.isEmpty
                                      //           //           ? ''
                                      //           //           : addressController
                                      //           //               .text,
                                      //           //       quantity: quantityController
                                      //           //               .text.isEmpty
                                      //           //           ? '1'
                                      //           //           : quantityController
                                      //           //               .text,
                                      //           //       selectedImage: selectedImage
                                      //           //                   .split('/')[
                                      //           //               selectedImage
                                      //           //                       .split(
                                      //           //                           '/')
                                      //           //                       .length -
                                      //           //                   1] +
                                      //           //           '_image',
                                      //           //       pincode: pincodeController
                                      //           //           .text,
                                      //           //     ),
                                      //           //   ),
                                      //           // );
                                      //         }
                                      //       }
                                      //     },
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         borderRadius:
                                      //             BorderRadius.circular(10),
                                      //         color: Palette.contrastColor,
                                      //         boxShadow: [
                                      //           BoxShadow(
                                      //             color: const Color(0xffFFF0D0)
                                      //                 .withOpacity(0.0),
                                      //             blurRadius:
                                      //                 30.0, // soften the shadow
                                      //             spreadRadius:
                                      //                 0.0, //extend the shadow
                                      //             offset: const Offset(
                                      //               0.0, // Move to right 10  horizontally
                                      //               0.0, // Move to bottom 10 Vertically
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //       child: Center(
                                      //         child: Text(
                                      //           'Buy Now',
                                      //           style: TextStyle(
                                      //             color: Colors.white,
                                      //             fontSize: 16.0,
                                      //             fontFamily:
                                      //                 'EuclidCircularA Medium',
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
                ),
              ],
            ),
    );
  }
}
