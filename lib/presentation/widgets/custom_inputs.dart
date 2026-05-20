import 'package:flutter/material.dart';

class ToquiTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool isNumber;
  final bool isPassword;
  final int? maxLines;

  const ToquiTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.isNumber = false,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines == null || maxLines! > 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        maxLines: isPassword ? 1 : maxLines,
        keyboardType: isNumber
            ? TextInputType.number
            : (isMultiline ? TextInputType.multiline : TextInputType.text),
        textAlignVertical: isMultiline
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[50],
          alignLabelWithHint: isMultiline,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
    );
  }
}
