import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart';
import 'package:ardennes/libraries/drawing/recent_drawing_service.dart';
import 'package:ardennes/models/drawings/drawing_sheet_view_log.dart';

// Generate mock using mockito's build_runner
@GenerateNiceMocks([MockSpec<RecentDrawingService>()])
import 'recent_drawing_bloc_test.mocks.dart';

void main() {
  group('RecentDrawingBloc', () {
    late MockRecentDrawingService mockService;
    late RecentDrawingBloc recentDrawingBloc;

    setUp(() {
      mockService = MockRecentDrawingService();
      recentDrawingBloc = RecentDrawingBloc(mockService);
    });

    tearDown(() {
      recentDrawingBloc.close();
    });

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

    blocTest<RecentDrawingBloc, RecentDrawingState>(
      'emits [RecentDrawingLoading, RecentDrawingLoaded] when LoadRecentDrawings event is added',
      build: () {
        when(mockService.getRecentDrawings(
          projectId: anyNamed('projectId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) => Stream.value([drawingLog]));
        return recentDrawingBloc;
      },
      act: (bloc) => bloc.add(
        LoadRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        ),
      ),
      expect: () => [
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

    blocTest<RecentDrawingBloc, RecentDrawingState>(
      'emits [RecentDrawingLoading, RecentDrawingLoaded(null)] when no drawings found',
      build: () {
        when(mockService.getRecentDrawings(
          projectId: anyNamed('projectId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) => Stream.value([]));
        return recentDrawingBloc;
      },
      act: (bloc) => bloc.add(
        LoadRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        ),
      ),
      expect: () => [
        RecentDrawingLoading(),
        RecentDrawingLoaded(null),
      ],
    );

    blocTest<RecentDrawingBloc, RecentDrawingState>(
      'emits [RecentDrawingLoading, RecentDrawingError] when error occurs',
      build: () {
        when(mockService.getRecentDrawings(
          projectId: anyNamed('projectId'),
          userId: anyNamed('userId'),
        )).thenAnswer((_) => Stream.error('Error'));
        return recentDrawingBloc;
      },
      act: (bloc) => bloc.add(
        LoadRecentDrawings(
          projectId: drawingLog.projectId,
          userId: drawingLog.userId,
        ),
      ),
      expect: () => [
        RecentDrawingLoading(),
        RecentDrawingError('Failed to load recent drawings.'),
      ],
    );
  });
}
