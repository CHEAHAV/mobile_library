import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onTap;
  final bool dark; // true = dark hero style, false = light style

  const CircleButton({
    super.key,
    this.icon,
    this.child,
    this.onTap,
    this.dark = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: dark
              // ignore: deprecated_member_use
              ? Colors.white.withOpacity(0.15)
              : const Color(0xFFFFF8E7),
          shape: BoxShape.circle,
          border: Border.all(
            color: dark
                // ignore: deprecated_member_use
                ? Colors.white.withOpacity(0.2)
                // ignore: deprecated_member_use
                : const Color(0xFFD4A853).withOpacity(0.4),
          ),
          boxShadow: dark
              ? []
              : [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child:
            child ??
            Icon(
              icon,
              color: dark ? Colors.white : const Color(0xFF3E2A00),
              size: 18,
            ),
      ),
    );
  }
}
