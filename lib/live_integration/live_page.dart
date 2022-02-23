import 'package:flutter/material.dart';
import 'package:taruna_birla/config/palette.dart';
import 'package:taruna_birla/widgets/webviewx_page.dart';

class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  // Future<void> initialiseCalenderApi() async {
  //   var _clientID = ClientId(Secret.getId(), "");
  //   const _scopes = [cal.CalendarApi.calendarScope];
  //   await clientViaUserConsent(_clientID, _scopes, prompt)
  //       .then((AuthClient client) async {
  //     CalendarClient.calendar = cal.CalendarApi(client);
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.scaffoldColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
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
      body:
          // YoutubePlayerPage(
          //   url: '2Gw1geZE8KE',
          //   fullScreen: false,
          // )
          const WebviewXPage(
        fullScreen: false,
        url: 'https://www.youtube.com/watch?v=2Gw1geZE8KE',
      ),
      // Center(
      //   child: Image.asset(
      //     'assets/images/coming-soon.png',
      //     width: 200.0,
      //   ),
      // ),
    );
  }
}
