import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveWorkoutRecordSimpleProvider = FutureProvider<Box>((ref) async {
  await Hive.openBox<WorkoutRecordSimple>(workoutRecordSimple);

  Box box = Hive.box<WorkoutRecordSimple>(workoutRecordSimple);

  return box;
});
