import 'package:fitend_member/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // App flavor 값 조회
  // flavor = 'dev' | 'product'
  String? flavor =
      await const MethodChannel('flavor').invokeMethod<String>('getFlavor');
  Config(flavor);

  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final route = ref.watch(routerProvider);

    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
    );
  }
}

class Config {
  final String baseUrl;
  final String token;
  static late final Config instance;

  Config._dev()
      : baseUrl = '', // dev url
        token = ''; // dev token

  Config._product()
      : baseUrl = '', // product url
        token = ''; // product token

  factory Config(String? _flavor) {
    if (_flavor == 'development') {
      instance = Config._dev();
    } else if (_flavor == 'production') {
      instance = Config._product();
    } else {
      throw Exception("Unknown flavor : $_flavor}");
    }

    return instance;
  }
}
