import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:for_anis/features/apps/domain/entities/installed_app.dart';
import 'package:for_anis/features/apps/domain/repositories/apps_repository.dart';
import 'package:for_anis/features/apps/domain/usecases/get_blocked_selection.dart';
import 'package:for_anis/features/apps/domain/usecases/get_installed_apps.dart';
import 'package:for_anis/features/apps/domain/usecases/save_blocked_selection.dart';
import 'package:for_anis/features/apps/presentation/bloc/apps_bloc.dart';

/// In-memory fake standing in for the native-backed repository.
class _FakeAppsRepository implements AppsRepository {
  _FakeAppsRepository(this._apps);

  final List<InstalledApp> _apps;
  List<String> saved = const [];

  @override
  Future<List<InstalledApp>> getInstalledApps() async => _apps;

  @override
  Future<List<String>> getBlockedSelection() async => saved;

  @override
  Future<void> saveBlockedSelection(List<String> packages) async {
    saved = packages;
  }
}

AppsBloc _buildBloc(_FakeAppsRepository repo) => AppsBloc(
      getInstalledApps: GetInstalledApps(repo),
      getBlockedSelection: GetBlockedSelection(repo),
      saveBlockedSelection: SaveBlockedSelection(repo),
    );

void main() {
  final apps = [
    const InstalledApp(packageName: 'com.instagram.android', appName: 'Instagram'),
    const InstalledApp(packageName: 'com.x.android', appName: 'X'),
    const InstalledApp(packageName: 'com.example.notes', appName: 'Notes'),
  ];

  blocTest<AppsBloc, AppsState>(
    'loads installed apps and the saved selection',
    build: () => _buildBloc(_FakeAppsRepository(apps)..saved = ['com.x.android']),
    act: (bloc) => bloc.add(const AppsLoaded()),
    verify: (bloc) {
      expect(bloc.state.status, AppsStatus.ready);
      expect(bloc.state.apps.length, 3);
      expect(bloc.state.selected, {'com.x.android'});
    },
  );

  // The async AppsLoaded handler must finish before later (synchronous)
  // events, so these tests await a tick after loading.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  blocTest<AppsBloc, AppsState>(
    'toggles an app in and out of the selection',
    build: () => _buildBloc(_FakeAppsRepository(apps)),
    act: (bloc) async {
      bloc.add(const AppsLoaded());
      await settle();
      bloc.add(const AppToggled('com.instagram.android'));
      bloc.add(const AppToggled('com.x.android'));
      bloc.add(const AppToggled('com.instagram.android'));
    },
    verify: (bloc) => expect(bloc.state.selected, {'com.x.android'}),
  );

  blocTest<AppsBloc, AppsState>(
    'applies the social preset to installed apps only',
    build: () => _buildBloc(_FakeAppsRepository(apps)),
    act: (bloc) async {
      bloc.add(const AppsLoaded());
      await settle();
      bloc.add(const SocialPresetApplied());
    },
    verify: (bloc) {
      expect(bloc.state.selected, contains('com.instagram.android'));
      expect(bloc.state.selected, contains('com.x.android'));
      expect(bloc.state.selected, isNot(contains('com.example.notes')));
    },
  );

  blocTest<AppsBloc, AppsState>(
    'clears the selection',
    build: () => _buildBloc(_FakeAppsRepository(apps)),
    act: (bloc) async {
      bloc.add(const AppsLoaded());
      await settle();
      bloc.add(const SocialPresetApplied());
      bloc.add(const SelectionCleared());
    },
    verify: (bloc) => expect(bloc.state.selected, isEmpty),
  );

  blocTest<AppsBloc, AppsState>(
    'filters apps by the search query',
    build: () => _buildBloc(_FakeAppsRepository(apps)),
    act: (bloc) async {
      bloc.add(const AppsLoaded());
      await settle();
      bloc.add(const AppSearchChanged('insta'));
    },
    verify: (bloc) {
      expect(bloc.state.visibleApps.length, 1);
      expect(bloc.state.visibleApps.first.packageName, 'com.instagram.android');
    },
  );

  test('saves the selection to the repository', () async {
    final repo = _FakeAppsRepository(apps);
    final bloc = _buildBloc(repo);
    bloc.add(const AppsLoaded());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    bloc.add(const AppToggled('com.instagram.android'));
    bloc.add(const SelectionSaved());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(repo.saved, ['com.instagram.android']);
    await bloc.close();
  });
}
