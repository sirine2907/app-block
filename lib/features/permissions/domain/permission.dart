import 'package:equatable/equatable.dart';

/// The Android permissions / special accesses the app needs to enforce a
/// session. Each maps to a native key understood by the Kotlin layer.
enum PermissionType {
  accessibility('accessibility'),
  deviceAdmin('deviceAdmin'),
  usageAccess('usageAccess'),
  overlay('overlay'),
  batteryOptimization('batteryOptimization'),
  notifications('notifications');

  const PermissionType(this.key);

  /// The identifier sent across the method channel.
  final String key;

  static PermissionType? fromKey(String key) {
    for (final t in PermissionType.values) {
      if (t.key == key) return t;
    }
    return null;
  }
}

/// A permission together with whether it is currently granted.
class PermissionStatus extends Equatable {
  const PermissionStatus(this.type, this.granted);

  final PermissionType type;
  final bool granted;

  PermissionStatus copyWith({bool? granted}) =>
      PermissionStatus(type, granted ?? this.granted);

  @override
  List<Object?> get props => [type, granted];
}
