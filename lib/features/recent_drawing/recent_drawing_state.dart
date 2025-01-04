part of 'recent_drawing_bloc.dart';

abstract class RecentDrawingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecentDrawingInitial extends RecentDrawingState {}

class RecentDrawingLoading extends RecentDrawingState {}

class RecentDrawingLoaded extends RecentDrawingState {
  final DrawingSheetViewLog? log;

  RecentDrawingLoaded(this.log);

  @override
  List<Object?> get props => [log];
}

class RecentDrawingError extends RecentDrawingState {
  final String message;

  RecentDrawingError(this.message);

  @override
  List<Object?> get props => [message];
}
