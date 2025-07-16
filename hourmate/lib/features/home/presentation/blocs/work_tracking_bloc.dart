import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/work_entry.dart';
import '../../domain/usecases/clock_in_usecase.dart';
import '../../domain/usecases/clock_out_usecase.dart';
import '../../domain/usecases/get_work_entries_usecase.dart';
import '../../domain/usecases/get_weekly_summary_usecase.dart';

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

  const WorkTrackingLoaded({
    required this.workEntries,
    this.activeWorkEntry,
    required this.isClockInEnabled,
  });

  @override
  List<Object?> get props => [workEntries, activeWorkEntry, isClockInEnabled];

  WorkTrackingLoaded copyWith({
    List<WorkEntry>? workEntries,
    WorkEntry? activeWorkEntry,
    bool? isClockInEnabled,
  }) {
    return WorkTrackingLoaded(
      workEntries: workEntries ?? this.workEntries,
      activeWorkEntry: activeWorkEntry ?? this.activeWorkEntry,
      isClockInEnabled: isClockInEnabled ?? this.isClockInEnabled,
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

      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: activeWorkEntry,
          isClockInEnabled: activeWorkEntry == null,
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
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: newEntry,
          isClockInEnabled: false,
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
      emit(
        WorkTrackingLoaded(
          workEntries: workEntries,
          activeWorkEntry: null,
          isClockInEnabled: true,
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
    return super.close();
  }
}
