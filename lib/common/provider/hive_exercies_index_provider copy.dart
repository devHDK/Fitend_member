import 'package:fitend_member/common/const/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveExerciseIndexProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<int>(processingExerciseIndex);

    Box box = Hive.box<int>(processingExerciseIndex);

    return box;
  },
);
