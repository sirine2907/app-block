import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A launchable app installed on the device, shown in the picker.
class InstalledApp extends Equatable {
  const InstalledApp({
    required this.packageName,
    required this.appName,
    this.icon,
    this.isSystem = false,
  });

  final String packageName;
  final String appName;

  /// Raw PNG bytes of the launcher icon, if available.
  final Uint8List? icon;
  final bool isSystem;

  @override
  List<Object?> get props => [packageName, appName, isSystem];
}
