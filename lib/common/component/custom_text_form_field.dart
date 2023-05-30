import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? hintText;
  final String? errorText;
  final String? labelText;
  final String? fullLabelText;
  final bool obscureText;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;
  final TextInputType? textInputType;
  final Iterable<String>? autoFillHint;
  final TextEditingController controller;

  const CustomTextFormField({
    super.key,
    this.hintText,
    this.errorText,
    this.labelText,
    this.fullLabelText,
    this.obscureText = false,
    this.autoFocus = false,
    required this.onChanged,
    required this.controller,
    this.textInputType,
    this.autoFillHint,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      // print('${widget.labelText} ,${focusNode.hasFocus}');
      if (focusNode.hasFocus) {
        setState(() {
          focusNode.requestFocus();
        });
      } else {
        setState(() {
          focusNode.unfocus();
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: DARK_GRAY_COLOR,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );

    return TextFormField(
        controller: widget.controller,
        style: const TextStyle(color: Colors.white),
        cursorColor: POINT_COLOR,
        //비밀번호 입력할때
        obscureText: widget.obscureText,
        autofocus: widget.autoFocus,
        focusNode: focusNode,
        onChanged: widget.onChanged,
        keyboardType: widget.textInputType,
        autofillHints: widget.autoFillHint,
        onTapOutside: (event) {
          focusNode.unfocus();
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          hintText: widget.hintText,
          // errorText: errorText,
          hintStyle: const TextStyle(
            color: GRAY_COLOR,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
          filled: true,
          fillColor: BACKGROUND_COLOR,
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
              color: POINT_COLOR,
            ),
          ),
          labelText: focusNode.hasFocus || widget.controller.text.isEmpty
              ? widget.fullLabelText
              : widget.labelText,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? POINT_COLOR : GRAY_COLOR,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ));
  }
}
