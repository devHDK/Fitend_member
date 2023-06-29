import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:ndialog/ndialog.dart';

class ErrorDialog extends StatelessWidget {
  final String error;

  const ErrorDialog({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return NAlertDialog(
      title: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Center(
            child: Text(
          '$error😂',
          style: s2SubTitle,
        )),
      ),
      dialogStyle: DialogStyle(
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Container(
            width: 279,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: POINT_COLOR,
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Text(
                '확인',
                style: h6Headline.copyWith(
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
