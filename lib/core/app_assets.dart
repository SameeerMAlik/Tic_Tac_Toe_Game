/// Central paths for bundled assets (see `pubspec.yaml` → `flutter.assets`).
abstract final class AppAssets {
  /// In-app branding + source for launcher icons (`flutter_launcher_icons`) and splash.
  static const logo = 'assets/images/logo.png';

  /// Same asset as [logo]; Android launcher mipmaps are generated from this file.
  static const launcherIconSource = logo;
}
