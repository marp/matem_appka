import 'package:flutter/material.dart';

enum ButtonType {
  number,
  operation,
  action,
  clear,
}

class CalcButtonModel {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final VoidCallback? onTap;
  final double height;
  final ButtonType type;
  final IconData? icon;

  const CalcButtonModel({
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.onTap,
    this.height = 1.0,
    this.type = ButtonType.number,
    this.icon,
  });

  CalcButtonModel copyWith({
    String? text,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
    VoidCallback? onTap,
    double? height,
    ButtonType? type,
    IconData? icon,
  }) {
    return CalcButtonModel(
      text: text ?? this.text,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      onTap: onTap ?? this.onTap,
      height: height ?? this.height,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}
