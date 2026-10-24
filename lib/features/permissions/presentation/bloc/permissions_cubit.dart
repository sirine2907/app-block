import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/permission.dart';
import '../../domain/permissions_repository.dart';

/// Holds the permission checklist and refreshes it when the user returns from
/// a system settings screen.
class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit(this._repository) : super(const PermissionsState.initial());

  final PermissionsRepository _repository;

  Future<void> refresh() async {
    emit(state.copyWith(loading: true));
    final statuses = await _repository.checkAll();
    emit(state.copyWith(loading: false, statuses: statuses, loaded: true));
  }

  Future<void> request(PermissionType type) async {
    await _repository.request(type);
  }
}

class PermissionsState extends Equatable {
  const PermissionsState({
    required this.loading,
    required this.loaded,
    required this.statuses,
  });

  const PermissionsState.initial()
      : loading = false,
        loaded = false,
        statuses = const [];

  final bool loading;
  final bool loaded;
  final List<PermissionStatus> statuses;

  bool get allGranted =>
      statuses.isNotEmpty && statuses.every((s) => s.granted);

  int get grantedCount => statuses.where((s) => s.granted).length;

  PermissionsState copyWith({
    bool? loading,
    bool? loaded,
    List<PermissionStatus>? statuses,
  }) {
    return PermissionsState(
      loading: loading ?? this.loading,
      loaded: loaded ?? this.loaded,
      statuses: statuses ?? this.statuses,
    );
  }

  @override
  List<Object?> get props => [loading, loaded, statuses];
}
