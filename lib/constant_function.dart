import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:taruna_birla/config/palette.dart';

class ConstantFunction {
  //Local Variables
  bool isDevelopment = true;

  //Print Log function
  void printLog(String msg) {
    if (isDevelopment) {
      print(msg);
    }
  }

  //Update Application Popup
  Future<void> updateApplicationDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: const EdgeInsets.all(0.0),
          title: const Text(
            'App Update Available',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CenturyGothic',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Enjoy seamless experience of the application with our new update',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'EuclidCircularA Regular',
                        fontSize: 16.0,
                        color: Color(0xff8e8e8e),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            LaunchReview.launch(
                              androidAppId: "com.cheftarunbirla",
                              iOSAppId: "com.technotwist.tarunaBirla",
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Palette.contrastColor),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Update',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xfff4f4f4),
                            ),
                            child: const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12.0, horizontal: 0.0),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontFamily: 'CenturyGothic',
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
