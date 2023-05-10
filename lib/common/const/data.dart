import 'dart:io';

import 'package:fitend_member/flavors.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

final buildEnv = F.appFlavor == Flavor.local
    ? "local"
    : F.appFlavor == Flavor.development
        ? "development"
        : "production";

const emulatorIp = 'http://10.0.2.2:4000/api/mobile';
const simulatorIp = 'http://127.0.0.1:4000/api/mobile';

final localIp = F.appFlavor == Flavor.local && Platform.isAndroid
    ? emulatorIp
    : simulatorIp;
const devIp = '';
const deployIp = '';
