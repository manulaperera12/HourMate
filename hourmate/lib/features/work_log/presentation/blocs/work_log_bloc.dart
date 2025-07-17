import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../home/domain/entities/work_entry.dart';
import '../../../home/domain/usecases/get_work_entries_usecase.dart';

// Events
abstract class WorkLogEvent extends Equatable {
  const WorkLogEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkLogEntries extends WorkLogEvent {}

// States
abstract class WorkLogState extends Equatable {
  const WorkLogState();
  @override
  List<Object?> get props => [];
}

class WorkLogInitial extends WorkLogState {}

class WorkLogLoading extends WorkLogState {}

class WorkLogLoaded extends WorkLogState {
  final List<WorkEntry> entries;
  const WorkLogLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}

class WorkLogError extends WorkLogState {
  final String message;
  const WorkLogError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class WorkLogBloc extends Bloc<WorkLogEvent, WorkLogState> {
  final GetWorkEntriesUseCase getWorkEntriesUseCase;
  WorkLogBloc({required this.getWorkEntriesUseCase}) : super(WorkLogInitial()) {
    on<LoadWorkLogEntries>(_onLoadWorkLogEntries);
  }

  Future<void> _onLoadWorkLogEntries(
    LoadWorkLogEntries event,
    Emitter<WorkLogState> emit,
  ) async {
    emit(WorkLogLoading());
    try {
      final entries = await getWorkEntriesUseCase();
      emit(WorkLogLoaded(entries));
    } catch (e) {
      emit(WorkLogError(e.toString()));
    }
  }
}
