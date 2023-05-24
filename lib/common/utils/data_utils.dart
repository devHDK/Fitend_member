import 'dart:convert';

import 'package:fitend_member/common/const/data.dart';

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
}
