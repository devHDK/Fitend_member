import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/thread/model/common/create_resp_model.dart';
import 'package:fitend_member/thread/model/threads/thread_create_model.dart';
import 'package:fitend_member/thread/model/threads/thread_get_list_params_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'thread_repository.g.dart';

final threadRepositoryProvider = Provider<ThreadRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ThreadRepository(dio);
});

@RestApi()
abstract class ThreadRepository {
  factory ThreadRepository(Dio dio) = _ThreadRepository;

  @POST('/threads')
  @Headers({
    'accessToken': 'true',
  })
  Future<CreateRespModel> postThread({
    @Body() required ThreadCreateModel model,
  });

  @POST('/threads/welcome/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<CreateRespModel> postWelcomeThread({
    @Path('id') required int id,
  });

  @GET('/threads')
  @Headers({
    'accessToken': 'true',
  })
  Future<ThreadListModel> getThreads({
    @Queries() required ThreadGetListParamsModel params,
  });

  @GET('/threads/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<ThreadModel> getThreadWithId({
    @Path('id') required int id,
  });

  @PUT('/threads/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putThreadWithId({
    @Path('id') required int id,
    @Body() required ThreadCreateModel model,
  });

  @DELETE('/threads/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deleteThreadWithId({
    @Path('id') required int id,
  });
}
