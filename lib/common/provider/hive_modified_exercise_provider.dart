import 'package:fitend_member/common/const/data.dart';
import 'package:fitend_member/exercise/model/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveModifiedExerciseProvider = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<Exercise>(modifiedExercise);

    Box box = Hive.box<Exercise>(modifiedExercise);

    return box;
  },
);
