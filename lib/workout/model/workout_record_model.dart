import 'package:fitend_member/exercise/model/setInfo_model.dart';
import 'package:hive/hive.dart';

part 'workout_record_model.g.dart';

@HiveType(typeId: 1)
class WorkoutRecordModel {
  @HiveField(1)
  final int workoutPlanId;
  @HiveField(2)
  final List<SetInfo> setInfo;

  WorkoutRecordModel({
    required this.workoutPlanId,
    required this.setInfo,
  });

  WorkoutRecordModel copyWith({
    int? workoutPlanId,
    List<SetInfo>? setInfo,
  }) =>
      WorkoutRecordModel(
        workoutPlanId: workoutPlanId ?? this.workoutPlanId,
        setInfo: setInfo ?? this.setInfo,
      );
}
