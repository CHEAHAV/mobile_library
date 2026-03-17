import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:frontend/styles/app_styles.dart';

class MyButton extends StatelessWidget {
  final Function()? onTap;
  final String text;
  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
    required bool isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DropShadow(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Center(
            child: Text(
              text,
              style: AppStyles.simpleboolTextStyle().copyWith(
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
