import 'package:fitend_member/common/const/data.dart';
import 'package:flutter/material.dart';
import '../flavors.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(F.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Hello ${F.title}',
            ),
            Text(
              F.appFlavor.toString(),
            ),
            Text(buildEnv),
            Text(Flavor.local.name),
            Text((Flavor.local.name == buildEnv).toString()),
          ],
        ),
      ),
    );
  }
}
