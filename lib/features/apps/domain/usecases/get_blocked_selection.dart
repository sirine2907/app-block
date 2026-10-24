import '../repositories/apps_repository.dart';

/// Reads the saved set of apps the user wants blocked.
class GetBlockedSelection {
  const GetBlockedSelection(this._repository);

  final AppsRepository _repository;

  Future<List<String>> call() => _repository.getBlockedSelection();
}
