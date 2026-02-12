import 'package:flutter/material.dart';

import '../model/calc_button_model.dart';

class CalcButton extends StatefulWidget {
  final CalcButtonModel buttonModel;

  const CalcButton({
    super.key,
    required this.buttonModel,
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
    // Użyj koloru z modelu lub domyślnego na podstawie typu przycisku
    Color buttonColor = widget.buttonModel.backgroundColor ?? _getDefaultColor();
    Color textColor = widget.buttonModel.textColor ?? Colors.white;
    double fontSize = widget.buttonModel.fontSize ?? 26;
    FontWeight fontWeight = widget.buttonModel.fontWeight ?? FontWeight.normal;

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
        onTap: () {
          _controller.forward();
          Future.delayed(const Duration(milliseconds: 50), () {
            _controller.reverse();
          });
          widget.buttonModel.onTap?.call();
        },
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 1.1,
            end: 0.9,
          ).animate(_controller),
          child: Container(
            height: 56.0 * widget.buttonModel.height,
              decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(4),
            ),
              child: Center(
              child: widget.buttonModel.icon != null
                ? Icon(
                    widget.buttonModel.icon,
                    color: textColor,
                    size: fontSize,
                  )
                : Text(
                    widget.buttonModel.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                    ),
                  ),
            ),
          ),
        ),)
    );
  }

  Color _getDefaultColor() {
    switch (widget.buttonModel.type) {
      case ButtonType.clear:
        return Colors.red;
      case ButtonType.action:
        return Colors.green;
      case ButtonType.operation:
        return Colors.deepPurple;
      case ButtonType.number:
      default:
        return Colors.deepPurple[400] ?? Colors.deepPurple;
    }
  }
}
