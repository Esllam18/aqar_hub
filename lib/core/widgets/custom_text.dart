import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String txt;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final String? fontFamily;
  final double? letterSpacing;
  final FontStyle? fontStyle;
  final TextStyle? style;

  const CustomText({
    super.key,
    required this.txt,
    this.maxLines,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.overflow,
    this.fontFamily,
    this.letterSpacing,
    this.fontStyle,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive font scaling
    final double scaledFontSize = fontSize != null
        ? MediaQuery.textScalerOf(context).scale(fontSize!)
        : MediaQuery.textScalerOf(context).scale(
            style?.fontSize ??
                Theme.of(context).textTheme.bodyLarge?.fontSize ??
                16,
          );

    final TextStyle baseStyle =
        style ??
        Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontSize: scaledFontSize,
          fontWeight: fontWeight,
          color: color,
          fontFamily: fontFamily,
          letterSpacing: letterSpacing,
          fontStyle: fontStyle,
        );

    return Text(
      txt,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: overflow ?? TextOverflow.ellipsis,
      style: baseStyle,
    );
  }
}
