import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:taruna_birla/live_integration/live_page.dart';
import 'package:taruna_birla/models/current_index.dart';
import 'package:taruna_birla/models/selected_value.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class Courses extends StatefulWidget {
  const Courses({
    Key? key,
  }) : super(key: key);

  @override
  State<Courses> createState() => _CoursesState();
}

class _CoursesState extends State<Courses> with AutomaticKeepAliveClientMixin {
  List imageList = [];
  List nameList = [];
  bool isLoading = false;

  Future<void> getCourseCategory() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getCourseCategories',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      nameList.clear();
      imageList.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        nameList.add(_data['data'][i]['name'].toString());
        imageList.add(_data['data'][i]['path'].toString());
      }
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  @override
  void initState() {
    super.initState();
    getCourseCategory();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : SizedBox(
            height: 182.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    context.read<CurrentIndex>().setIndex(2);
                    Provider.of<SelectedValue>(context, listen: false)
                        .setSelectedValue('Online');
                  },
                  child: CourseCard(
                    name: 'Online\nCourses',
                    marginLeft: 24.0,
                    marginRight: 0.0,
                    imagePath:
                        'https://dashboard.cheftarunabirla.com${imageList[nameList.indexOf('online')]}',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<CurrentIndex>().setIndex(2);
                    Provider.of<SelectedValue>(context, listen: false)
                        .setSelectedValue('Offline');
                  },
                  child: CourseCard(
                    name: 'Offline\nCourses',
                    marginLeft: 20.0,
                    marginRight: 0.0,
                    imagePath:
                        'https://dashboard.cheftarunabirla.com${imageList[nameList.indexOf('offline')]}',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LivePage(),
                      ),
                    );
                  },
                  child: CourseCard(
                    name: 'Live\nClasses',
                    marginLeft: 20.0,
                    marginRight: 0.0,
                    imagePath:
                        'https://dashboard.cheftarunabirla.com${imageList[nameList.indexOf('live')]}',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<CurrentIndex>().setIndex(2);
                    Provider.of<SelectedValue>(context, listen: false)
                        .setSelectedValue('Free');
                  },
                  child: CourseCard(
                    name: 'Free\nCourses',
                    marginLeft: 20.0,
                    marginRight: 24.0,
                    imagePath:
                        'https://dashboard.cheftarunabirla.com${imageList[nameList.indexOf('free')]}',
                  ),
                ),
              ],
            ),
          );
  }

  @override
  bool get wantKeepAlive => true;
}

class CourseCard extends StatelessWidget {
  final String name;
  final double marginLeft;
  final double marginRight;
  final String imagePath;

  const CourseCard({
    Key? key,
    required this.name,
    required this.marginLeft,
    required this.imagePath,
    required this.marginRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(marginLeft, 0.0, marginRight, 0.0),
      width: 144.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imagePath,
              // placeholder: (context, url) =>
              //     const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              // fadeOutDuration: const Duration(seconds: 1),
              // fadeInDuration: const Duration(seconds: 1),
              fit: BoxFit.cover,
              width: 144.0,
              height: 182.0,
            ),
            // Image.network(
            //   imagePath,
            //   fit: BoxFit.cover,
            //   width: 144.0,
            //   height: 182.0,
            // ),
            Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.93),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontFamily: 'EuclidCircularA Medium'),
                      ),
                    ),
                    Container(
                      height: 32.0,
                      width: 32.0,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30.0)),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16.0,
                        ),
                      ),
                    ),
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
