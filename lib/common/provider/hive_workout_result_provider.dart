import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveWorkoutResultProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<WorkoutRecordResult>(workoutResult);

    Box box = Hive.box<WorkoutRecordResult>(workoutResult);

    return box;
  },
);
