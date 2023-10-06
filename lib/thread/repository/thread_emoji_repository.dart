import 'package:dio/dio.dart' hide Headers;
import 'package:fitend_member/common/dio/dio.dart';
import 'package:fitend_member/thread/model/emojis/emoji_params_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';

part 'thread_emoji_repository.g.dart';

final emojiRepositoryProvider = Provider<EmojiRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return EmojiRepository(dio);
});

@RestApi()
abstract class EmojiRepository {
  factory EmojiRepository(Dio dio) = _EmojiRepository;

  @PUT('/emojis')
  @Headers({
    'accessToken': 'true',
  })
  Future<void> putEmoji({
    @Body() required PutEmojiParamsModel model,
  });
}
