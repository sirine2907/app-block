import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/platform/focus_channel.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/repositories/apps_repository.dart';
import '../models/installed_app_model.dart';

/// Lists apps via the native layer and stores the selection in prefs.
class AppsRepositoryImpl implements AppsRepository {
  AppsRepositoryImpl({required FocusChannel channel, required SharedPreferences prefs})
      : _channel = channel,
        _prefs = prefs;

  final FocusChannel _channel;
  final SharedPreferences _prefs;

  @override
  Future<List<InstalledApp>> getInstalledApps() async {
    final raw = await _channel.getInstalledApps();
    final apps = raw.map(InstalledAppModel.fromMap).toList()
      // Never offer the safety-critical packages for blocking.
      ..removeWhere((a) => SocialPreset.neverBlock.contains(a.packageName));
    apps.sort(
      (a, b) => a.appName.toLowerCase().compareTo(b.appName.toLowerCase()),
    );
    return apps;
  }

  @override
  Future<List<String>> getBlockedSelection() async {
    return _prefs.getStringList(AppConstants.keyBlockedPackages) ?? const [];
  }

  @override
  Future<void> saveBlockedSelection(List<String> packages) async {
    // Final safety net: strip anything we must never block.
    final safe = packages
        .where((p) => !SocialPreset.neverBlock.contains(p))
        .toSet()
        .toList();
    await _prefs.setStringList(AppConstants.keyBlockedPackages, safe);
  }
}
