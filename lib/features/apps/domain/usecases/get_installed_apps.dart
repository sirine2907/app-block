import '../entities/installed_app.dart';
import '../repositories/apps_repository.dart';

/// Returns the launchable apps for the picker.
class GetInstalledApps {
  const GetInstalledApps(this._repository);

  final AppsRepository _repository;

  Future<List<InstalledApp>> call() => _repository.getInstalledApps();
}
