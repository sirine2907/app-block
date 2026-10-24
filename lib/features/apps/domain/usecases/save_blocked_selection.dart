import '../repositories/apps_repository.dart';

/// Persists the set of apps the user wants blocked.
class SaveBlockedSelection {
  const SaveBlockedSelection(this._repository);

  final AppsRepository _repository;

  Future<void> call(List<String> packages) =>
      _repository.saveBlockedSelection(packages);
}
