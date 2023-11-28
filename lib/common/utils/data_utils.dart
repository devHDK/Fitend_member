import 'dart:convert';
import 'dart:io';

import 'package:fitend_member/common/const/data_constants.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DataUtils {
  static String pathToUrl(String value) {
    return 'http://${URLConstants.localIp}$value';
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

  static getThreadPushType(String type) {
    switch (type) {
      case 'threadCreate':
        return ThreadPushType.threadCreate;
      case 'threadDelete':
        return ThreadPushType.threadDelete;
      case 'threadUpdate':
        return ThreadPushType.threadUpdate;
      default:
    }
  }

  static getCommentPushType(String type) {
    switch (type) {
      case 'commentCreate':
        return CommentPushType.commentCreate;
      case 'commentDelete':
        return CommentPushType.commentDelete;
      case 'commentUpdate':
        return CommentPushType.commentUpdate;
      default:
    }
  }

  static getEmojiPushType(String type) {
    switch (type) {
      case 'emojiCreate':
        return EmojiPushType.emojiCreate;
      case 'emojiDelete':
        return EmojiPushType.emojiDelete;

      default:
    }
  }

  static String getTimeStringHour(int seconds) {
    String ret =
        '${(seconds / 3600).floor().toString().padLeft(2, '0')} : ${((seconds % 3600) / 60).floor().toString().padLeft(2, '0')} : ${(seconds % 60).floor().toString().padLeft(2, '0')}';

    return ret;
  }

  static String getTimeStringMinutes(int seconds) {
    //string seconds => 00:00

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

  static String getElapsedTimeStringFromNow(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금전';
    }

    if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    }

    if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    }

    if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    }

    if (difference.inDays >= 31 && difference.inDays < 365) {
      return '${(difference.inDays / 31).floor()}달 전';
    }

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()}달 전';
    }

    return DateFormat('h:mm a').format(dateTime).toString();
  }

  static void launchURL(String url) async {
    String tempUrl = url;
    if (!tempUrl.contains('https://')) {
      tempUrl = 'https://$tempUrl';
    }

    await canLaunchUrlString(tempUrl)
        ? await launchUrlString(tempUrl)
        : throw 'Could not launch $tempUrl';
  }

  static Future<bool> checkFileSize(List<String> assetPaths) async {
    const limitFileSize = 400 * 1000 * 1000; //200mb
    for (var filePath in assetPaths) {
      final file = File(filePath);

      if (await file.exists()) {
        final fileSize = await file.length(); //byte

        if (limitFileSize < fileSize) {
          return true;
        }
      }
    }

    return false;
  }

  static DateTime getLastMondayDate(String date) {
    DateTime tempDate = DateTime.parse(date);

    DateTime ret =
        tempDate.subtract(Duration(days: (tempDate.weekday - 1) + 7));

    return ret;
  }
}
