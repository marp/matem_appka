import 'package:flutter/material.dart';

import '../const/colors.dart';

class CalcButton extends StatefulWidget {
  final String child;
  final VoidCallback onTap;

  final double height;

  const CalcButton({
    super.key,
    required this.child,
    required this.onTap,
    this.height = 1,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50), // Reduced duration for faster animation
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var buttonColor = Colors.deepPurple[400];

    if (widget.child == 'C') {
      buttonColor = Colors.red;
    } else if (widget.child == '⌫') {
      buttonColor = Colors.green;
    } else if (widget.child == '=') {
      buttonColor = Colors.deepPurple;
    }

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
        onTap: () {
          _controller.forward();
          Future.delayed(const Duration(milliseconds: 150), () {
            _controller.reverse();
          });
          widget.onTap();
        },
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.1,
            end: 0.9,
          ).animate(_controller),
          child: Container(
            height: 56.0 * widget.height,
              decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(4),
            ),
              child: Center(
              child: Text(widget.child, style: whiteTextStyle),
            ),
          ),
        ),)
    );
  }
}