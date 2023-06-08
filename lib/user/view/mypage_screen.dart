import 'package:fitend_member/common/const/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    version = packageInfo!.version;
  }

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.only(left: 28),
            child: Icon(Icons.arrow_back_sharp),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 20),
              child: Column(
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Alex',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
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
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 20,
                        color: LIGHT_GRAY_COLOR,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'abc@dfasdfasfasdfasdfas.fdfdfda',
                        style: TextStyle(
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
                      const Text(
                        '010-1234-1234',
                        style: TextStyle(
                          color: LIGHT_GRAY_COLOR,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            _renderLabel(
              name: '비밀번호 변경',
              child: Image.asset(
                'asset/img/icon_next.png',
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            _renderLabel(
              name: '서비스 이용 약관',
              child: Image.asset(
                'asset/img/icon_next.png',
              ),
            ),
            const Divider(
              color: DARK_GRAY_COLOR,
              height: 1,
            ),
            _renderLabel(
              name: '개인정보 처리방침',
              child: Image.asset(
                'asset/img/icon_next.png',
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
            _renderLabel(
              name: '로그아웃',
            )
          ],
        ),
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
