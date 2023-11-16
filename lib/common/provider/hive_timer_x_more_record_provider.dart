import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/workout/model/workout_record_simple_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveTimerXMoreRecordProvider = FutureProvider<Box>((ref) async {
  // final appDocumentDirectory = await getApplicationDocumentsDirectory();
  // await Hive.initFlutter(appDocumentDirectory.path);

  await Hive.openBox<WorkoutRecordSimple>(StringConstants.timerXMoreRecord);
  Box box = Hive.box<WorkoutRecordSimple>(StringConstants.timerXMoreRecord);

  return box;
});
