import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/workout/model/workout_record_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveWorkoutRecordProvider = FutureProvider<Box>((ref) async {
  await Hive.openBox<WorkoutRecordModel>(workoutRecordBox);

  Box box = Hive.box<WorkoutRecordModel>(workoutRecordBox);

  return box;
});
