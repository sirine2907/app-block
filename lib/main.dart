import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_gate.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/love_notes/domain/love_notes_repository.dart';
import 'features/session/presentation/bloc/session_bloc.dart';
import 'features/stats/presentation/bloc/stats_cubit.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initDependencies();
  // Mirror the love notes to the native layer so the block screen has them.
  await sl<LoveNotesRepository>().load();
  runApp(const ForAnisApp());
}

/// The root widget. Provides the app-wide [SessionBloc] and [StatsCubit].
class ForAnisApp extends StatelessWidget {
  const ForAnisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionBloc>.value(value: sl<SessionBloc>()),
        BlocProvider<StatsCubit>.value(value: sl<StatsCubit>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const AppGate(),
      ),
    );
  }
}
