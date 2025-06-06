import 'package:flutter/material.dart';

class HomeButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final buttonColor = Colors.deepPurple[400];

  HomeButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: buttonColor, borderRadius: BorderRadius.circular(4)),
              child: Center(
                child: child,
              )),
        ));
  }
}
