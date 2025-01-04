part of 'recent_drawing_bloc.dart';

abstract class RecentDrawingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadRecentDrawings extends RecentDrawingEvent {
  final String projectId;
  final String userId;

  LoadRecentDrawings({required this.projectId, required this.userId});

  @override
  List<Object> get props => [projectId, userId];
}

class LogRecentDrawing extends RecentDrawingEvent {
  final String projectId;
  final String userId;
  final DrawingViewLogItem newItem;

  LogRecentDrawing({
    required this.projectId,
    required this.userId,
    required this.newItem,
  });

  @override
  List<Object> get props => [projectId, userId, newItem];
}
