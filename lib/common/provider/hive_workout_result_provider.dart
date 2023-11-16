import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/workout/model/workout_result_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveWorkoutRecordForResultProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<WorkoutRecord>(StringConstants.workoutResult);

    Box box = Hive.box<WorkoutRecord>(StringConstants.workoutResult);

    return box;
  },
);
