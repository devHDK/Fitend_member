import 'package:fitend_member/common/const/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtils {
  static bool getIsNeedUpdateSchedule(SharedPreferences pref) {
    final bool? isNeedUpdateSchedule = pref.getBool(needScheduleUpdate);

    if (isNeedUpdateSchedule == null) return false;

    return isNeedUpdateSchedule;
  }

  static bool getIsNeedUpdateNotification(SharedPreferences pref) {
    final bool? isNeedUpdateNoti = pref.getBool(needNotificationUpdate);

    if (isNeedUpdateNoti == null) return false;

    return isNeedUpdateNoti;
  }

  static List<String> getNeedUpdateWorkoutList(SharedPreferences pref) {
    final updateWorkoutList = pref.getStringList(needWorkoutUpdateList);

    if (updateWorkoutList == null) return [];

    return updateWorkoutList.toSet().toList();
  }

  static Future<void> updateIsNeedUpdateSchedule(
      SharedPreferences pref, bool isNeedUpdate) async {
    await pref.setBool(needScheduleUpdate, isNeedUpdate);
  }

  static Future<void> updateIsNeedUpdateNotification(
      SharedPreferences pref, bool isNeedUpdate) async {
    await pref.setBool(needNotificationUpdate, isNeedUpdate);
  }

  static Future<void> addOneNeedUpdateWorkoutList(
      SharedPreferences pref, String workoutScheduleId) async {
    final pList = getNeedUpdateWorkoutList(pref);

    pList.add(workoutScheduleId);

    await pref.setStringList(needWorkoutUpdateList, pList);
  }

  static Future<void> updateNeedUpdateWorkoutList(
      SharedPreferences pref, List<String> updateList) async {
    await pref.setStringList(needWorkoutUpdateList, updateList);
  }
}
