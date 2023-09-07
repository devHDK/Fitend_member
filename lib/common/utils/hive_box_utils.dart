import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BoxUtils {
  static void deleteBox(AsyncValue<Box> box, List<Exercise> exercises) {
    box.whenData(
      (value) {
        for (var element in exercises) {
          value.delete(element.workoutPlanId);
        }
      },
    );
  }

  static void deleteTimerBox(AsyncValue<Box> box, List<Exercise> exercises) {
    box.whenData(
      (value) {
        for (var element in exercises) {
          if ((element.trackingFieldId == 3 || element.trackingFieldId == 4)) {
            value.delete(element.workoutPlanId);
          }
        }
      },
    );
  }
}
