import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/installed_app.dart';
import '../../domain/usecases/get_blocked_selection.dart';
import '../../domain/usecases/get_installed_apps.dart';
import '../../domain/usecases/save_blocked_selection.dart';

part 'apps_event.dart';
part 'apps_state.dart';

/// Drives the app-picker screen: loading apps, searching, toggling, applying
/// the social preset and persisting the selection.
class AppsBloc extends Bloc<AppsEvent, AppsState> {
  AppsBloc({
    required GetInstalledApps getInstalledApps,
    required GetBlockedSelection getBlockedSelection,
    required SaveBlockedSelection saveBlockedSelection,
  })  : _getInstalledApps = getInstalledApps,
        _getBlockedSelection = getBlockedSelection,
        _saveBlockedSelection = saveBlockedSelection,
        super(const AppsState()) {
    on<AppsLoaded>(_onLoaded);
    on<AppSearchChanged>(_onSearchChanged);
    on<AppToggled>(_onToggled);
    on<SocialPresetApplied>(_onPresetApplied);
    on<SelectionCleared>(_onCleared);
    on<SelectionSaved>(_onSaved);
  }

  final GetInstalledApps _getInstalledApps;
  final GetBlockedSelection _getBlockedSelection;
  final SaveBlockedSelection _saveBlockedSelection;

  Future<void> _onLoaded(AppsLoaded event, Emitter<AppsState> emit) async {
    emit(state.copyWith(status: AppsStatus.loading));
    try {
      final apps = await _getInstalledApps();
      final saved = await _getBlockedSelection();
      emit(state.copyWith(
        status: AppsStatus.ready,
        apps: apps,
        selected: saved.toSet(),
      ));
    } catch (e) {
      emit(state.copyWith(status: AppsStatus.error, error: e.toString()));
    }
  }

  void _onSearchChanged(AppSearchChanged event, Emitter<AppsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onToggled(AppToggled event, Emitter<AppsState> emit) {
    final next = Set<String>.from(state.selected);
    if (next.contains(event.packageName)) {
      next.remove(event.packageName);
    } else {
      next.add(event.packageName);
    }
    emit(state.copyWith(selected: next, saved: false));
  }

  void _onPresetApplied(SocialPresetApplied event, Emitter<AppsState> emit) {
    final installed = state.apps.map((a) => a.packageName).toSet();
    final next = Set<String>.from(state.selected)
      ..addAll(SocialPreset.packages.where(installed.contains));
    emit(state.copyWith(selected: next, saved: false));
  }

  void _onCleared(SelectionCleared event, Emitter<AppsState> emit) {
    emit(state.copyWith(selected: const {}, saved: false));
  }

  Future<void> _onSaved(SelectionSaved event, Emitter<AppsState> emit) async {
    await _saveBlockedSelection(state.selected.toList());
    emit(state.copyWith(saved: true));
  }
}
