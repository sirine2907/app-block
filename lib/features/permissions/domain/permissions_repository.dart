import 'permission.dart';

/// Reads permission status and opens the system screens that grant them.
abstract class PermissionsRepository {
  /// Current granted/denied status for every [PermissionType].
  Future<List<PermissionStatus>> checkAll();

  /// Opens the system screen to grant [type].
  Future<void> request(PermissionType type);
}
