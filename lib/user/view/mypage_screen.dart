import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/const/text_style.dart';
import 'package:fitend_member/common/utils/data_utils.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:fitend_member/user/view/password_confirm_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
              color: DARK_GRAY_COLOR,
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
                child: SvgPicture.asset(
                  'asset/img/icon_next.svg',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            InkWell(
              onTap: () => DataUtils.onWebViewTap(
                  uri:
                      "https://weareraid.notion.site/87468f88c99b427b81ae3e44aeb1f37b?pvs=4"),
              child: _renderLabel(
                name: '서비스 이용 약관',
                child: SvgPicture.asset(
                  'asset/img/icon_next.svg',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            InkWell(
              onTap: () => DataUtils.onWebViewTap(
                  uri:
                      "https://weareraid.notion.site/06b383e3c7aa4515a4637c2c11f3d908?pvs=4"),
              child: _renderLabel(
                name: '개인정보 처리방침',
                child: SvgPicture.asset(
                  'asset/img/icon_next.svg',
                ),
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            _renderLabel(
                name: '현재 버전',
                child: Text(
                  packageInfo != null ? 'v${packageInfo!.version}' : '',
                  style: s3SubTitle.copyWith(
                    color: POINT_COLOR,
                  ),
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
              child: _renderLabel(
                name: '로그아웃',
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
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
              SvgPicture.asset('asset/img/icon_email.svg'),
              const SizedBox(
                width: 8,
              ),
              Text(
                model.user.email,
                style: s2SubTitle.copyWith(
                  color: LIGHT_GRAY_COLOR,
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
              SvgPicture.asset('asset/img/icon_phone.svg'),
              const SizedBox(
                width: 8,
              ),
              Text(
                formattedPhoneNumber,
                style: s2SubTitle.copyWith(
                  color: LIGHT_GRAY_COLOR,
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
