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
import 'features/work_log/presentation/screens/work_log_screen.dart';
import 'features/weekly_summary/presentation/screens/summary_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';

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
        home: const MainScaffold(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(showBackButton: false),
    WorkLogScreen(showBackButton: false),
    SummaryScreen(showBackButton: false), // Use new SummaryScreen as main tab
    SettingsScreen(showBackButton: false), // Settings screen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bottomNavBg,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.13),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.bottomNavSelected,
              unselectedItemColor:
                  AppTheme.bottomNavUnselected.withValues(alpha: 0.7),
              selectedFontSize: 13,
              unselectedFontSize: 13,
              iconSize: 28,
              elevation: 0,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_rounded),
                  label: 'Log',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Summary',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
