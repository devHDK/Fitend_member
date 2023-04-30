import 'package:fitend_member/common/layout/default_layout.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultLayout(
        child: Center(
      child: Text('Home Screen'),
    ));
  }
}
