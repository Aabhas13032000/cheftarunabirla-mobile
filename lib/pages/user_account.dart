import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({Key? key}) : super(key: key);

  @override
  _UserAccountState createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  String phoneNumber = '';
  bool isLoading = false;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final phoneController = TextEditingController();
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phonenumber = prefs.getString('phonenumber') ?? '';
    // print();
    setState(() {
      phoneNumber = phonenumber;
      phoneController.text = phonenumber;
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
      // data loaded
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_data['data'][0]['email_id'].toString() != 'null') {
        emailController.text = _data['data'][0]['email_id'].toString();
        prefs.setString('email', _data['data'][0]['email_id'].toString());
      }
      if (_data['data'][0]['name'].toString() != 'null') {
        nameController.text = _data['data'][0]['name'].toString();
        prefs.setString('name', _data['data'][0]['name'].toString());
      }
      if (_data['data'][0]['address'].toString() != 'null') {
        addressController.text = _data['data'][0]['address'].toString();
        prefs.setString('address', _data['data'][0]['address'].toString());
      }
      if (_data['data'][0]['pincode'].toString() != 'null') {
        pincodeController.text = _data['data'][0]['pincode'].toString();
        prefs.setString('address', _data['data'][0]['pincode'].toString());
      }
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  Future<void> saveUserDetails() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
        requestType: RequestType.POST,
        url:
            'https://dashboard.cheftarunabirla.com/users/saveUserDetails/$phoneNumber',
        body: {
          'name': nameController.text,
          'email_id': emailController.text,
          'address': addressController.text,
          'pincode': pincodeController.text
        });

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      if (_data['message'].toString() == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', emailController.text);
        prefs.setString('name', nameController.text);
        prefs.setString('address', addressController.text);
        prefs.setString('pincode', pincodeController.text);
        _showSuccessDialog('Updated Successfully', 'Your data is updated!!');
      } else {
        _showSuccessDialog('Some error occured', 'Try again in some time!!');
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

  Future<void> _showSuccessDialog(String title, String description) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
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
            'Account',
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
            : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 30.0,
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
                          // enabled: false,
                          readOnly: true,
                          onChanged: (value) {},
                          // keyboardType: TextInputType.multiline,
                          // minLines: 1,
                          // maxLines: 1,
                          controller: phoneController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.phoneOutline,
                            ),
                            counterText: "",
                            hintText: "",
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
                          onChanged: (value) {},
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 1,
                          controller: nameController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.formatTextVariant,
                            ),
                            counterText: "",
                            hintText: "Enter your full name",
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
                          onChanged: (value) {},
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 1,
                          controller: emailController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.emailOutline,
                            ),
                            counterText: "",
                            hintText: "Enter your email",
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
                          onChanged: (value) {},
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          controller: addressController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.mapMarkerOutline,
                            ),
                            counterText: "",
                            hintText: "Enter your address",
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
                          onChanged: (value) {},
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          controller: pincodeController,
                          style: const TextStyle(
                            fontFamily: 'EuclidCircularA Regular',
                          ),
                          autofocus: false,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              MdiIcons.formTextboxPassword,
                            ),
                            counterText: "",
                            hintText: "Enter your pincode",
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
                      child: GestureDetector(
                        onTap: () {
                          // if(addressController.text.isNotEmpty)
                          setState(() {
                            isLoading = false;
                          });
                          saveUserDetails();
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
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontFamily: 'EuclidCircularA Medium',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
