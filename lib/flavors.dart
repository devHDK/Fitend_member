enum Flavor {
  local,
  development,
  production,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.local:
        return 'fitend_local';
      case Flavor.development:
        return 'fitend_dev';
      case Flavor.production:
        return 'fitend';
      default:
        return 'title';
    }
  }

}
