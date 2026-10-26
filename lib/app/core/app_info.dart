/// Everything the app says about itself, so the drawer, the About screen and
/// the share message never disagree.
class AppInfo {
  static const name = 'Easy List';
  static const tagline = 'Plan smarter. Shop easier.';
  static const description = 'A simple way to organize your shopping lists.';

  /// Keep these two in step with `version:` in pubspec.yaml.
  static const versionName = '1.0.0';
  static const buildNumber = '3';

  static String get versionLabel => 'Version $versionName ($buildNumber)';

  /// The app's Google Play listing, shared by the drawer's "Share App" row.
  /// The id part must stay in step with `applicationId` in
  /// android/app/build.gradle.kts.
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.shopinglist2026.app';

  /// Body for the "Share App" action.
  static String get shareText =>
      '$name — $tagline\n$description\nGet it on Google Play: $playStoreUrl';
}
