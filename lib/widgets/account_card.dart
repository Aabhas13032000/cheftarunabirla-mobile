import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:taruna_birla/config/palette.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 24.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xffFFF0D0).withOpacity(0.9),
              blurRadius: 30.0, // soften the shadow
              spreadRadius: 0.0, //extend the shadow
              offset: const Offset(
                4.0, // Move to right 10  horizontally
                8.0, // Move to bottom 10 Vertically
              ),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                child: CircleAvatar(
                  backgroundColor: Palette.secondaryColor,
                  // backgroundImage: AssetImage('assets/images/blog.jpeg'),
                  radius: 25.0,
                  child: Icon(
                    MdiIcons.cartOutline,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 5.0),
                child: Row(
                  children: [
                    const Text(
                      'Orders',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontFamily: 'EuclidCircularA Medium'),
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Container(
                      // width: 20.0,
                      height: 20.0,
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 0.0, horizontal: 7.8),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'EuclidCircularA Regular',
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(100.0)),
                    )
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
