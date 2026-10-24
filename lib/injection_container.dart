import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/platform/focus_channel.dart';
import 'features/apps/data/repositories/apps_repository_impl.dart';
import 'features/apps/domain/repositories/apps_repository.dart';
import 'features/apps/domain/usecases/get_blocked_selection.dart';
import 'features/apps/domain/usecases/get_installed_apps.dart';
import 'features/apps/domain/usecases/save_blocked_selection.dart';
import 'features/apps/presentation/bloc/apps_bloc.dart';
import 'features/love_notes/data/love_notes_repository_impl.dart';
import 'features/love_notes/domain/love_notes_repository.dart';
import 'features/permissions/data/permissions_repository_impl.dart';
import 'features/permissions/domain/permissions_repository.dart';
import 'features/permissions/presentation/bloc/permissions_cubit.dart';
import 'features/session/data/repositories/session_repository_impl.dart';
import 'features/session/domain/repositories/session_repository.dart';
import 'features/session/domain/usecases/get_session_state.dart';
import 'features/session/domain/usecases/start_session.dart';
import 'features/session/domain/usecases/watch_session.dart';
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/stats/data/stats_repository_impl.dart';
import 'features/stats/domain/repositories/stats_repository.dart';
import 'features/stats/domain/usecases/get_stats.dart';
import 'features/stats/domain/usecases/record_completed_session.dart';
import 'features/stats/presentation/bloc/stats_cubit.dart';

/// The service locator. Wiring lives here so the widget tree stays clean.
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<FocusChannel>(() => FocusChannel());

  // Repositories
  sl.registerLazySingleton<LoveNotesRepository>(
    () => LoveNotesRepositoryImpl(channel: sl()),
  );
  sl.registerLazySingleton<SessionRepository>(
    () => SessionRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<PermissionsRepository>(
    () => PermissionsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AppsRepository>(
    () => AppsRepositoryImpl(channel: sl(), prefs: sl()),
  );
  sl.registerLazySingleton<StatsRepository>(
    () => StatsRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => StartSession(sl()));
  sl.registerLazySingleton(() => WatchSession(sl()));
  sl.registerLazySingleton(() => GetSessionState(sl()));
  sl.registerLazySingleton(() => GetInstalledApps(sl()));
  sl.registerLazySingleton(() => GetBlockedSelection(sl()));
  sl.registerLazySingleton(() => SaveBlockedSelection(sl()));
  sl.registerLazySingleton(() => GetStats(sl()));
  sl.registerLazySingleton(() => RecordCompletedSession(sl()));

  // Blocs / Cubits
  sl.registerLazySingleton<SessionBloc>(
    () => SessionBloc(
      startSession: sl(),
      watchSession: sl(),
      getSessionState: sl(),
      recordCompletedSession: sl(),
      loveNotes: sl(),
    ),
  );
  sl.registerLazySingleton<StatsCubit>(
    () => StatsCubit(getStats: sl(), repository: sl(), loveNotes: sl()),
  );
  sl.registerFactory<PermissionsCubit>(() => PermissionsCubit(sl()));
  sl.registerFactory<AppsBloc>(
    () => AppsBloc(
      getInstalledApps: sl(),
      getBlockedSelection: sl(),
      saveBlockedSelection: sl(),
    ),
  );
}
