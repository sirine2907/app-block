import '../entities/installed_app.dart';

/// Lists installed apps and persists which ones the user wants blocked.
abstract class AppsRepository {
  /// All launchable apps, sorted by name.
  Future<List<InstalledApp>> getInstalledApps();

  /// Packages the user has chosen to block.
  Future<List<String>> getBlockedSelection();

  /// Saves the chosen packages.
  Future<void> saveBlockedSelection(List<String> packages);
}
