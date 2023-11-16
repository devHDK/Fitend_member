import 'dart:convert';

import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/provider/shared_preference_provider.dart';
import 'package:fitend_member/common/utils/shared_pref_utils.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/thread/model/emojis/emoji_model.dart';
import 'package:fitend_member/thread/model/threads/thread_list_model.dart';
import 'package:fitend_member/thread/model/threads/thread_model.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThreadUpdateUtils {
  static Future<void> checkThreadNeedUpdate(WidgetRef ref) async {
    final pref = await ref.read(sharedPrefsProvider);
    final isNeedListUpdate =
        SharedPrefUtils.getIsNeedUpdate(StringConstants.needThreadUpdate, pref);
    var threadUpdateList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needThreadUpdateList, pref);
    var threadDeleteList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needThreadDelete, pref);
    var commentCreateList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needCommentCreate, pref);
    var commentDeleteList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needCommentDelete, pref);
    var emojiCreateList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needEmojiCreate, pref);
    var emojiDeleteList = SharedPrefUtils.getNeedUpdateList(
        StringConstants.needEmojiDelete, pref);

    bool isListRefreshed = false;
    List<String> detailRefreshedList = [];

    if (isNeedListUpdate) {
      ref
          .read(threadProvider.notifier)
          .paginate(startIndex: 0, isRefetch: true);

      ref.read(notificationHomeProvider.notifier).addBageCount(1);
      ref.read(notificationHomeProvider.notifier).updateIsConfirm(false);

      await SharedPrefUtils.updateIsNeedUpdate(
          StringConstants.needThreadUpdate, pref, false);
      await SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needThreadDelete, pref, []);
      threadDeleteList = [];
      isListRefreshed = true;

      debugPrint('[debug] Thread List updated');
    }

    if (threadUpdateList.isNotEmpty) {
      for (var e in threadUpdateList) {
        final tempState = ref.read(threadProvider);

        debugPrint('[debug] Thread List updated');

        final model = tempState as ThreadListModel;
        final index = model.data.indexWhere((thread) {
          return thread.id == int.parse(e);
        });

        if (index != -1) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(e);

          debugPrint('[debug] Thread Detail updated! threadId: $e');
        }
      }
      await SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needThreadUpdateList, pref, []);
    }

    if (threadDeleteList.isNotEmpty && !isListRefreshed) {
      for (var e in threadDeleteList) {
        final tempState = ref.read(threadProvider);

        final model = tempState as ThreadListModel;
        final index = model.data.indexWhere((thread) {
          return thread.id == int.parse(e);
        });

        if (index != -1) {
          ref
              .read(threadProvider.notifier)
              .removeThreadWithId(int.parse(e), index);

          debugPrint('[debug] Thread Deleted! threadId: $e');
        }
      }
    }

    if (commentCreateList.isNotEmpty) {
      for (var e in commentCreateList) {
        if (ref.read(threadDetailProvider(int.parse(e))) is ThreadModel &&
            !detailRefreshedList.contains(e)) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(e);

          debugPrint('[debug] Thread Detail updated! threadId: $e');
        }

        ref.read(notificationHomeProvider.notifier).addBageCount(1);
        ref.read(notificationHomeProvider.notifier).updateIsConfirm(false);

        var tempState = ref.read(threadProvider);
        var model = tempState as ThreadListModel;

        int index =
            model.data.indexWhere((thread) => thread.id == int.parse(e));

        if (index != -1 && !isListRefreshed) {
          ref
              .read(threadProvider.notifier)
              .updateTrainerCommentCount(int.parse(e), 1);
        }
      }
      await SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needCommentCreate, pref, []);
      commentCreateList = [];
    }

    if (commentDeleteList.isNotEmpty) {
      for (var e in commentDeleteList) {
        if (ref.read(threadDetailProvider(int.parse(e))) is ThreadModel &&
            !detailRefreshedList.contains(e)) {
          ref
              .read(threadDetailProvider(int.parse(e)).notifier)
              .getThreadDetail(threadId: int.parse(e));

          detailRefreshedList.add(e);

          debugPrint('[debug] Thread Detail updated! threadId: $e');
        }

        var tempState = ref.read(threadProvider);
        var model = tempState as ThreadListModel;

        int index =
            model.data.indexWhere((thread) => thread.id == int.parse(e));

        if (index != -1 && !isListRefreshed) {
          ref
              .read(threadProvider.notifier)
              .updateTrainerCommentCount(int.parse(e), -1);
        }
      }
    }

    if (emojiCreateList.isNotEmpty) {
      var tempList = emojiCreateList;

      if (ref.read(threadProvider) is! ThreadListModel) {
        tempList = [];
        await SharedPrefUtils.updateNeedUpdateList(
            StringConstants.needEmojiCreate, pref, []);
      }

      for (var emoji in tempList) {
        Map<String, dynamic> emojiMap = jsonDecode(emoji);
        var emojiModel = EmojiModelFromPushData.fromJson(emojiMap);

        if (emojiModel.commentId == null) {
          //thread에 추가
          if (!isListRefreshed) {
            final tempState = ref.read(threadProvider) as ThreadListModel;
            int index = tempState.data.indexWhere(
                (element) => element.id == int.parse(emojiModel.threadId!));

            ref.read(threadProvider.notifier).addEmoji(
                null,
                int.parse(emojiModel.trainerId!),
                emojiModel.emoji,
                index,
                int.parse(emojiModel.id));
          }

          if (!detailRefreshedList.contains(emojiModel.threadId!)) {
            ref
                .read(threadDetailProvider(int.parse(emojiModel.threadId!))
                    .notifier)
                .addThreadEmoji(null, int.parse(emojiModel.trainerId!),
                    emojiModel.emoji, int.parse(emojiModel.id));
          }

          debugPrint(
              '[debug] Add Thread Emoji! threadId: ${emojiModel.threadId}');
        } else if (emojiModel.commentId != null &&
            !detailRefreshedList.contains(emojiModel.threadId)) {
          ThreadModel? tempState;
          if (ref.read(threadDetailProvider(int.parse(emojiModel.threadId!)))
              is ThreadModel) {
            tempState =
                ref.read(threadDetailProvider(int.parse(emojiModel.threadId!)))
                    as ThreadModel;
          }

          if (tempState != null &&
              tempState.comments != null &&
              tempState.comments!.isNotEmpty) {
            final index = tempState.comments!.indexWhere(
                (element) => element.id == int.parse(emojiModel.commentId!));

            if (index != -1) {
              ref
                  .read(threadDetailProvider(int.parse(emojiModel.threadId!))
                      .notifier)
                  .addCommentEmoji(null, int.parse(emojiModel.trainerId!),
                      emojiModel.emoji, index, int.parse(emojiModel.id));
            }
          }
          debugPrint(
              '[debug] Add comment Emoji! threadId: ${emojiModel.threadId}');
        }

        // emojiCreateList.remove(emoji);
      }

      await SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needEmojiCreate, pref, []);
    }

    if (emojiDeleteList.isNotEmpty) {
      var tempList = emojiDeleteList;

      if (ref.read(threadProvider) is! ThreadListModel) {
        tempList = [];
        await SharedPrefUtils.updateNeedUpdateList(
            StringConstants.needEmojiDelete, pref, []);
      }

      for (var emoji in tempList) {
        Map<String, dynamic> emojiMap = jsonDecode(emoji);
        var emojiModel = EmojiModelFromPushData.fromJson(emojiMap);

        if (emojiModel.commentId == null) {
          //thread에서 삭제
          if (!isListRefreshed) {
            final tempState = ref.read(threadProvider) as ThreadListModel;
            int index = tempState.data.indexWhere(
                (element) => element.id == int.parse(emojiModel.threadId!));

            ref.read(threadProvider.notifier).removeEmoji(
                  null,
                  int.parse(emojiModel.trainerId!),
                  emojiModel.emoji,
                  index,
                  int.parse(emojiModel.id),
                );
          }

          if (!detailRefreshedList.contains(emojiModel.threadId!)) {
            ref
                .read(threadDetailProvider(int.parse(emojiModel.threadId!))
                    .notifier)
                .removeThreadEmoji(null, int.parse(emojiModel.trainerId!),
                    emojiModel.emoji, int.parse(emojiModel.id));
          }

          debugPrint(
              '[debug] Delete Thread Emoji! threadId: ${emojiModel.threadId}');
        } else if (emojiModel.commentId != null &&
            !detailRefreshedList.contains(emojiModel.threadId)) {
          ThreadModel? tempState;
          if (ref.read(threadDetailProvider(int.parse(emojiModel.threadId!)))
              is ThreadModel) {
            tempState =
                ref.read(threadDetailProvider(int.parse(emojiModel.threadId!)))
                    as ThreadModel;
          }

          if (tempState != null &&
              tempState.comments != null &&
              tempState.comments!.isNotEmpty) {
            final index = tempState.comments!.indexWhere(
                (element) => element.id == int.parse(emojiModel.commentId!));

            if (index != -1) {
              ref
                  .read(threadDetailProvider(int.parse(emojiModel.threadId!))
                      .notifier)
                  .removeCommentEmoji(null, int.parse(emojiModel.trainerId!),
                      emojiModel.emoji, index, int.parse(emojiModel.id));
            }
          }
          debugPrint(
              '[debug] Delete Comment Emoji! threadId: ${emojiModel.threadId}');
        }

        // emojiDeleteList.remove(emoji);
      }

      await SharedPrefUtils.updateNeedUpdateList(
          StringConstants.needEmojiDelete, pref, []);
    }
  }
}
