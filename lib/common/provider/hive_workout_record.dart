import 'package:fitend_member/common/const/data_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveProcessTotalTimeBox = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<int>(StringConstants.timerTotalTimeRecord);

    Box box = Hive.box<int>(StringConstants.timerTotalTimeRecord);

    return box;
  },
);
