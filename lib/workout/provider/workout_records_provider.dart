import 'package:fitend_member/workout/repository/workout_records_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRecordsProvider = StateNotifierProvider((ref) {
  final workoutRecordsRepository = ref.watch(workoutRecordsRepositoryProvider);

  return WorkoutRecordStateNotifier(repository: workoutRecordsRepository);
});

class WorkoutRecordStateNotifier extends StateNotifier {
  final WorkoutRecordsRepository repository;

  WorkoutRecordStateNotifier({
    required this.repository,
  }) : super(null);
}
