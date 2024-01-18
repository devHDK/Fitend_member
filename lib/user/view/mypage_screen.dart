import 'package:dio/dio.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/aseet_constants.dart';
import 'package:fitend_member/common/const/data_constants.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/notifications/model/notification_setting_model.dart';
import 'package:fitend_member/notifications/provider/notification_home_screen_provider.dart';
import 'package:fitend_member/notifications/provider/notification_provider.dart';
import 'package:fitend_member/notifications/repository/notifications_repository.dart';
import 'package:fitend_member/schedule/provider/schedule_provider.dart';
import 'package:fitend_member/thread/provider/comment_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_create_provider.dart';
import 'package:fitend_member/thread/provider/thread_detail_provider.dart';
import 'package:fitend_member/thread/provider/thread_provider.dart';
import 'package:fitend_member/ticket/component/no_ticket_cell.dart';
import 'package:fitend_member/ticket/component/ticket_cell.dart';
import 'package:fitend_member/ticket/provider/ticket_provider.dart';
import 'package:fitend_member/ticket/view/active_ticket_screen.dart';
import 'package:fitend_member/ticket/view/ticket_screen.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/password_confirm_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  static String get routeName => 'mypage';
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  PackageInfo? packageInfo;
  String? version;

  @override
  void initState() {
    super.initState();
    getPackage();
  }

  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        version = packageInfo!.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);

    if (state is UserModelLoading) {
      return const Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
            child: CircularProgressIndicator(
          color: Pallete.point,
        )),
      );
    }

    if (state is UserModelError) {
      return Scaffold(
        backgroundColor: Pallete.background,
        body: Center(
          child: DialogWidgets.oneButtonDialog(
            message: '데이터를 불러올수없습니다😂',
            confirmText: '확인',
            confirmOnTap: () => context.pop(),
          ),
        ),
      );
    }

    final model = state as UserModel;

    String formattedPhoneNumber = model.user.phone != null
        ? model.user.phone!.replaceAllMapped(RegExp(r'(\d{3})(\d{3,4})(\d{4})'),
            (m) => '${m[1]}-${m[2]}-${m[3]}')
        : '';

    // int ticketLength = 0;

    if (model.user.activeTickets != null &&
        model.user.activeTickets!.isNotEmpty) {
      // ActiveTicket nowTicket = model.user.activeTickets!.first;

      // final diff = nowTicket.expiredAt.difference(nowTicket.startedAt).inDays;
      // if (diff > 92) {
      //   ticketLength = 6;
      // } else if (diff > 31) {
      //   ticketLength = 3;
      // } else {
      //   ticketLength = 1;
      // }
    }

    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        elevation: 0,
        title: Text(
          '마이페이지',
          style: h4Headline,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context); //뒤로가기
          },
          icon: const Padding(
            padding: EdgeInsets.only(left: 18),
            child: Icon(Icons.arrow_back_sharp),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            _renderUserInfo(model, formattedPhoneNumber),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ActiveTicketScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: model.user.activeTickets != null &&
                        model.user.activeTickets!.isNotEmpty
                    ? TicketCell(
                        ticket: model.user.activeTickets!.first,
                        child: SvgPicture.asset(SVGConstants.next),
                      )
                    : NoTicketCell(
                        title: '멤버십을 구매하여',
                        content: '맞춤형 운동플랜과 코칭을 받아보세요!',
                        child: SvgPicture.asset(SVGConstants.next),
                      ),
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const TicketScreen(),
                  ),
                );
              },
              child: _renderLabel(
                name: '멤버쉽 결제 내역',
                child: SvgPicture.asset(SVGConstants.next),
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const PasswordConfirmScreen(),
                  ),
                );
              },
              child: _renderLabel(
                name: '비밀번호 변경',
                child: SvgPicture.asset(SVGConstants.next),
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            _renderLabel(
                name: '알림 설정',
                child: SizedBox(
                  width: 42,
                  height: 24,
                  child: Transform.scale(
                    scale: 0.7,
                    child: CupertinoSwitch(
                      activeColor: Pallete.point,
                      trackColor: Pallete.gray,
                      value: state.user.isNotification!,
                      onChanged: (value) async {
                        try {
                          ref.read(getMeProvider.notifier).changeIsNotification(
                              isNotification: !state.user.isNotification!);

                          await ref
                              .read(notificationRepositoryProvider)
                              .putNotificationsSetting(
                                  body: NotificationSettingParams(
                                      isNotification:
                                          !state.user.isNotification!));
                        } on DioException catch (e) {
                          debugPrint('$e');
                          ref.read(getMeProvider.notifier).changeIsNotification(
                              isNotification: !state.user.isNotification!);
                        }
                      },
                    ),
                  ),
                )),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () =>
                  DataUtils.onWebViewTap(uri: URLConstants.notionServiceUser),
              child: _renderLabel(
                name: '서비스 이용약관',
                child: SvgPicture.asset(SVGConstants.next),
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () =>
                  DataUtils.onWebViewTap(uri: URLConstants.notionPrivacy),
              child: _renderLabel(
                name: '개인정보 처리방침',
                child: SvgPicture.asset(SVGConstants.next),
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            _renderLabel(
                name: '현재 버전',
                child: Text(
                  packageInfo != null ? 'v${packageInfo!.version}' : '',
                  style: s3SubTitle.copyWith(
                    color: Pallete.point,
                  ),
                )),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => DialogWidgets.confirmDialog(
                    message: '로그아웃 하시겠습니까?',
                    confirmText: '확인',
                    cancelText: '취소',
                    confirmOnTap: () async {
                      await ref.read(getMeProvider.notifier).logout();

                      ref.invalidate(threadProvider);
                      ref.invalidate(threadDetailProvider);

                      ref.invalidate(scheduleProvider);

                      ref.invalidate(threadCreateProvider);
                      ref.invalidate(commentCreateProvider);

                      ref.invalidate(notificationProvider);
                      ref.invalidate(notificationHomeProvider);

                      ref.invalidate(ticketProvider);
                    },
                    cancelOnTap: () => context.pop(),
                  ),
                );
              },
              child: _renderLabel(
                name: '로그아웃',
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
            InkWell(
              onTap: () async {
                var tempDir = await getTemporaryDirectory();

                if (tempDir.existsSync()) {
                  tempDir.deleteSync(recursive: true);
                  DialogWidgets.showToast(content: '캐시가 삭제되었습니다!');
                }
              },
              child: _renderLabel(
                name: '캐시 비우기',
              ),
            ),
            const Divider(
              color: Pallete.darkGray,
              height: 1,
            ),
          ],
        ),
      ),
    );
  }

  Padding _renderUserInfo(UserModel model, String formattedPhoneNumber) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                model.user.nickname,
                style: h1Headline.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                '회원님',
                style: s2SubTitle.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(SVGConstants.email),
              const SizedBox(
                width: 8,
              ),
              Text(
                model.user.email,
                style: s2SubTitle.copyWith(
                  color: Pallete.lightGray,
                  height: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(SVGConstants.phone),
              const SizedBox(
                width: 8,
              ),
              Text(
                formattedPhoneNumber,
                style: s2SubTitle.copyWith(
                  color: Pallete.lightGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Padding _renderLabel({required String name, Widget? child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: s1SubTitle.copyWith(
              color: Colors.white,
            ),
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}
