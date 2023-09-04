import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SetInfoTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType textInputType;
  final String allowedDigits;

  const SetInfoTextField({
    super.key,
    required this.controller,
    this.textInputType = TextInputType.number,
    this.allowedDigits = r'^\d*',
  });

  @override
  State<SetInfoTextField> createState() => _SetInfoTextFieldState();
}

class _SetInfoTextFieldState extends State<SetInfoTextField> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {});
    } else {
      setState(() {
        focusNode.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: focusNode,
      cursorColor: POINT_COLOR,
      textAlign: TextAlign.center,
      style: h3Headline.copyWith(
        color: Colors.black,
      ),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: InputBorder.none,
      ),
      keyboardType: widget.textInputType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(widget.allowedDigits)),
      ],
    );
  }
}
