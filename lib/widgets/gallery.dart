import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:taruna_birla/pages/open_image.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class Gallery extends StatefulWidget {
  const Gallery({Key? key}) : super(key: key);

  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List list = [];
  bool isLoading = false;

  Future<void> getGalleryImages() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getGalleryImpImages/0',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(_data['data'][i]['path'].toString());
      }
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  @override
  void initState() {
    super.initState();
    getGalleryImages();
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
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth < 768) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: 'https://dashboard.cheftarunabirla.com${list[0]}'),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: 'https://dashboard.cheftarunabirla.com${list[0]}',
                            // placeholder: (context, url) => const Center(
                            //     child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            // fadeOutDuration: const Duration(seconds: 1),
                            // fadeInDuration: const Duration(seconds: 1),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 224.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenImage(
                                      url:
                                          'https://dashboard.cheftarunabirla.com${list[1]}'),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: 'https://dashboard.cheftarunabirla.com${list[1]}',
                                // placeholder: (context, url) => const Center(
                                //     child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                // fadeOutDuration: const Duration(seconds: 1),
                                // fadeInDuration: const Duration(seconds: 1),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 105.0,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 14.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OpenImage(
                                      url:
                                          'https://dashboard.cheftarunabirla.com${list[2]}'),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: CachedNetworkImage(
                                imageUrl: 'https://dashboard.cheftarunabirla.com${list[2]}',
                                // placeholder: (context, url) => const Center(
                                //     child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                // fadeOutDuration: const Duration(seconds: 1),
                                // fadeInDuration: const Duration(seconds: 1),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 105.0,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              if (constraints.maxWidth < 2560) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: 'https://dashboard.cheftarunabirla.com${list[0]}'),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: 'https://dashboard.cheftarunabirla.com${list[0]}',
                            // placeholder: (context, url) => const Center(
                            //     child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            // fadeOutDuration: const Duration(seconds: 1),
                            // fadeInDuration: const Duration(seconds: 1),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: 'https://dashboard.cheftarunabirla.com${list[1]}'),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: 'https://dashboard.cheftarunabirla.com${list[1]}',
                            // placeholder: (context, url) => const Center(
                            //     child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            // fadeOutDuration: const Duration(seconds: 1),
                            // fadeInDuration: const Duration(seconds: 1),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenImage(
                                  url: 'https://dashboard.cheftarunabirla.com${list[2]}'),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: CachedNetworkImage(
                            imageUrl: 'https://dashboard.cheftarunabirla.com${list[2]}',
                            // placeholder: (context, url) => const Center(
                            //     child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            // fadeOutDuration: const Duration(seconds: 1),
                            // fadeInDuration: const Duration(seconds: 1),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 350.0,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: 'https://dashboard.cheftarunabirla.com${list[0]}',
                          // placeholder: (context, url) => const Center(
                          //     child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          // fadeOutDuration: const Duration(seconds: 1),
                          // fadeInDuration: const Duration(seconds: 1),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                        // Image.network(
                        //   'https://dashboard.cheftarunabirla.com${list[0]}',
                        //   height: 224.0,
                        //   fit: BoxFit.cover,
                        //   width: double.infinity,
                        //   alignment: Alignment.topCenter,
                        // ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: 'https://dashboard.cheftarunabirla.com${list[1]}',
                          // placeholder: (context, url) => const Center(
                          //     child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          // fadeOutDuration: const Duration(seconds: 1),
                          // fadeInDuration: const Duration(seconds: 1),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                        // Image.network(
                        //   'https://dashboard.cheftarunabirla.com${list[1]}',
                        //   height: 224.0,
                        //   fit: BoxFit.cover,
                        //   width: double.infinity,
                        //   alignment: Alignment.topCenter,
                        // ),
                      ),
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: CachedNetworkImage(
                          imageUrl: 'https://dashboard.cheftarunabirla.com${list[2]}',
                          // placeholder: (context, url) => const Center(
                          //     child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          // fadeOutDuration: const Duration(seconds: 1),
                          // fadeInDuration: const Duration(seconds: 1),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 224.0,
                          alignment: Alignment.topCenter,
                        ),
                        // Image.network(
                        //   'https://dashboard.cheftarunabirla.com${list[2]}',
                        //   height: 224.0,
                        //   fit: BoxFit.cover,
                        //   width: double.infinity,
                        //   alignment: Alignment.topCenter,
                        // ),
                      ),
                    ),
                  ],
                );
              }
            },
          );
  }
}
