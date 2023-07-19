import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/notifications/component/notification_cell.dart';
import 'package:fitend_member/notifications/model/notification_model.dart';
import 'package:fitend_member/notifications/provider/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  static String get routeName => 'notification';

  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  final ScrollController controller = ScrollController();
  late NotificationModel notification;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    final provider = ref.read(notificationProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (controller.offset > controller.position.maxScrollExtent - 100 &&
          notification.data.length < notification.total) {
        //스크롤을 아래로 내렸을때
        provider.paginate(start: notification.data.length, fetchMore: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    if (state is NotificationModelLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: POINT_COLOR,
        ),
      );
    }

    if (state is NotificationModelError) {
      showDialog(
        context: context,
        builder: (context) => DialogWidgets.errorDialog(
          message: '데이터를 불러올수 없습니다.',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    notification = state as NotificationModel;

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: BACKGROUND_COLOR,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        title: Text(
          '알림',
          style: h4Headline.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ListView.builder(
          controller: controller,
          itemBuilder: (context, index) {
            return NotificationCell(notificationData: state.data[index]);
          },
          itemCount: state.data.length,
        ),
      ),
    );
  }
}
