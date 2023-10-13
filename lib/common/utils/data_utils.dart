import 'dart:convert';

import 'package:fitend_member/common/const/data.dart';
import 'package:url_launcher/url_launcher.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://$localIp$value';
  }

  static List<String> listPathsToUrls(List paths) {
    return paths.map((e) => pathToUrl(e)).toList();
  }

  static String plainToBase64(String plain) {
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(plain);

    return encoded;
  }

  static DateTime getDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static onWebViewTap({required String uri}) async {
    final url = Uri.parse(uri);
    await launchUrl(
      url,
      mode: LaunchMode.platformDefault,
    );
  }

  static getWorkoutPushType(String type) {
    switch (type) {
      case 'workoutScheduleCreate':
        return WorkoutPushType.workoutScheduleCreate;
      case 'workoutScheduleDelete':
        return WorkoutPushType.workoutScheduleDelete;
      case 'workoutScheduleChange':
        return WorkoutPushType.workoutScheduleChange;
      default:
    }
  }

  static String getTimeStringHour(int seconds) {
    String ret =
        '${(seconds / 3600).floor().toString().padLeft(2, '0')} : ${((seconds % 3600) / 60).floor().toString().padLeft(2, '0')} : ${(seconds % 60).floor().toString().padLeft(2, '0')}';

    return ret;
  }

  static String getTimeStringMinutes(int seconds) {
    String ret =
        '${(seconds / 60).floor().toString().padLeft(2, '0')} : ${(seconds % 60).floor().toString().padLeft(2, '0')}';

    return ret;
  }

  static String getTimerString(int seconds) {
    String ret = '';

    if ((seconds / 3600).floor() > 0) {
      ret += '${(seconds / 3600).floor()}시간 ';
    }

    if (((seconds % 3600) / 60).floor() > 0) {
      ret += '${((seconds % 3600) / 60).floor()}분 ';
    }

    if ((seconds % 60) > 0) {
      ret += '${seconds % 60}초';
    }

    return ret;
  }

  static String getTimerStringMinuteSeconds(int seconds) {
    String ret = '';

    if ((seconds / 60).floor() > 0) {
      ret += '${(seconds / 60).floor()}분 ';
    }

    if ((seconds % 60) > 0) {
      ret += '${seconds % 60}초';
    }

    return ret;
  }

  static String getDateFromDateTime(DateTime dateTime) {
    String date = '${dateTime.year}-${dateTime.month}-${dateTime.day}';

    return date;
  }

  static String getMonthDayFromDateTime(DateTime dateTime) {
    String date = '${dateTime.month}월 ${dateTime.day}일';

    return date;
  }
}
