import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        color: Colors.white,
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
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(widget.allowedDigits)),
      ],
    );
  }
}

// class RangeTextInputFormatter extends TextInputFormatter {
//   final int min;
//   final int max;

//   RangeTextInputFormatter({
//     required this.min,
//     required this.max,
//   });

//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     int enteredValue = int.tryParse(newValue.text) ?? 0;
//     if (enteredValue < min) {
//       enteredValue = min;
//     } else if (enteredValue > max) {
//       enteredValue = max;
//     }

//     return TextEditingValue(
//       text: enteredValue.toString(),
//       selection:
//           TextSelection.collapsed(offset: enteredValue.toString().length),
//     );
//   }
// }
