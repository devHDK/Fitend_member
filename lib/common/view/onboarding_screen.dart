import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fitend_member/common/component/dialog_widgets.dart';
import 'package:fitend_member/common/const/pallete.dart';
import 'package:fitend_member/common/layout/default_layout.dart';
import 'package:fitend_member/flavors.dart';
import 'package:fitend_member/user/model/user_model.dart';
import 'package:fitend_member/user/provider/get_me_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:store_redirect/store_redirect.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  static String get routeName => 'onboard';
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  PackageInfo? packageInfo;
  String? version;

  @override
  void initState() {
    super.initState();
    // getStoreVersionInfo();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(getMeProvider);

    if (state is UserModelError && state.statusCode == 444) {
      return DialogWidgets.oneButtonDialog(
        message: '회원님들의 의견을 반영하여\n서비스 사용성을 개선했어요 🎉',
        confirmText: '업데이트 하러 가기',
        confirmOnTap: () {
          StoreRedirect.redirect(
            androidAppId: 'com.raid.fitend',
            iOSAppId: 'id6450522413',
          );
        },
        dismissable: false,
      );
    }

    return DefaultLayout(
      backgroundColor: Pallete.background,
      child: _flavorBanner(
        child: Center(
            child: AnimatedTextKit(animatedTexts: [
          ColorizeAnimatedText(
            'F I T E N D',
            textStyle: GoogleFonts.audiowide(
              fontSize: 45,
              fontWeight: FontWeight.w500,
              color: Pallete.point,
            ),
            colors: [
              Pallete.point,
              Colors.pink.shade300,
              Colors.white,
            ],
            speed: const Duration(milliseconds: 400),
          )
        ])
            // DefaultTextStyle(
            //   style: GoogleFonts.audiowide(
            //     fontSize: 45,
            //     fontWeight: FontWeight.w500,
            //     color: Pallete.point,
            //   ),
            //   child: const Text('F I T E N D'),
            // ),
            ),
        show: F.appFlavor == Flavor.development || F.appFlavor == Flavor.local
            ? true
            : false,
      ),
    );
  }
}

Widget _flavorBanner({
  required Widget child,
  bool show = true,
}) =>
    show
        ? Banner(
            location: BannerLocation.topStart,
            message: F.name,
            color: Colors.green.withOpacity(0.6),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.0,
              letterSpacing: 1.0,
            ),
            textDirection: TextDirection.ltr,
            child: child,
          )
        : Container(
            child: child,
          );
