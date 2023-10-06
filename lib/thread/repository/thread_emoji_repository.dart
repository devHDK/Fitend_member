import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/thread/model/emoji_params_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'thread_emoji_repository.g.dart';

final emojiRepositoryProvider = Provider<emojiRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return emojiRepository(dio);
});

@RestApi()
abstract class emojiRepository {
  factory emojiRepository(Dio dio) = _emojiRepository;

  @PUT('/emojis')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putEmoji({
    @Body() required PutEmojiParamsModel model,
  });
}
