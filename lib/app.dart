import 'package:fitend_member/common/view/splash_screen.dart';
import 'package:flutter/material.dart';

import 'flavors.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: F.title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Pretendard",
      ),
      home: _flavorBanner(
        child: const SplashScreen(),
        show: F.appFlavor == Flavor.development || F.appFlavor == Flavor.local
            ? true
            : false,
      ),
    );
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
                  letterSpacing: 1.0),
              textDirection: TextDirection.ltr,
              child: child,
            )
          : Container(
              child: child,
            );
}
