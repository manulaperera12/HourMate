import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/datasources/work_entry_local_datasource.dart';
import 'features/home/data/repositories/work_entry_repository_impl.dart';
import 'features/home/domain/usecases/clock_in_usecase.dart';
import 'features/home/domain/usecases/clock_out_usecase.dart';
import 'features/home/domain/usecases/get_work_entries_usecase.dart';
import 'features/home/domain/usecases/get_weekly_summary_usecase.dart';
import 'features/home/presentation/blocs/work_tracking_bloc.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();

  runApp(MyApp(sharedPreferences: sharedPreferences));
}

class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    // Create dependencies
    final WorkEntryLocalDataSource localDataSource =
        WorkEntryLocalDataSourceImpl(sharedPreferences: sharedPreferences);

    final WorkEntryRepositoryImpl repository = WorkEntryRepositoryImpl(
      localDataSource: localDataSource,
    );

    final ClockInUseCase clockInUseCase = ClockInUseCase(
      repository: repository,
      uuid: const Uuid(),
    );

    final ClockOutUseCase clockOutUseCase = ClockOutUseCase(
      repository: repository,
    );

    final GetWorkEntriesUseCase getWorkEntriesUseCase = GetWorkEntriesUseCase(
      repository: repository,
    );

    final GetWeeklySummaryUseCase getWeeklySummaryUseCase =
        GetWeeklySummaryUseCase(repository: repository);

    return BlocProvider(
      create: (context) => WorkTrackingBloc(
        clockInUseCase: clockInUseCase,
        clockOutUseCase: clockOutUseCase,
        getWorkEntriesUseCase: getWorkEntriesUseCase,
        getWeeklySummaryUseCase: getWeeklySummaryUseCase,
      ),
      child: MaterialApp(
        title: 'HourMate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
