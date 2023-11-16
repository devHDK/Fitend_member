import 'package:fitend_member/common/const/data_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveExerciseIndexProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<int>(StringConstants.processingExerciseIndex);

    Box box = Hive.box<int>(StringConstants.processingExerciseIndex);

    return box;
  },
);
