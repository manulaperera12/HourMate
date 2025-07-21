import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/work_entry.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_work_entries_usecase.dart';
import '../../domain/usecases/get_weekly_summary_usecase.dart';
import '../../../../core/services/settings_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../../../profile/presentation/blocs/achievements_cubit.dart';
import '../../../profile/data/repositories/achievement_repository.dart';
import 'package:vibration/vibration.dart';
import '../../data/datasources/work_entry_local_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../profile/presentation/widgets/level_up_popup.dart';
import '../../../../main.dart';
import '../../../profile/presentation/widgets/achievement_unlocked_popup.dart';

// Events
abstract class WorkTrackingEvent extends Equatable {
  const WorkTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkEntries extends WorkTrackingEvent {}

class LoadActiveWorkEntry extends WorkTrackingEvent {}

class ClockIn extends WorkTrackingEvent {
  final String taskDescription;
  final String taskRating;
  final String? taskComment;

  const ClockIn({
    required this.taskDescription,
    required this.taskRating,
    this.taskComment,
  });

  @override
  List<Object?> get props => [taskDescription, taskRating, taskComment];
}

class ClockOut extends WorkTrackingEvent {}

class LoadWeeklySummary extends WorkTrackingEvent {
  final DateTime weekStart;

  const LoadWeeklySummary({required this.weekStart});

  @override
  List<Object?> get props => [weekStart];
}

class StartBreak extends WorkTrackingEvent {
  final int durationMinutes;
  const StartBreak({required this.durationMinutes});
  @override
  List<Object?> get props => [durationMinutes];
}

class TickBreakTimer extends WorkTrackingEvent {}

class EndBreak extends WorkTrackingEvent {
  final bool autoEnded;
  const EndBreak({this.autoEnded = false});
  @override
  List<Object?> get props => [autoEnded];
}

class RestoreBreak extends WorkTrackingEvent {}

class UpdateBreakDuration extends WorkTrackingEvent {
  final int durationMinutes;
  const UpdateBreakDuration({required this.durationMinutes});
  @override
  List<Object?> get props => [durationMinutes];
}

// States
abstract class WorkTrackingState extends Equatable {
  const WorkTrackingState();

  @override
  List<Object?> get props => [];
}

class WorkTrackingInitial extends WorkTrackingState {}

class WorkTrackingLoading extends WorkTrackingState {}

class WorkTrackingLoaded extends WorkTrackingState {
  final List<WorkEntry> workEntries;
  final WorkEntry? activeWorkEntry;
  final bool isClockInEnabled;
  final Map<DateTime, double> dailyHours;
  final double dailyGoal;
  final bool isOnBreak;
  final DateTime? breakStartTime;
  final int? breakDurationMinutes;
  final int breakElapsedSeconds;
  final int breakRemainingSeconds;

  const WorkTrackingLoaded({
    required this.workEntries,
    this.activeWorkEntry,
    required this.isClockInEnabled,
    required this.dailyHours,
    required this.dailyGoal,
    this.isOnBreak = false,
    this.breakStartTime,
    this.breakDurationMinutes,
    this.breakElapsedSeconds = 0,
    this.breakRemainingSeconds = 0,
  });

  @override
  List<Object?> get props => [
    workEntries,
    activeWorkEntry,
    isClockInEnabled,
    dailyHours,
    dailyGoal,
    isOnBreak,
    breakStartTime,
    breakDurationMinutes,
    breakElapsedSeconds,
    breakRemainingSeconds,
  ];

  WorkTrackingLoaded copyWith({
    List<WorkEntry>? workEntries,
    WorkEntry? activeWorkEntry,
    bool? isClockInEnabled,
    Map<DateTime, double>? dailyHours,
    double? dailyGoal,
    bool? isOnBreak,
    DateTime? breakStartTime,
    int? breakDurationMinutes,
    int? breakElapsedSeconds,
    int? breakRemainingSeconds,
  }) {
    return WorkTrackingLoaded(
      workEntries: workEntries ?? this.workEntries,
      activeWorkEntry: activeWorkEntry ?? this.activeWorkEntry,
      isClockInEnabled: isClockInEnabled ?? this.isClockInEnabled,
      dailyHours: dailyHours ?? this.dailyHours,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      isOnBreak: isOnBreak ?? this.isOnBreak,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      breakElapsedSeconds: breakElapsedSeconds ?? this.breakElapsedSeconds,
      breakRemainingSeconds:
          breakRemainingSeconds ?? this.breakRemainingSeconds,
    );
  }
}

class WorkTrackingError extends WorkTrackingState {
  final String message;

  const WorkTrackingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class WeeklySummaryLoaded extends WorkTrackingState {
  final double totalHours;
  final Map<String, int> taskRatingSummary;
  final Map<DateTime, double> dailyHours;

  const WeeklySummaryLoaded({
    required this.totalHours,
    required this.taskRatingSummary,
    required this.dailyHours,
  });

  @override
  List<Object?> get props => [totalHours, taskRatingSummary, dailyHours];
}

// BLoC
class WorkTrackingBloc extends Bloc<WorkTrackingEvent, WorkTrackingState> {
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  final GetWeeklySummaryUseCase getWeeklySummaryUseCase;
  Timer? _timer;
  Timer? _breakTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  WorkTrackingBloc({
    required this.clockInUseCase,
    required this.clockOutUseCase,
    required this.getWorkEntriesUseCase,
    required this.getWeeklySummaryUseCase,
  }) : super(WorkTrackingInitial()) {
    on<LoadWorkEntries>(_onLoadWorkEntries);
    on<LoadActiveWorkEntry>(_onLoadActiveWorkEntry);
    on<ClockIn>(_onClockIn);
    on<ClockOut>(_onClockOut);
    on<LoadWeeklySummary>(_onLoadWeeklySummary);
    on<StartBreak>(_onStartBreak);
    on<TickBreakTimer>(_onTickBreakTimer);
    on<EndBreak>(_onEndBreak);
    on<RestoreBreak>(_onRestoreBreak);
    on<UpdateBreakDuration>(_onUpdateBreakDuration);
  }

  Future<void> _onLoadWorkEntries(
    LoadWorkEntries event,
    Emitter<WorkTrackingState> emit,
  ) async {
    emit(WorkTrackingLoading());
    try {
      final List<WorkEntry> workEntries = await getWorkEntriesUseCase();
      if (workEntries is! List<WorkEntry>) {
        await WorkEntryLocalDataSource.clearCorruptedWorkEntries();
        emit(
          const WorkTrackingError(
            message:
                'Work entry data was corrupted and has been reset. Please try again.',
          ),
        );
        return;
      }
      final WorkEntry? activeWorkEntry = await getWorkEntriesUseCase
          .getActiveEntry();
      final now = DateTime.now();
      final weekDay = now.weekday;
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: weekDay - 1));
      final weeklySummary = await getWeeklySummaryUseCase(startOfWeek);
      final double dailyGoal = await SettingsService.getDailyGoal();
      final int breakDuration = await SettingsService.getBreakDuration();
      // Merge break info if a break is active
      final breakInfo = await SettingsService.getActiveBreak();
      bool isOnBreak = false;
      DateTime? breakStartTime;
      int? breakDurationMinutes;
      int breakElapsedSeconds = 0;
      int breakRemainingSeconds = 0;
      if (breakInfo != null) {
        isOnBreak = true;
        breakStartTime = breakInfo['start'] as DateTime;
        breakDurationMinutes = breakInfo['duration'] as int;
        final elapsed = now.difference(breakStartTime).inSeconds;
        final total = breakDurationMinutes * 60;
        breakElapsedSeconds = elapsed;
        breakRemainingSeconds = total - elapsed;
      }
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: activeWorkEntry,
          isClockInEnabled: activeWorkEntry == null,
          dailyHours: weeklySummary.dailyHours,
          dailyGoal: dailyGoal,
          breakDurationMinutes: breakDuration,
          isOnBreak: isOnBreak,
          breakStartTime: breakStartTime,
          breakElapsedSeconds: breakElapsedSeconds,
          breakRemainingSeconds: breakRemainingSeconds,
        ),
      );
    } catch (e) {
      emit(WorkTrackingError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveWorkEntry(
    LoadActiveWorkEntry event,
    Emitter<WorkTrackingState> emit,
  ) async {
    try {
      final WorkEntry? activeWorkEntry = await getWorkEntriesUseCase
          .getActiveEntry();

      if (state is WorkTrackingLoaded) {
        final currentState = state as WorkTrackingLoaded;
        emit(
          currentState.copyWith(
            activeWorkEntry: activeWorkEntry,
            isClockInEnabled: activeWorkEntry == null,
          ),
        );
      }
    } catch (e) {
      emit(WorkTrackingError(message: e.toString()));
    }
  }

  Future<void> _onClockIn(
    ClockIn event,
    Emitter<WorkTrackingState> emit,
  ) async {
    emit(WorkTrackingLoading());
    try {
      final WorkEntry newEntry = await clockInUseCase(
        taskDescription: event.taskDescription,
        taskRating: event.taskRating,
        taskComment: event.taskComment,
      );
      // Vibration feedback on clock in
      final hasVibrator = await Vibration.hasVibrator();
      if (await SettingsService.getVibrationEnabled() && hasVibrator == true) {
        Vibration.vibrate(duration: 50);
      }
      // Start timer to update active work entry
      _startTimer();

      final List<WorkEntry> workEntries = await getWorkEntriesUseCase();
      final double dailyGoal = await SettingsService.getDailyGoal();
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: newEntry,
          isClockInEnabled: false,
          dailyHours: {},
          dailyGoal: dailyGoal,
        ),
      );
    } catch (e) {
      emit(WorkTrackingError(message: e.toString()));
    }
  }

  Future<void> _onClockOut(
    ClockOut event,
    Emitter<WorkTrackingState> emit,
  ) async {
    try {
      final WorkEntry updatedEntry = await clockOutUseCase();
      // Vibration feedback on clock out
      final hasVibratorOut = await Vibration.hasVibrator();
      if (await SettingsService.getVibrationEnabled() &&
          hasVibratorOut == true) {
        Vibration.vibrate(duration: 50);
      }
      // Sound feedback on clock out
      if (await SettingsService.getSoundEnabled()) {
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      }
      // Achievement logic: Early Bird
      if (updatedEntry.startTime.hour < 8) {
        await AchievementRepository.updateAchievementGlobal(
          'early_bird',
          unlocked: true,
          progress: 1.0,
        );
        await showAchievementPopupIfNeeded('early_bird', 'Early Bird');
      }
      // Consistency King: 30-day streak
      final allEntries = await getWorkEntriesUseCase();
      final streakDays = _calculateStreakDays(allEntries);
      if (streakDays >= 30) {
        await AchievementRepository.updateAchievementGlobal(
          'consistency_king',
          unlocked: true,
          progress: 1.0,
        );
        await showAchievementPopupIfNeeded(
          'consistency_king',
          'Consistency King',
        );
      } else {
        await AchievementRepository.updateAchievementGlobal(
          'consistency_king',
          progress: streakDays / 30.0,
        );
      }
      // Task Crusher: 100 tasks in a month
      final now = DateTime.now();
      final monthEntries = allEntries
          .where(
            (e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                !e.isActive,
          )
          .toList();
      if (monthEntries.length >= 100) {
        await AchievementRepository.updateAchievementGlobal(
          'task_crusher',
          unlocked: true,
          progress: 1.0,
        );
        await showAchievementPopupIfNeeded('task_crusher', 'Task Crusher');
      } else {
        await AchievementRepository.updateAchievementGlobal(
          'task_crusher',
          progress: monthEntries.length / 100.0,
        );
      }
      // Focus Master: 50 tasks with 90%+ productivity
      final focusEntries = allEntries
          .where(
            (e) =>
                (e.taskRating == 'Good' || e.taskRating == 'Average') &&
                !e.isActive,
          )
          .toList();
      final goodEntries = allEntries
          .where((e) => e.taskRating == 'Good' && !e.isActive)
          .toList();
      if (focusEntries.length >= 50 &&
          goodEntries.length / focusEntries.length >= 0.9) {
        await AchievementRepository.updateAchievementGlobal(
          'focus_master',
          unlocked: true,
          progress: 1.0,
        );
        await showAchievementPopupIfNeeded('focus_master', 'Focus Master');
      } else {
        final progress = focusEntries.isEmpty
            ? 0.0
            : (goodEntries.length / focusEntries.length).clamp(0.0, 1.0);
        await AchievementRepository.updateAchievementGlobal(
          'focus_master',
          progress: progress,
        );
      }
      // After achievements and before emitting loading state
      // Level-up detection
      final dataSource = WorkEntryLocalDataSource();
      final entries = (await dataSource.getAllWorkEntries())
          .map((e) => e.toEntity())
          .toList();
      final completed = entries.where((e) => !e.isActive).toList();
      final totalSessions = completed.length;
      int experience = totalSessions * 10;
      int level = (experience / 100).floor() + 1;
      final prefs = await SharedPreferences.getInstance();
      int prevLevel = prefs.getInt('level') ?? 1;
      if (level > prevLevel) {
        // Show popup globally
        Future.delayed(const Duration(milliseconds: 500), () {
          if (globalNavigatorKey.currentState != null) {
            showDialog(
              context: globalNavigatorKey.currentState!.overlay!.context,
              barrierDismissible: false,
              builder: (context) => LevelUpPopup(newLevel: level),
            );
          }
        });
        await prefs.setInt('level', level);
      }
      // Emit loading state before reloading entries to force HomeScreen rebuild
      emit(WorkTrackingLoading());
      add(LoadWorkEntries());
    } catch (e, st) {
      emit(
        WorkTrackingError(message: 'Failed to end session: ${e.toString()}'),
      );
    }
  }

  int _calculateStreakDays(List<WorkEntry> entries) {
    // Only consider completed entries
    final completed = entries.where((e) => !e.isActive).toList();
    if (completed.isEmpty) return 0;
    completed.sort((a, b) => b.date.compareTo(a.date));
    int streak = 1;
    DateTime prev = completed.first.date;
    for (int i = 1; i < completed.length; i++) {
      final diff = prev.difference(completed[i].date).inDays;
      if (diff == 1) {
        streak++;
        prev = completed[i].date;
      } else if (diff > 1) {
        break;
      }
    }
    return streak;
  }

  Future<void> _onLoadWeeklySummary(
    LoadWeeklySummary event,
    Emitter<WorkTrackingState> emit,
  ) async {
    emit(WorkTrackingLoading());
    try {
      final weeklySummary = await getWeeklySummaryUseCase(event.weekStart);
      emit(
        WeeklySummaryLoaded(
          totalHours: weeklySummary.totalHours,
          taskRatingSummary: weeklySummary.taskRatingSummary,
          dailyHours: weeklySummary.dailyHours,
        ),
      );
    } catch (e) {
      emit(WorkTrackingError(message: e.toString()));
    }
  }

  Future<void> _onStartBreak(
    StartBreak event,
    Emitter<WorkTrackingState> emit,
  ) async {
    // Defensive: Only start a break if not already on break
    if (state is WorkTrackingLoaded &&
        (state as WorkTrackingLoaded).isOnBreak) {
      return;
    }
    final now = DateTime.now();
    await SettingsService.startBreak(now, event.durationMinutes);
    _startBreakTimer(now, event.durationMinutes, emit);
  }

  void _startBreakTimer(
    DateTime start,
    int durationMinutes,
    Emitter<WorkTrackingState> emit, {
    int? elapsedSeconds,
    int? remainingSeconds,
  }) {
    _breakTimer?.cancel();
    final totalSeconds = durationMinutes * 60;
    final elapsed = elapsedSeconds ?? 0;
    final remaining = remainingSeconds ?? totalSeconds;
    emit(
      _currentLoadedState().copyWith(
        isOnBreak: true,
        breakStartTime: start,
        breakDurationMinutes: durationMinutes,
        breakElapsedSeconds: elapsed,
        breakRemainingSeconds: remaining,
      ),
    );
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TickBreakTimer());
    });
  }

  Future<void> _onTickBreakTimer(
    TickBreakTimer event,
    Emitter<WorkTrackingState> emit,
  ) async {
    if (state is! WorkTrackingLoaded) return;
    final loaded = state as WorkTrackingLoaded;
    if (!loaded.isOnBreak ||
        loaded.breakStartTime == null ||
        loaded.breakDurationMinutes == null)
      return;
    final now = DateTime.now();
    final elapsed = now.difference(loaded.breakStartTime!).inSeconds;
    final total = loaded.breakDurationMinutes! * 60;
    final remaining = total - elapsed;
    if (remaining <= 0) {
      add(const EndBreak(autoEnded: true));
    } else {
      emit(
        loaded.copyWith(
          breakElapsedSeconds: elapsed,
          breakRemainingSeconds: remaining,
        ),
      );
    }
  }

  Future<void> _onEndBreak(
    EndBreak event,
    Emitter<WorkTrackingState> emit,
  ) async {
    _breakTimer?.cancel();
    await SettingsService.endBreak();
    final breakDuration = await SettingsService.getBreakDuration();
    emit(
      _currentLoadedState().copyWith(
        isOnBreak: false,
        breakStartTime: null,
        breakDurationMinutes: breakDuration,
        breakElapsedSeconds: 0,
        breakRemainingSeconds: 0,
      ),
    );
    // Stop audio before playing break end sound
    final sound = await SettingsService.getBreakEndSound();
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/$sound'));
  }

  Future<void> _onRestoreBreak(
    RestoreBreak event,
    Emitter<WorkTrackingState> emit,
  ) async {
    final breakInfo = await SettingsService.getActiveBreak();
    if (breakInfo != null) {
      final start = breakInfo['start'] as DateTime;
      final duration = breakInfo['duration'] as int;
      final now = DateTime.now();
      final elapsed = now.difference(start).inSeconds;
      final total = duration * 60;
      final remaining = total - elapsed;
      if (remaining > 0) {
        _startBreakTimer(
          start,
          duration,
          emit,
          elapsedSeconds: elapsed,
          remainingSeconds: remaining,
        );
      } else {
        add(const EndBreak(autoEnded: true));
      }
    }
  }

  Future<void> _onUpdateBreakDuration(
    UpdateBreakDuration event,
    Emitter<WorkTrackingState> emit,
  ) async {
    await SettingsService.setBreakDuration(event.durationMinutes);
    if (state is WorkTrackingLoaded) {
      final currentState = state as WorkTrackingLoaded;
      emit(currentState.copyWith(breakDurationMinutes: event.durationMinutes));
    }
  }

  WorkTrackingLoaded _currentLoadedState() {
    return state is WorkTrackingLoaded
        ? state as WorkTrackingLoaded
        : WorkTrackingLoaded(
            workEntries: [],
            isClockInEnabled: true,
            dailyHours: {},
            dailyGoal: 8.0,
          );
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(LoadActiveWorkEntry());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    _breakTimer?.cancel();
    return super.close();
  }
}

Future<void> showAchievementPopupIfNeeded(
  String key,
  String displayName,
) async {
  final prefs = await SharedPreferences.getInstance();
  final shownKey = 'achievement_${key}_shown';
  if (!(prefs.getBool(shownKey) ?? false)) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (globalNavigatorKey.currentState != null) {
        showDialog(
          context: globalNavigatorKey.currentState!.overlay!.context,
          barrierDismissible: false,
          builder: (context) =>
              AchievementUnlockedPopup(achievementName: displayName),
        );
      }
    });
    await prefs.setBool(shownKey, true);
  }
}
