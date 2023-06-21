import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/password_confirm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    setState(() {
      version = packageInfo!.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);

    if (state is UserModelLoading) {
      return const Scaffold(
        backgroundColor: BACKGROUND_COLOR,
        body: Center(
            child: CircularProgressIndicator(
          color: POINT_COLOR,
        )),
      );
    }

    if (state is UserModelError) {
      showDialog(
        context: context,
        builder: (context) => DialogWidgets.errorDialog(
          message: '데이터를 불러올수없습니다😂',
          confirmText: '확인',
          confirmOnTap: () => context.pop(),
        ),
      );
    }

    final model = state as UserModel;

    String formattedPhoneNumber = model.user.phone != null
        ? model.user.phone!.replaceAllMapped(RegExp(r'(\d{3})(\d{3,4})(\d{4})'),
            (m) => '${m[1]}-${m[2]}-${m[3]}')
        : '';

    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      appBar: AppBar(
        backgroundColor: BACKGROUND_COLOR,
        elevation: 0,
        title: const Text(
          '마이페이지',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
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
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const PasswordConfirmScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            SlideTransition(
                      position: animation.drive(
                        Tween(
                          begin: const Offset(1.0, 0),
                          end: Offset.zero,
                        ).chain(
                          CurveTween(curve: Curves.linearToEaseOut),
                        ),
                      ),
                      child: child,
                    ),
                  ),
                );
              },
              child: _renderLabel(
                name: '비밀번호 변경',
                child: Image.asset(
                  'asset/img/icon_next.png',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            InkWell(
              onTap: () =>
                  DataUtils.onWebViewTap(uri: "https://www.google.com"),
              child: _renderLabel(
                name: '서비스 이용 약관',
                child: Image.asset(
                  'asset/img/icon_next.png',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            InkWell(
              onTap: () =>
                  DataUtils.onWebViewTap(uri: "https://www.google.com"),
              child: _renderLabel(
                name: '개인정보 처리방침',
                child: Image.asset(
                  'asset/img/icon_next.png',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            _renderLabel(
                name: '현재버전',
                child: Text(
                  packageInfo != null ? 'v${packageInfo!.version}' : '',
                  style: const TextStyle(color: POINT_COLOR, fontSize: 12),
                )),
            const Divider(
              color: DARK_GRAY_COLOR,
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
                    confirmOnTap: () {
                      ref.read(getMeProvider.notifier).logout();
                    },
                    cancelOnTap: () => context.pop(),
                  ),
                );
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 40,
                child: _renderLabel(
                  name: '로그아웃',
                ),
              ),
            )
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
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              const Text(
                '회원님',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.mail_outline,
                size: 20,
                color: LIGHT_GRAY_COLOR,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                model.user.email,
                style: const TextStyle(
                  color: LIGHT_GRAY_COLOR,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset('asset/img/icon_phone.png'),
              const SizedBox(
                width: 8,
              ),
              Text(
                formattedPhoneNumber,
                style: const TextStyle(
                  color: LIGHT_GRAY_COLOR,
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
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
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          if (child != null) child,
        ],
      ),
    );
  }
}
