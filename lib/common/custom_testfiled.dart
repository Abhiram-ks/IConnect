import 'package:flutter/material.dart';
import 'package:iconnect/constant/constant.dart';

import '../app_palette.dart';

class TextFormFieldWidget extends StatelessWidget {
  final String? label;
  final String hintText;
  final IconData? prefixIcon;
  final TextEditingController? controller;
  final String? Function(String? value)? validate;
  final bool enabled;
  final Color? borderClr;
  final Color? suffixIconColor;
  final Color? fillClr;
  final ValueChanged<String>? onChanged;
  final IconData? suffixIconData;
  final VoidCallback? suffixIconAction;
  final double? borderRadius;
  final int? minLines;
  final int? maxLines;
  final String? initialValue;
  final bool obscureText;
  final bool? showPasswordToggle;

  const TextFormFieldWidget({
    super.key,
    this.label,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.validate,
    this.enabled = true,
    this.borderClr,
    this.fillClr,
    this.suffixIconColor,
    this.onChanged,
    this.suffixIconData,
    this.suffixIconAction,
    this.borderRadius = 10,
    this.minLines = 1,
    this.maxLines = 1,
    this.initialValue,
    this.obscureText = false,
    this.showPasswordToggle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5),
            child: Text(
              label ?? 'No ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),

        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validate,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 16),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enabled: enabled,
          onChanged: onChanged,
          minLines: minLines,

          maxLines: maxLines,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            filled: fillClr != null,
            fillColor: fillClr,
            hintText: hintText,
            hintStyle: TextStyle(color: AppPalette.hintColor),
            prefixIcon:
                prefixIcon != null
                    ? Icon(
                      prefixIcon,
                      color: const Color.fromARGB(255, 52, 52, 52),
                    )
                    : null,
            suffixIcon:
                (suffixIconData != null)
                    ? GestureDetector(
                      onTap: () {
                        if (suffixIconData != null) {
                          suffixIconAction?.call();
                        }
                      },
                      child: Icon(suffixIconData, color: suffixIconColor),
                    )
                    : null,

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.00),
              borderSide: BorderSide(
                color: borderClr ?? AppPalette.hintColor,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.00),
              borderSide: BorderSide(color: AppPalette.blueColor, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.00),
              borderSide: BorderSide(color: AppPalette.redColor, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 10.00),
              borderSide: BorderSide(color: AppPalette.redColor, width: 1),
            ),
          ),
        ),
        ConstantWidgets.hight10(context),
      ],
    );
  }
}
