import 'dart:io';

import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ndialog/ndialog.dart';

class ErrorScreen extends StatelessWidget {
  static String get routeName => 'error';

  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: NAlertDialog(
        title: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Center(
            child: Text(
              '서버와 통신하는동안 문제가 생겼습니다.',
              style: s2SubTitle,
            ),
          ),
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
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (Platform.isIOS) {
                    exit(0);
                  } else {
                    SystemNavigator.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: POINT_COLOR,
                ),
                child: Text(
                  '확인',
                  style: h6Headline.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
