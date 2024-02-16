import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/meeting/model/meeting_date_model.dart';
import 'package:fitend_member/trainer/model/get_extend_trainers_model.dart';
import 'package:fitend_member/trainer/model/get_trainer_schedule_model.dart';
import 'package:fitend_member/trainer/model/trainer_detail_model.dart';
import 'package:fitend_member/trainer/model/trainer_list_extend.dart';
import 'package:fitend_member/trainer/model/trainer_list_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'trainer_repository.g.dart';

final trainerRepositoryProvider = Provider<TrainerRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return TrainerRepository(dio);
});

@RestApi()
abstract class TrainerRepository {
  factory TrainerRepository(Dio dio) = _TrainerRepository;

  @GET('/trainers')
  Future<TrainerListModel> getTrainers();

  @GET('/trainers/extend')
  Future<TrainerListExtend> getTrainersExtend(
    @Queries() GetExtendTrainersModel model,
  );

  @GET('/trainers/{id}')
  Future<TrainerDetailModel> getTrainerDetail({
    @Path('id') required int id,
  });

  @GET('/trainers/{id}/schedules')
  @Headers({
    'accessToken': 'true',
  })
  Future<MeetingDateModel> getTrainerSchedules({
    @Path('id') required int id,
    @Queries() required GetTrainerScheduleModel model,
  });
}
