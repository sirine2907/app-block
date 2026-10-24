part of 'apps_bloc.dart';

enum AppsStatus { initial, loading, ready, error }

class AppsState extends Equatable {
  const AppsState({
    this.status = AppsStatus.initial,
    this.apps = const [],
    this.selected = const {},
    this.query = '',
    this.saved = false,
    this.error,
  });

  final AppsStatus status;
  final List<InstalledApp> apps;
  final Set<String> selected;
  final String query;
  final bool saved;
  final String? error;

  /// Apps filtered by the current search query.
  List<InstalledApp> get visibleApps {
    if (query.trim().isEmpty) return apps;
    final q = query.toLowerCase();
    return apps
        .where((a) =>
            a.appName.toLowerCase().contains(q) ||
            a.packageName.toLowerCase().contains(q))
        .toList();
  }

  int get selectedCount => selected.length;

  AppsState copyWith({
    AppsStatus? status,
    List<InstalledApp>? apps,
    Set<String>? selected,
    String? query,
    bool? saved,
    String? error,
  }) {
    return AppsState(
      status: status ?? this.status,
      apps: apps ?? this.apps,
      selected: selected ?? this.selected,
      query: query ?? this.query,
      saved: saved ?? this.saved,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, apps, selected, query, saved, error];
}
