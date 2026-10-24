part of 'apps_bloc.dart';

sealed class AppsEvent extends Equatable {
  const AppsEvent();

  @override
  List<Object?> get props => [];
}

/// Load installed apps and the previously saved selection.
class AppsLoaded extends AppsEvent {
  const AppsLoaded();
}

/// The search field text changed.
class AppSearchChanged extends AppsEvent {
  const AppSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Toggle a single app in/out of the blocked set.
class AppToggled extends AppsEvent {
  const AppToggled(this.packageName);

  final String packageName;

  @override
  List<Object?> get props => [packageName];
}

/// Select every app in the "Social media" preset that is installed.
class SocialPresetApplied extends AppsEvent {
  const SocialPresetApplied();
}

/// Clear the whole selection.
class SelectionCleared extends AppsEvent {
  const SelectionCleared();
}

/// Persist the current selection.
class SelectionSaved extends AppsEvent {
  const SelectionSaved();
}
