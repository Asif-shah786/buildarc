import 'package:ardennes/features/recent_drawing/recent_drawing_bloc.dart';
import 'package:ardennes/features/recent_drawing/recent_drawing_view.dart';
import 'package:ardennes/libraries/account_context/bloc.dart';
import 'package:ardennes/libraries/account_context/state.dart';
import 'package:ardennes/models/drawings/drawing_sheet_view_log.dart';
import 'package:ardennes/models/projects/project_metadata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:go_router/go_router.dart';

// Generate mocks
@GenerateNiceMocks([
  MockSpec<RecentDrawingBloc>(),
  MockSpec<AccountContextBloc>(),
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<GoRouter>(),
])
import 'recent_drawing_view_test.mocks.dart';

void main() {
  late MockRecentDrawingBloc mockRecentDrawingBloc;
  late MockAccountContextBloc mockAccountContextBloc;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockRecentDrawingBloc = MockRecentDrawingBloc();
    mockAccountContextBloc = MockAccountContextBloc();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();

    // Setup default behaviors
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test-uid');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<RecentDrawingBloc>.value(value: mockRecentDrawingBloc),
          BlocProvider<AccountContextBloc>.value(value: mockAccountContextBloc),
        ],
        child: RecentDrawingView(),
      ),
    );
  }

  group('RecentDrawingView', () {
    testWidgets('shows loading indicator when state is RecentDrawingLoading', (WidgetTester tester) async {
      // Arrange
      when(mockRecentDrawingBloc.state).thenReturn(RecentDrawingLoading());
      when(mockAccountContextBloc.state).thenReturn(
        AccountContextLoadedState(
          selectedProject: ProjectMetadata(id: 'test-project'),
          projects: [ProjectMetadata(id: 'test-project')],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty message when no drawings are available', (WidgetTester tester) async {
      // Arrange
      when(mockRecentDrawingBloc.state).thenReturn(
        RecentDrawingLoaded(null),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No recently viewed sheets'), findsOneWidget);
    });

    testWidgets('shows drawings list when drawings are available', (WidgetTester tester) async {
      // Arrange
      final mockDrawings = [
        DrawingViewLogItem(
          title: 'Drawing 1',
          subTitle: 'Subtitle 1',
          url: 'url1',
        ),
        DrawingViewLogItem(
          title: 'Drawing 2',
          subTitle: 'Subtitle 2',
          url: 'url2',
        ),
      ];

      final drawingLog = DrawingSheetViewLog(
        projectId: 'test-project',
        userId: 'test-user',
        drawings: mockDrawings,
      );

      when(mockRecentDrawingBloc.state).thenReturn(RecentDrawingLoaded(drawingLog));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      for (var drawing in mockDrawings) {
        expect(find.text(drawing.title), findsOneWidget);
        expect(find.text(drawing.subTitle), findsOneWidget);
      }
    });

    testWidgets('shows error message and retry button when error occurs', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Failed to load drawings';
      when(mockRecentDrawingBloc.state).thenReturn(RecentDrawingError(errorMessage));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('tapping Try again button triggers reload', (WidgetTester tester) async {
      // Arrange
      when(mockRecentDrawingBloc.state).thenReturn(RecentDrawingError('Error'));
      when(mockAccountContextBloc.state).thenReturn(
        AccountContextLoadedState(
          selectedProject: ProjectMetadata(id: 'test-project'),
          projects: [ProjectMetadata(id: 'test-project')],
        ),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Try again'));
      await tester.pump();

      // Verify
      verify(mockRecentDrawingBloc.add(
        LoadRecentDrawings(
          projectId: 'test-project',
          userId: 'test-uid',
        ),
      )).called(1);
    });
  });
}
