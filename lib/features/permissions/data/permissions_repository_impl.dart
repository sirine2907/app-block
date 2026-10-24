import '../../../core/platform/focus_channel.dart';
import '../domain/permission.dart';
import '../domain/permissions_repository.dart';

/// Implements [PermissionsRepository] over the native [FocusChannel].
class PermissionsRepositoryImpl implements PermissionsRepository {
  PermissionsRepositoryImpl(this._channel);

  final FocusChannel _channel;

  @override
  Future<List<PermissionStatus>> checkAll() async {
    final raw = await _channel.checkPermissions();
    return PermissionType.values.map((type) {
      return PermissionStatus(type, raw[type.key] ?? false);
    }).toList();
  }

  @override
  Future<void> request(PermissionType type) =>
      _channel.requestPermission(type.key);
}
