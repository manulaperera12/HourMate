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
import 'features/onboarding/presentation/screens/get_started_screen.dart';
import 'features/profile/presentation/blocs/achievements_cubit.dart';

final GlobalKey<NavigatorState> globalNavigatorKey =
    GlobalKey<NavigatorState>();

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
    final WorkEntryLocalDataSource localDataSource = WorkEntryLocalDataSource();

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

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => WorkTrackingBloc(
            clockInUseCase: clockInUseCase,
            clockOutUseCase: clockOutUseCase,
            getWorkEntriesUseCase: getWorkEntriesUseCase,
            getWeeklySummaryUseCase: getWeeklySummaryUseCase,
          ),
        ),
        BlocProvider(
          create: (context) => AchievementsCubit()..loadAchievements(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: globalNavigatorKey,
        title: 'HourMate',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: OnboardingWrapper(
          sharedPreferences: sharedPreferences,
          getWorkEntriesUseCase: getWorkEntriesUseCase,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  final SharedPreferences sharedPreferences;
  final GetWorkEntriesUseCase getWorkEntriesUseCase;

  const OnboardingWrapper({
    super.key,
    required this.sharedPreferences,
    required this.getWorkEntriesUseCase,
  });

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _isLoading = true;
  bool _onboardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final onboardingCompleted =
        widget.sharedPreferences.getBool('onboarding_completed') ?? false;
    setState(() {
      _onboardingCompleted = onboardingCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.cyanBlue, AppTheme.neonYellowGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonYellowGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.black,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'HourMate',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _onboardingCompleted
        ? MainScaffold(getWorkEntriesUseCase: widget.getWorkEntriesUseCase)
        : GetStartedScreen(getWorkEntriesUseCase: widget.getWorkEntriesUseCase);
  }
}

class MainScaffold extends StatefulWidget {
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  const MainScaffold({super.key, required this.getWorkEntriesUseCase});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _KeepAliveWrapper(
        child: HomeScreen(
          showBackButton: false,
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
      ),
      _KeepAliveWrapper(
        child: WorkLogScreen(
          showBackButton: false,
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
      ),
      _KeepAliveWrapper(child: SummaryScreen(showBackButton: false)),
      _KeepAliveWrapper(
        child: SettingsScreen(
          showBackButton: false,
          getWorkEntriesUseCase: widget.getWorkEntriesUseCase,
        ),
      ),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bottomNavBg,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.13),
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
                unselectedItemColor: AppTheme.bottomNavUnselected.withOpacity(
                  0.7,
                ),
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
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
