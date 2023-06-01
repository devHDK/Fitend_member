import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'flavors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  F.appFlavor = Flavor.local;

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
