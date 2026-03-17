import 'package:flutter/material.dart';

class MyInformationField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final Widget? prefixIcon;
  final bool obscreText;
  const MyInformationField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.obscreText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: TextField(
          controller: controller,
          obscureText: obscreText,
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            labelText: labelText,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }
}
