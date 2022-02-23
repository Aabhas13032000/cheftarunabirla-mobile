import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:taruna_birla/models/current_index.dart';
import 'package:taruna_birla/models/selected_value.dart';
import 'package:taruna_birla/pages/inshop_page.dart';

class OurStore extends StatelessWidget {
  const OurStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 576) {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InshopPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 125.0,
                          child: Center(
                            child: Image.asset(
                              'assets/images/inshop1.jpg',
                              // width: 117.0,
                              height: 125.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.4),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InshopPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 125.0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/images/amazon_logo.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.4),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
                child: GestureDetector(
                  onTap: () {
                    context.read<CurrentIndex>().setIndex(3);
                    Provider.of<SelectedValue>(context, listen: false)
                        .setSelectedValue('All');
                  },
                  child: Container(
                    height: 125.0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          'assets/images/0002.jpg',
                          width: 250.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xffE2C6BA),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xffFFF0D0).withOpacity(0.4),
                          blurRadius: 30.0, // soften the shadow
                          spreadRadius: 0.0, //extend the shadow
                          offset: const Offset(
                            4.0, // Move to right 10  horizontally
                            8.0, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        } else {
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InshopPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 125.0,
                          child: Center(
                            child: Image.asset(
                              'assets/images/inshop1.jpg',
                              // width: 117.0,
                              height: 125.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.4),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InshopPage(),
                            ),
                          );
                        },
                        child: Container(
                          height: 125.0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/images/amazon_logo.png',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.4),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24.0,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          context.read<CurrentIndex>().setIndex(3);
                          Provider.of<SelectedValue>(context, listen: false)
                              .setSelectedValue('All');
                        },
                        child: Container(
                          height: 125.0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Image.asset(
                                'assets/images/0002.jpg',
                                width: 250.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Color(0xffE2C6BA),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xffFFF0D0).withOpacity(0.4),
                                blurRadius: 30.0, // soften the shadow
                                spreadRadius: 0.0, //extend the shadow
                                offset: const Offset(
                                  4.0, // Move to right 10  horizontally
                                  8.0, // Move to bottom 10 Vertically
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
