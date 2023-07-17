import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/notifications/model/notification_model.dart';
import 'package:flutter/material.dart';

class NotificationCell extends StatelessWidget {
  const NotificationCell({
    super.key,
    required this.notificationData,
  });

  final NotificationData notificationData;

  @override
  Widget build(BuildContext context) {
    var tempContents = notificationData.contents.split('\n');
    final temp = tempContents.last.replaceAll("|", '∙');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 12,
        ),
        Text(
          tempContents.first,
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          temp,
          style: s2SubTitle.copyWith(
            color: LIGHT_GRAY_COLOR,
          ),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
