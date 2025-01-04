import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../libraries/drawing/recent_drawing_service.dart';
import '../../models/drawings/drawing_sheet_view_log.dart';

part 'recent_drawing_event.dart';
part 'recent_drawing_state.dart';

class RecentDrawingBloc extends Bloc<RecentDrawingEvent, RecentDrawingState> {
  final RecentDrawingService service;

  RecentDrawingBloc(this.service) : super(RecentDrawingInitial()) {
    on<LoadRecentDrawings>(_onLoadRecentDrawings);
    on<LogRecentDrawing>(_onLogRecentDrawing);
  }

  Future<void> _onLoadRecentDrawings(LoadRecentDrawings event, Emitter<RecentDrawingState> emit) async {
    emit(RecentDrawingLoading());

    try {
      // Await the stream processing completely
      final subscription = service
          .getRecentDrawings(
        projectId: event.projectId,
        userId: event.userId,
      )
          .listen((drawings) {
        if (drawings.isNotEmpty) {
          emit(RecentDrawingLoaded(drawings.first));
        } else {
          emit(RecentDrawingLoaded(null));
        }
      }, onError: (error) {
        emit(RecentDrawingError('Failed to load recent drawings.'));
      });

      // Ensure subscription completes
      await subscription.asFuture();
    } catch (e) {
      emit(RecentDrawingError('Failed to load recent drawings.'));
    }
  }

  Future<void> _onLogRecentDrawing(LogRecentDrawing event, Emitter<RecentDrawingState> emit) async {
    try {
      await service.logDrawingView(
        projectId: event.projectId,
        userId: event.userId,
        newItem: event.newItem,
      );
    } catch (e) {
      emit(RecentDrawingError('Failed to log recent drawing.'));
    }
  }
}
