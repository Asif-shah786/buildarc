import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart';
import 'package:ardennes/libraries/drawing/recent_drawing_service.dart';
import 'package:ardennes/models/drawings/drawing_sheet_view_log.dart';

class MockRecentDrawingService extends Mock implements RecentDrawingService {}

void main() {
  group('RecentDrawingBloc', () {
    final mockService = MockRecentDrawingService();
    final recentDrawingBloc = RecentDrawingBloc(mockService);

    test('initial state is RecentDrawingInitial', () {
      expect(recentDrawingBloc.state, RecentDrawingInitial());
    });

    final drawingItem = DrawingViewLogItem(
      title: 'Drawing 1',
      subTitle: 'SubTitle 1',
      url: 'url1',
    );

    final drawingLog = DrawingSheetViewLog(
      projectId: 'd8j3h8d7h3d8h',
      userId: 'FRjSTnqE5WzgwYB00ljyn466s4Ql',
      drawings: [drawingItem],
    );

    //Facing problem with testing and moacking stream
    blocTest<RecentDrawingBloc, RecentDrawingState>(
      'emits [RecentDrawingLoading, RecentDrawingLoaded] when LoadRecentDrawings event is added with valid IDs',
      build: () => recentDrawingBloc,
      setUp: () {
        when(mockService.getRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        )).thenAnswer((_) {
          final v = Stream<List<DrawingSheetViewLog>>.fromIterable([
            [drawingLog]
          ]);
          return v;
        });
      },
      act: (bloc) => bloc.add(
        LoadRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        ),
      ),
      expect: () => <RecentDrawingState>[
        RecentDrawingLoading(),
        RecentDrawingLoaded(drawingLog),
      ],
      verify: (_) {
        verify(mockService.getRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        )).called(1);
      },
    );
  });
}
