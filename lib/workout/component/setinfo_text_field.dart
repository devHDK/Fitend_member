import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetInfoTextField extends StatefulWidget {
  final TextEditingController? controller;
  final TextInputType textInputType;
  final String allowedDigits;
  final ValueChanged<String> onChanged;
  final String? initValue;
  final Color textColor;

  const SetInfoTextField({
    super.key,
    this.controller,
    this.textInputType = TextInputType.number,
    this.allowedDigits = r'^\d*',
    required this.onChanged,
    this.initValue,
    required this.textColor,
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
      // setState(() {});
    } else {
      setState(() {
        focusNode.unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.initValue,
      controller: widget.controller,
      focusNode: focusNode,
      cursorColor: POINT_COLOR,
      textAlign: TextAlign.center,
      style: h3Headline.copyWith(color: widget.textColor),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: InputBorder.none,
      ),
      onTapOutside: (event) {
        focusNode.unfocus();
      },
      keyboardType: widget.textInputType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(widget.allowedDigits)),
      ],
      onChanged: widget.onChanged,
    );
  }
}
