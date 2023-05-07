import 'dart:io';

import 'package:fitend_member/flavors.dart';

const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

final buildEnv = F.appFlavor == Flavor.local
    ? "local"
    : F.appFlavor == Flavor.development
        ? "development"
        : "production";

const emulatorIp = '10.0.2.2';
const simulatorIp = '127.0.0.1:3000';

final ip = Platform.isIOS ? simulatorIp : emulatorIp;
