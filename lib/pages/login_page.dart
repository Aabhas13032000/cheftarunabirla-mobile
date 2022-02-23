import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

import '../main.dart';

enum MobileVerificationState {
  SHOW_MOBILE_FROM_STATE,
  SHOW_OTP_FORM_STATE,
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Set default `_initialized` and `_error` state to false
  bool _initialized = false;
  bool _error = false;
  String isUser = 'true';
  late String databasename;
  late String type;
  late String name;
  String deviceToken = '';
  String completephonenumber = '';

  bool showLoading = false;

  MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FROM_STATE;
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  late String verificationId;

  FirebaseAuth _auth = FirebaseAuth.instance;

  // Define an async function to initialize FlutterFire
  // void initializeFlutterFire() async {
  //   try {
  //     // Wait for Firebase to initialize and set `_initialized` state to true
  //     await Firebase.initializeApp();
  //     setState(() {
  //       _initialized = true;
  //     });
  //   } catch (e) {
  //     // Set `_error` state to true if Firebase initialization fails
  //     setState(() {
  //       _error = true;
  //     });
  //   }
  // }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    print('entered');
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        _saveLogin();
      }
    } on FirebaseAuthException catch (e) {
      // TODO
      setState(() {
        showLoading = false;
      });

      print('error: ${e.message}');

      // _scaffoldKey.currentState!.showSnackBar(SnackBar(
      //   content: Text('${e.message}'),
      // ));
    }
  }

  Future<String> _saveLogin() async {
    // print('name= $name');
    // print('type= $type');
    Map<String, dynamic> _saveDeviceTokenData = await MySqlDBService().runQuery(
      requestType: RequestType.POST,
      url: 'https://dashboard.cheftarunabirla.com/users/save_user_mobile',
      body: {
        'token': deviceToken,
        'phone_number': phoneController.text,
      },
    );

    bool _status = _saveDeviceTokenData['status'];
    var _data = _saveDeviceTokenData['data'];

    if (_status) {
      print(_data);
      if (_data['message'].toString() == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool('loggedIn', true);
        prefs.setString('phonenumber', phoneController.text);
        if (_data['user_id'].toString().isNotEmpty) {
          prefs.setString('user_id', _data['user_id'].toString());
        }
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainContainer(),
          ),
          (Route<dynamic> route) => false,
        );
      } else if (_data['message'].toString() == 'deviceNotMatched') {
        _showMyDialog('Looks like you already have an account!');
      } else {
        _showMyDialog('Looks like some error occurred!');
      }
    } else {
      print('Something went wrong while saving token.');
    }

    return 'saved';
  }

  Future<void> _showMyDialog(message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(message),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Contact Support for this !!'),
                Text('Call on: 8619810907'),
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

  // Future<void> getUser(value) async {
  //   // print(value);
  //   Map<String, dynamic> _getDatabases = await MySqlDBService().runQuery(
  //     requestType: RequestType.GET,
  //     url:
  //         'https://truelinefashion.foundationadroit.org/app/api/checkPhoneNumber/$value',
  //   );
  //
  //   bool _status = _getDatabases['status'];
  //   var _data = _getDatabases['data'];
  //   print(_data);
  //   if (_status) {
  //     if (_data.length == 0) {
  //       setState(() {
  //         isUser = 'false';
  //       });
  //     } else {
  //       setState(() {
  //         isUser = 'true';
  //         databasename = _data[0]['data'];
  //         type = _data[0]['type'];
  //         name = _data[0]['name'];
  //       });
  //     }
  //     // _getSize();
  //   } else {
  //     print('Something went wrong.');
  //   }
  // }

  getMobileFromWidget(context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          // height: 800.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/login.png',
                width: 200.0,
              ),
              // const SizedBox(
              //   height: 20.0,
              // ),
              const Text(
                'Welcome 👋',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                  color: Palette.secondaryColor,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                'We are glad to have you back !!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffAAAEB0),
                  // fontFamily: GoogleFonts.montserrat().fontFamily,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: IntlPhoneField(
                        initialCountryCode: 'IN',
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter 10-digit The Phone Number",
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Palette.secondaryColor,
                                width: 1.3,
                              ),
                              borderRadius: BorderRadius.circular(8.0)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color(0xffffffff), width: 1.0),
                              borderRadius: BorderRadius.circular(8.0)),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          filled: true,
                          fillColor: const Color(0xffffffff),
                        ),
                        onChanged: (phone) {
                          // print(phone.completeNumber);
                          setState(() {
                            completephonenumber = phone.completeNumber;
                          });
                        },
                        onCountryChanged: (phone) {
                          print('Country code changed to: ');
                        },
                      ),
                    ),
                    // Expanded(
                    //   child: SizedBox(
                    //     child: TextField(
                    //       maxLength: 10,
                    //       // onChanged: (value) {
                    //       //   if (value.length == 10) {
                    //       //     if (value == '1234567890') {
                    //       //       // setState(() {
                    //       //       //   isUser = 'true';
                    //       //       //   type = 'superadmin';
                    //       //       //   databasename = '1234567890';
                    //       //       //   name = 'Admin';
                    //       //       // });
                    //       //     } else {
                    //       //       // getUser(value);
                    //       //     }
                    //       //   } else {
                    //       //     setState(() {
                    //       //       isUser = '';
                    //       //     });
                    //       //   }
                    //       // },
                    //       keyboardType: TextInputType.number,
                    //       inputFormatters: <TextInputFormatter>[
                    //         FilteringTextInputFormatter.digitsOnly
                    //       ],
                    //       controller: phoneController,
                    //       style: const TextStyle(
                    //           fontFamily: 'EuclidCircularA Regular'),
                    //       autofocus: false,
                    //       decoration: InputDecoration(
                    //         counterText: "",
                    //         hintText: "Enter 10-digit The Phone Number",
                    //         focusedBorder: OutlineInputBorder(
                    //             borderSide: const BorderSide(
                    //               color: Palette.secondaryColor,
                    //               width: 1.3,
                    //             ),
                    //             borderRadius: BorderRadius.circular(8.0)),
                    //         enabledBorder: OutlineInputBorder(
                    //             borderSide: const BorderSide(
                    //                 color: Color(0xffffffff), width: 1.0),
                    //             borderRadius: BorderRadius.circular(8.0)),
                    //         contentPadding: const EdgeInsets.symmetric(
                    //             vertical: 8.0, horizontal: 16.0),
                    //         filled: true,
                    //         fillColor: const Color(0xffffffff),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              const SizedBox(
                height: 0.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (completephonenumber.length > 10) {
                      print(completephonenumber);
                      setState(() {
                        showLoading = true;
                      });

                      // print('+91${phoneController.text}');
                      if (kIsWeb) {
                        await _auth
                            .signInWithPhoneNumber(
                          completephonenumber,
                          RecaptchaVerifier(
                            container: null,
                            size: RecaptchaVerifierSize.compact,
                            theme: RecaptchaVerifierTheme.dark,
                            onSuccess: () {
                              setState(() {
                                showLoading = false;
                              });
                            },
                            onError: (FirebaseAuthException error) async {
                              print("error");
                              print(error);
                              setState(() {
                                showLoading = false;
                              });
                            },
                            onExpired: () async {
                              print('reCAPTCHA Expired!');
                              setState(() {
                                showLoading = false;
                              });
                            },
                          ),
                        )
                            .then((confirmationResult) {
                          // SMS sent. Prompt user to type the code from the message, then sign the
                          // user in with confirmationResult.confirm(code).
                          setState(() {
                            currentState =
                                MobileVerificationState.SHOW_OTP_FORM_STATE;
                            this.verificationId =
                                confirmationResult.verificationId;
                          });
                        }).catchError((error) {
                          print(error);
                        });
                      } else {
                        await _auth.verifyPhoneNumber(
                          phoneNumber: completephonenumber,
                          verificationCompleted:
                              (PhoneAuthCredential phoneAuthCredential) async {
                            User? user;
                            bool error = false;
                            setState(() {
                              showLoading = false;
                            });
                            try {
                              user = (await _auth.signInWithCredential(
                                      phoneAuthCredential))
                                  .user!;
                            } catch (e) {
                              print("Failed to sign in: " + e.toString());
                              error = true;
                            }
                            // await _auth
                            //     .signInWithCredential(phoneAuthCredential)
                            //     .then((value) {
                            //   print("You are logged in successfully");
                            // });
                            // await _auth.signInWithCredential(phoneAuthCredential);
                            // signInWithPhoneAuthCredential(phoneAuthCredential);
                          },
                          verificationFailed:
                              (FirebaseAuthException verificationFailed) async {
                            setState(() {
                              showLoading = false;
                            });
                            if (verificationFailed.code ==
                                'invalid-phone-number') {
                              print('The provided phone number is not valid.');
                            }
                            print(
                                'verification error: ${verificationFailed.message}');
                            print(
                                'verification error: ${verificationFailed.code}');
                            // showToast(authException.message!);
                            // _scaffoldKey.currentState!.showSnackBar(
                            //   SnackBar(
                            //     content: Text('${verificationFailed.message}'),
                            //   ),
                            // );
                          },
                          codeSent: (verificationId, resendingCode) async {
                            setState(() {
                              showLoading = false;
                              currentState =
                                  MobileVerificationState.SHOW_OTP_FORM_STATE;
                              this.verificationId = verificationId;
                            });
                          },
                          codeAutoRetrievalTimeout: (verificationId) async {},
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12.0, horizontal: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Get OTP'),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18.0,
                        )
                      ],
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                      primary: Palette.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      shadowColor: Colors.black.withOpacity(0.5),
                      elevation: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getOtpFromWidget(context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login.png',
              width: 200.0,
            ),
            // const SizedBox(
            //   height: 20.0,
            // ),
            const Text(
              'Welcome 👋',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26.0,
                  color: Palette.secondaryColor,
                  fontFamily: 'EuclidCircularA Medium'),
            ),
            const SizedBox(
              height: 10.0,
            ),
            const Text(
              'You will recieve an OTP via text message !!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color(0xffAAAEB0),
                  fontFamily: 'EuclidCircularA Regular'),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                controller: otpController,
                style: const TextStyle(fontFamily: 'EuclidCircularA Regular'),
                autofocus: false,
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "Enter 6-digit OTP",
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Palette.secondaryColor,
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(8.0)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color(0xffffffff), width: 1.0),
                      borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  filled: true,
                  fillColor: const Color(0xffffffff),
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (otpController.text.length == 6) {
                    // print('OTP Entered');
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId,
                            smsCode: otpController.text);
                    // await _auth.signInWithCredential(phoneAuthCredential);
                    signInWithPhoneAuthCredential(phoneAuthCredential);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Submit'),
                      SizedBox(
                        width: 10.0,
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18.0,
                      )
                    ],
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    primary: Palette.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    shadowColor: Colors.black.withOpacity(0.5),
                    elevation: 20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _loginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // final loggedIn = prefs.getString('loggedIn') ?? '';
    // final databasename = prefs.getString('databasename') ?? '';
    final String token = prefs.getString('token') ?? '';

    setState(() {
      deviceToken = token;
    });
    // print(databasename);
    // if (databasename != '' && loggedIn == 'true') {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const MyApp(),
    //     ),
    //   );
    // }
  }

  @override
  void initState() {
    super.initState();
    _loginStatus();
  }

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: showLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : currentState == MobileVerificationState.SHOW_MOBILE_FROM_STATE
              ? getMobileFromWidget(context)
              : getOtpFromWidget(context),
    );
  }
}
