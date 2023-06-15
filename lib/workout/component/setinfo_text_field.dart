import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';

class SetInfoTextField extends StatefulWidget {
  final TextEditingController controller;
  TextInputType? textInputType;

  SetInfoTextField({
    super.key,
    required this.controller,
    this.textInputType = TextInputType.number,
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
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: LIGHT_GRAY_COLOR,
        hoverColor: POINT_COLOR,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
            style: BorderStyle.none,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.transparent,
            style: BorderStyle.none,
          ),
        ),
      ),
      keyboardType: widget.textInputType,
    );
  }
}
