import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SlackSetupTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final int? maxLength;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration decoration;
  final String? hintText;

  SlackSetupTextField({
    super.key,
    required this.controller,
    this.maxLines = 1,
    this.maxLength,
    this.textInputType,
    this.inputFormatters,
    this.decoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    ),
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = hintText != null
        ? decoration.copyWith(hintText: hintText)
        : decoration;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      decoration: effectiveDecoration,
    );
  }
}
