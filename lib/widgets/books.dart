import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taruna_birla/config/book.dart';
import 'package:taruna_birla/pages/books_page.dart';
import 'package:taruna_birla/pages/each_book.dart';
import 'package:taruna_birla/services/mysql_db_service.dart';

class Books extends StatefulWidget {
  const Books({Key? key}) : super(key: key);

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  List list = [];
  bool isLoading = false;

  Future<void> getImpBooks() async {
    Map<String, dynamic> _getNews = await MySqlDBService().runQuery(
      requestType: RequestType.GET,
      url: 'https://dashboard.cheftarunabirla.com/getImpBooks',
    );

    bool _status = _getNews['status'];
    var _data = _getNews['data'];
    // print(_data);
    if (_status) {
      // data loaded
      list.clear();
      for (var i = 0; i < _data['data'].length; i++) {
        list.add(
          Book(
            id: _data['data'][i]['id'].toString(),
            title: _data['data'][i]['title'].toString(),
            description: _data['data'][i]['description'].toString(),
            price: _data['data'][i]['price'].toString(),
            discount_price: _data['data'][i]['discount_price'].toString(),
            days: _data['data'][i]['days'],
            category: _data['data'][i]['category'].toString(),
            image_path: _data['data'][i]['image_path'].toString(),
            count: 0,
            pdflink: _data['data'][i]['pdf'].toString() == 'null'
                ? ''
                : _data['data'][i]['pdf'].toString(),
          ),
        );
      }
      setState(() => isLoading = true);
    } else {
      print('Something went wrong.');
    }
  }

  @override
  void initState() {
    super.initState();
    getImpBooks();
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
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Our Books',
                      style: TextStyle(
                        fontFamily: 'CenturyGothic',
                        fontSize: 24.0,
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BooksPage(),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 24.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 30.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EachBook(
                                name: list[0].title,
                                description: list[0].description,
                                id: list[0].id,
                                price: list[0].price,
                                category: list[0].category,
                                discount_price: list[0].discount_price,
                                pdflink: list[0].pdflink,
                              ),
                            ),
                          );
                        },
                        child: BookCard(
                          image: list[0].image_path,
                          name: list[0].title,
                        ),
                      ),
                      const SizedBox(
                        width: 24.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EachBook(
                                name: list[1].title,
                                description: list[1].description,
                                id: list[1].id,
                                price: list[1].price,
                                category: list[1].category,
                                discount_price: list[1].discount_price,
                                pdflink: list[1].pdflink,
                              ),
                            ),
                          );
                        },
                        child: BookCard(
                          image: list[1].image_path,
                          name: list[1].title,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }
}

class BookCard extends StatelessWidget {
  final String image;
  final String name;
  const BookCard({
    Key? key,
    required this.image,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220.0,
      width: 158.0,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: CachedNetworkImage(
            imageUrl: 'https://dashboard.cheftarunabirla.com$image',
            // placeholder: (context, url) => const Center(
            //     child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            // fadeOutDuration: const Duration(seconds: 1),
            // fadeInDuration: const Duration(seconds: 1),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 220.0,
          ),
          // Image.network(
          //   'https://dashboard.cheftarunabirla.com$image',
          //   // width: 250.0,
          //   height: 220,
          //   fit: BoxFit.cover,
          // ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xff000000).withOpacity(0.5),
            blurRadius: 30.0, // soften the shadow
            spreadRadius: 0.0, //extend the shadow
            offset: const Offset(
              4.0, // Move to right 10  horizontally
              8.0, // Move to bottom 10 Vertically
            ),
          ),
        ],
      ),
    );
  }
}
