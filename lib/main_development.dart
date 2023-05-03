import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'flavors.dart';

void main() {
  F.appFlavor = Flavor.development;

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
