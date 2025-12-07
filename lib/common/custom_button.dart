
import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart' show AppPalette;

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color bgColor;
  final Color textColor;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.bgColor = AppPalette.blackColor,
    this.textColor = AppPalette.whiteColor,
    this.borderRadius = 30,
    this.borderColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child:  ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              padding: padding,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                side:
                    borderColor != null
                        ? BorderSide(color: borderColor!)
                        : BorderSide.none,
              ),
            ),
            onPressed: onPressed,
            child: Center(
              child: onPressed == null
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: textColor,
                        fontWeight: fontWeight,
                      ),
                    ),
            ),
          )
    );
  }
}
