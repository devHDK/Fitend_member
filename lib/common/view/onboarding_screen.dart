import 'package:fitend_member/common/const/colors.dart';
import 'package:fitend_member/common/layout/default_layout.dart';
import 'package:fitend_member/flavors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

class OnBoardingScreen extends StatefulWidget {
  static String get routeName => 'onboard';
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PackageInfo? packageInfo;
  String? version;

  @override
  void initState() {
    super.initState();
    // getStoreVersionInfo();
  }

  // void getStoreVersionInfo() async {
  //   packageInfo = await PackageInfo.fromPlatform();
  //   version = packageInfo!.version;
  //   await Future.wait([
  //     checkUpdatable(version!).then((value) {
  //       print('result $value');
  //       return Future.value(true);
  //     })
  //   ]);
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: BACKGROUND_COLOR,
      child: _flavorBanner(
        child: Center(
          child: DefaultTextStyle(
            style: GoogleFonts.audiowide(
              fontSize: 45,
              fontWeight: FontWeight.w500,
              color: POINT_COLOR,
            ),
            child: const Text('F I T E N D'),
          ),
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
