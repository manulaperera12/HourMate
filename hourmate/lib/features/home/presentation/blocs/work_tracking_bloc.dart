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
  }

  Future<void> _onLoadWorkEntries(
    LoadWorkEntries event,
    Emitter<WorkTrackingState> emit,
  ) async {
    emit(WorkTrackingLoading());
    try {
      final List<WorkEntry> workEntries = await getWorkEntriesUseCase();
      final WorkEntry? activeWorkEntry = await getWorkEntriesUseCase
          .getActiveEntry();
      // Calculate start of week
      final now = DateTime.now();
      final weekDay = now.weekday;
      final startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: weekDay - 1));
      final weeklySummary = await getWeeklySummaryUseCase(startOfWeek);
      final double dailyGoal = await SettingsService.getDailyGoal();
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: activeWorkEntry,
          isClockInEnabled: activeWorkEntry == null,
          dailyHours: weeklySummary.dailyHours,
          dailyGoal: dailyGoal,
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
    emit(WorkTrackingLoading());
    try {
      await clockOutUseCase();

      // Stop timer
      _stopTimer();

      final List<WorkEntry> workEntries = await getWorkEntriesUseCase();
      final double dailyGoal = await SettingsService.getDailyGoal();
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: null,
          isClockInEnabled: true,
          dailyHours: {},
          dailyGoal: dailyGoal,
        ),
      );
    } catch (e) {
      emit(WorkTrackingError(message: e.toString()));
    }
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
    final now = DateTime.now();
    await SettingsService.startBreak(now, event.durationMinutes);
    _startBreakTimer(now, event.durationMinutes, emit);
  }

  void _startBreakTimer(
    DateTime start,
    int durationMinutes,
    Emitter<WorkTrackingState> emit,
  ) {
    _breakTimer?.cancel();
    final totalSeconds = durationMinutes * 60;
    emit(
      _currentLoadedState().copyWith(
        isOnBreak: true,
        breakStartTime: start,
        breakDurationMinutes: durationMinutes,
        breakElapsedSeconds: 0,
        breakRemainingSeconds: totalSeconds,
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
    emit(
      _currentLoadedState().copyWith(
        isOnBreak: false,
        breakStartTime: null,
        breakDurationMinutes: null,
        breakElapsedSeconds: 0,
        breakRemainingSeconds: 0,
      ),
    );
    if (event.autoEnded) {
      final sound = await SettingsService.getBreakEndSound();
      await _audioPlayer.play(AssetSource('sounds/$sound'));
    }
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
        _startBreakTimer(start, duration, emit);
        emit(
          _currentLoadedState().copyWith(
            breakElapsedSeconds: elapsed,
            breakRemainingSeconds: remaining,
          ),
        );
      } else {
        add(const EndBreak(autoEnded: true));
      }
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
