import 'package:fitend_member/flavors.dart';
import 'package:flutter/material.dart';

Widget flavorBanner({
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
