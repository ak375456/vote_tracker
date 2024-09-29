import 'package:flutter/material.dart';
import 'package:vote_tracker/constants.dart';

class MyTextFormField extends StatefulWidget {
  const MyTextFormField(
      {super.key,
      required this.labelText,
      this.prefixIcon,
      this.suffixIcon,
      this.hideText = false,
      this.controller,
      required this.validator,
      this.initialValue,
      this.onChanged,
      this.hasError = false,
      this.onSuffixIconPressed,
      this.readOnly = false,
      this.hintText,
      this.prefixText,
      this.textInputType,
      this.suffixText,
      this.maxLength});

  final String? hintText;
  final String labelText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool hideText;
  final TextEditingController? controller;
  final String? Function(String?) validator;
  final String? initialValue;
  final String? Function(String)? onChanged;
  final bool hasError;
  final VoidCallback? onSuffixIconPressed;
  final bool readOnly;
  final String? prefixText;
  final TextInputType? textInputType;
  final String? suffixText;
  final int? maxLength; // Add a maxLength parameter

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool isFocused = false;
  late FocusNode _focusNode;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    if (widget.maxLength != null &&
        _controller.text.length > widget.maxLength!) {
      _controller.text = _controller.text.substring(0, widget.maxLength!);
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        keyboardType: widget.textInputType,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        obscureText: widget.hideText,
        controller: _controller,
        validator: widget.validator,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              15,
            ),
          ),
          suffixText: widget.suffixText,
          prefixText: widget.prefixText,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixIconPressed,
                  child: Icon(
                    widget.suffixIcon,
                    color: isFocused
                        ? darkGreenColor
                        : (widget.hasError ? Colors.red : null),
                  ),
                )
              : null,
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: isFocused
                ? const Color(0xff2D8BBA)
                : (widget.hasError ? Colors.red : null),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: darkGreenColor,
            ),
          ),
          errorStyle: const TextStyle(
            color: Colors.red,
          ),
        ),
        focusNode: _focusNode,
      ),
    );
  }
}
