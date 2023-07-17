import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/schedule/model/reservation_schedule_model.dart';
import 'package:fitend_member/schedule/model/workout_schedule_pagenate_params.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'reservation_schedule_repository.g.dart';

final workoutScheduleRepositoryProvider =
    Provider<ReservationScheduleRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ReservationScheduleRepository(dio);
});

@RestApi()
abstract class ReservationScheduleRepository {
  factory ReservationScheduleRepository(Dio dio) =
      _ReservationScheduleRepository;

  @GET('/reservations')
  @Headers({
    'accessToken': 'true',
  })
  Future<ReservationScheduleModel> getReservationSchedule({
    @Queries() required SchedulePagenateParams params,
  });
}
