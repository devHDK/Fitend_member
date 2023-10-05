import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/thread/model/thread_comment_create_model.dart';
import 'package:fitend_member/thread/model/thread_comment_get_params_model.dart';
import 'package:fitend_member/thread/model/thread_list_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'thread_comment_repository.g.dart';

final reservaionScheduleRepositoryProvider =
    Provider<ThreadCommentRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return ThreadCommentRepository(dio);
});

@RestApi()
abstract class ThreadCommentRepository {
  factory ThreadCommentRepository(Dio dio) = _ThreadCommentRepository;

  @POST('/comments')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> postComment({
    @Body() required ThreadCommentCreateModel model,
  });

  @GET('/comments')
  @Headers({
    'accessToken': 'true',
  })
  Future<ThreadListModel> getComments({
    @Queries() required CommentGetListParamsModel model,
  });

  @PUT('/comments/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putCommentWithId({
    @Path('id') required int id,
    @Body() required ThreadCommentCreateModel model,
  });

  @DELETE('/comments/{id}')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> deleteCommentWithId({
    @Path('id') required int id,
  });
}
