import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/thread/model/file_upload_request_model.dart';
import 'package:fitend_member/thread/model/file_upload_response_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'file_repository.g.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return FileRepository(dio);
});

@RestApi()
abstract class FileRepository {
  factory FileRepository(Dio dio) = _FileRepository;

  @GET('/files/upload')
  @Headers({
    'accessToken': 'true',
  })
  Future<FileResponseModel> getFileUpload(
      {@Queries() required FileRequestModel model});
}
