import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:pub_semver/pub_semver.dart';

/// 안드로이드 버전을 가져옵니다
///
/// 구글은 API를 제공하지 않습니다
Future<Version> _fetchAndroidVersion() async {
  const String bundle = 'com.raid.fitend';
  const String url = 'https://play.google.com/store/apps/details?id=$bundle';
  final dio = Dio();
  Response response = await dio.get(url);
  final regexp = RegExp(r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]');
  final storeVersion = regexp.firstMatch(response.data)?.group(1);

  if (storeVersion == null) {
    throw 'Result Not Found';
  }
  return Version.parse(storeVersion);
}

Future<Version> _fetchiOSVersion() async {
  const String bundle = "com.raid.fitend";
  const String url =
      'https://itunes.apple.com/lookup?bundleId=$bundle&country=kr';
  final dio = Dio();
  final Options options = Options(
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  Response response = await dio.get(url, options: options);

  Map<String, dynamic> result = jsonDecode(response.data);

  String version = '';

  if (result['resultCount'] > 0 &&
      result['results'] != null &&
      result['results'].length > 0) {
    version = result['results'][0]['version'] ?? '';
  } else {
    throw 'Result Not Found';
  }

  return Version.parse(version);
}

/// 업데이트해야하는 버전을 사용하고 있는지 체크합니다
///
/// [true]인 경우 스토어 버전과 다르므로 업데이트 해야합니다
/// 스토어 버전이 항상 최신 버전일 것을 가정하여 [Version.allows]를 이용합니다
Future<Map<String, dynamic>> checkUpdatable(String version) async {
  Version currentVersion = Version.parse(version);
  late Version storeVersion;

  if (Platform.isAndroid) {
    storeVersion = await _fetchAndroidVersion();
  } else if (Platform.isIOS) {
    storeVersion = await _fetchiOSVersion();
  }

  // storeVersion이 Null이면 throw
  if (storeVersion.isEmpty) {
    throw 'Fetch store version failed';
  }
  Map<String, dynamic> result = {
    'needUpdate': false,
    'storeVersion': storeVersion,
  };

  if (currentVersion.major > storeVersion.major) {
    return result;
  }

  if (currentVersion.minor > storeVersion.minor) {
    return result;
  }

  if (currentVersion.patch > storeVersion.patch) {
    return result;
  }
  // 완전히 같은 버전
  if (currentVersion.allows(storeVersion)) {
    return result;
  }

  result['needUpdate'] = true;

  return result;
}
