import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/workout/model/schedule_record_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final hiveScheduleRecordBox = FutureProvider<Box>(
  (ref) async {
    await Hive.openBox<ScheduleRecordsModel>(StringConstants.scheduleRecord);

    Box box = Hive.box<ScheduleRecordsModel>(StringConstants.scheduleRecord);

    return box;
  },
);
