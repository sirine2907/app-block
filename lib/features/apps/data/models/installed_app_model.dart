import 'dart:convert';
import 'dart:typed_data';

import '../../domain/entities/installed_app.dart';

/// Parses the raw app map from native into an [InstalledApp].
class InstalledAppModel {
  InstalledAppModel._();

  static InstalledApp fromMap(Map<String, dynamic> map) {
    Uint8List? icon;
    final iconB64 = map['icon'] as String?;
    if (iconB64 != null && iconB64.isNotEmpty) {
      try {
        icon = base64Decode(iconB64);
      } catch (_) {
        icon = null;
      }
    }
    return InstalledApp(
      packageName: (map['packageName'] as String?) ?? '',
      appName: (map['appName'] as String?) ?? (map['packageName'] as String? ?? ''),
      icon: icon,
      isSystem: map['isSystem'] == true,
    );
  }
}
