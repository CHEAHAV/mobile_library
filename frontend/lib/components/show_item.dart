import 'package:flutter/material.dart';

class ShowItem extends StatefulWidget {
  const ShowItem({super.key});

  @override
  State<ShowItem> createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem> {
  bool burger = false;
  bool cake = false;
  bool icecream = false;
  bool noodle = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            burger = true;
            cake = false;
            icecream = false;
            noodle = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/icons/burger.png",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  color: burger ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            burger = false;
            cake = true;
            icecream = false;
            noodle = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: cake ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/icons/cake.png",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  color: cake ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            burger = false;
            cake = false;
            icecream = true;
            noodle = false;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: icecream ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  "assets/icons/icecream.png",
                  width: 45,
                  height: 45,
                  fit: BoxFit.cover,
                  color: icecream ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            burger = false;
            cake = false;
            icecream = false;
            noodle = true;
            setState(() {});
          },
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: noodle ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "assets/icons/noodle.png",
                width: 45,
                height: 45,
                fit: BoxFit.cover,
                color: noodle ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
