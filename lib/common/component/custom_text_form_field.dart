import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final List<TextInputFormatter>? formatter;
  final int? maxLength;
  final int? maxLine;

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
    this.formatter,
    this.maxLength,
    this.maxLine = 1,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (focusNode.hasFocus) {
      setState(() {
        // focusNode.requestFocus();
      });
    } else {
      if (mounted) {
        setState(() {
          focusNode.unfocus();
        });
      }
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChanged);
    focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Pallete.darkGray,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(10),
    );

    return TextFormField(
      maxLength: widget.maxLength,
      maxLines: widget.maxLine,
      autocorrect: false,
      controller: widget.controller,
      style: const TextStyle(
        color: Colors.white,
      ),
      cursorColor: Pallete.point,
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
      inputFormatters: widget.formatter,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          hintText: widget.hintText,
          // errorText: errorText,
          hintStyle: s2SubTitle.copyWith(
            color: Pallete.gray,
          ),
          filled: true,
          fillColor: Pallete.background,
          border: baseBorder,
          enabledBorder: baseBorder,
          focusedBorder: baseBorder.copyWith(
            borderSide: baseBorder.borderSide.copyWith(
              color: Pallete.point,
            ),
          ),
          labelText: focusNode.hasFocus || widget.controller.text.isEmpty
              ? widget.fullLabelText
              : widget.labelText,
          labelStyle: s2SubTitle.copyWith(
            color: focusNode.hasFocus ? Pallete.point : Pallete.gray,
          ),
          counterText: ''),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    var newString = '';
    var index = 0;

    for (var i = 0; i < digitsOnly.length; i++) {
      newString += digitsOnly[i];

      if (index == 2 || index == 6) {
        newString += '-';
      }
      index++;
    }

    // 새로운 문자열의 길이에서 추가된 '-'의 개수를 뺀 값이 커서의 위치가 되어야 합니다.
    var selectionOffset = newString.isNotEmpty ? newString.length - 1 : 0;

    return newValue.copyWith(
      text: newString,
      selection: newString.isNotEmpty && newString[newString.length - 1] != '-'
          ? TextSelection.collapsed(offset: newString.length)
          : TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
