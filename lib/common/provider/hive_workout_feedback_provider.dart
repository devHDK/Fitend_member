import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/schedule/model/workout_feedback_record_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveWorkoutFeedbackProvider = FutureProvider<Box>((ref) async {
  await Hive.openBox<WorkoutFeedbackRecordModel>(
      StringConstants.workoutFeedback);

  Box box =
      Hive.box<WorkoutFeedbackRecordModel>(StringConstants.workoutFeedback);

  return box;
});
