import 'package:fitend_member/common/const/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtils {
  static bool getIsNeedUpdate(String value, SharedPreferences pref) {
    final bool? isNeedUpdate = pref.getBool(value);

    if (isNeedUpdate == null) return false;

    return isNeedUpdate;
  }

  static List<String> getNeedUpdateList(String value, SharedPreferences pref) {
    final updateList = pref.getStringList(value);

    if (updateList == null) return [];

    return updateList.toSet().toList();
  }

  static Future<void> updateIsNeedUpdate(
      String value, SharedPreferences pref, bool isNeedUpdate) async {
    await pref.setBool(value, isNeedUpdate);
  }

  static Future<void> addOneNeedUpdateList(
      String value, SharedPreferences pref, String updateValue) async {
    final pList = getNeedUpdateList(value, pref);

    pList.add(updateValue);

    await pref.setStringList(needWorkoutUpdateList, pList);
  }

  static Future<void> updateNeedUpdateList(
      String value, SharedPreferences pref, List<String> updateList) async {
    await pref.setStringList(value, updateList);
  }

  static Future<void> updateThreadBadgeCount(
      SharedPreferences pref, String type) async {
    switch (type) {
      case 'add':
        int? count = pref.getInt(threadBadgeCount);

        count ??= 0;
        await pref.setInt(threadBadgeCount, count + 1);
        break;

      case 'reset':
        await pref.setInt(threadBadgeCount, 0);
        break;

      default:
    }
  }

  static int getThreadBadgeCount(
    SharedPreferences pref,
  ) {
    int? count = pref.getInt(threadBadgeCount);
    count ??= 0;

    return count;
  }

  static bool getHasNewNotification(SharedPreferences pref) {
    final bool? newNotification = pref.getBool(hasNewNotification);

    if (newNotification == null) return false;

    return newNotification;
  }

  static Future<void> updateHasNewNotification(
      SharedPreferences pref, bool newNotification) async {
    await pref.setBool(hasNewNotification, newNotification);
  }
}
