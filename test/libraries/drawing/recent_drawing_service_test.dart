import 'package:flutter_test/flutter_test.dart';
import 'package:ardennes/libraries/drawing/recent_drawing_service.dart';
import 'package:ardennes/models/drawings/drawing_sheet_view_log.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('RecentDrawingService', () {
    late FakeFirebaseFirestore mockFirestore;
    late RecentDrawingService service;

    setUp(() {
      mockFirestore = FakeFirebaseFirestore();
      service = RecentDrawingService(firestore: mockFirestore);
    });

    test('logDrawingView adds a new log if no existing log is found', () async {
      const projectId = 'project1';
      const userId = 'user1';
      const newItem = DrawingViewLogItem(
        title: 'Title 1',
        subTitle: 'Subtitle 1',
        url: 'http://example.com/image1',
      );

      await service.logDrawingView(
        projectId: projectId,
        userId: userId,
        newItem: newItem,
      );

      final snapshot = await mockFirestore
          .collection('home_screens')
          .where('project_id', isEqualTo: projectId)
          .where('user_id', isEqualTo: userId)
          .get();
      expect(snapshot.docs.length, 1);

      final loggedData = snapshot.docs.first.data();
      expect(loggedData['project_id'], projectId);
      expect(loggedData['user_id'], userId);
      expect(loggedData['drawings'][0]['title'], newItem.title);
    });

    test('logDrawingView updates an existing log', () async {
      const projectId = 'project1';
      const userId = 'user1';

      final existingLog = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [
          const DrawingViewLogItem(
            title: 'Old Title',
            subTitle: 'Old Subtitle',
            url: 'http://example.com/old_image',
          ),
        ],
      );

      await mockFirestore.collection('home_screens').add(existingLog.toMap());

      const newItem = DrawingViewLogItem(
        title: 'New Title',
        subTitle: 'New Subtitle',
        url: 'http://example.com/new_image',
      );

      await service.logDrawingView(
        projectId: projectId,
        userId: userId,
        newItem: newItem,
      );

      final snapshot = await mockFirestore
          .collection('home_screens')
          .where('project_id', isEqualTo: projectId)
          .where('user_id', isEqualTo: userId)
          .get();
      expect(snapshot.docs.length, 1);

      final loggedData = snapshot.docs.first.data();
      expect(loggedData['drawings'][0]['title'], newItem.title);
      expect(loggedData['drawings'][1]['title'], 'Old Title');
    });

    test('getRecentDrawings returns an empty list when no logs are found', () async {
      // Arrange
      const projectId = 'project1';
      const userId = 'user1';

      // Act
      final stream = service.getRecentDrawings(projectId: projectId, userId: userId);
      final result = await stream.first;

      // Assert
      expect(result, isEmpty);
    });

    test('getRecentDrawings returns correct data when logs are found', () async {
      // Arrange
      const projectId = 'project1';
      const userId = 'user1';

      // Create and add a drawing log
      const newItem = DrawingViewLogItem(
        title: 'Title 1',
        subTitle: 'Subtitle 1',
        url: 'http://example.com/image1',
      );

      final log = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [newItem],
      );

      await mockFirestore.collection('home_screens').add(log.toMap());

      // Act
      final stream = service.getRecentDrawings(projectId: projectId, userId: userId);
      final result = await stream.first;

      // Assert
      expect(result, isNotEmpty);
      expect(result.first.projectId, projectId);
      expect(result.first.userId, userId);
      expect(result.first.drawings.first.title, newItem.title);
    });

    test('getRecentDrawings returns multiple documents correctly', () async {
      // Arrange
      const projectId = 'project1';
      const userId = 'user1';

      // Create and add multiple drawing logs
      const newItem1 = DrawingViewLogItem(
        title: 'Title 1',
        subTitle: 'Subtitle 1',
        url: 'http://example.com/image1',
      );
      const newItem2 = DrawingViewLogItem(
        title: 'Title 2',
        subTitle: 'Subtitle 2',
        url: 'http://example.com/image2',
      );

      final log1 = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [newItem1],
      );
      final log2 = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [newItem2],
      );

      await mockFirestore.collection('home_screens').add(log1.toMap());
      await mockFirestore.collection('home_screens').add(log2.toMap());

      // Act
      final stream = service.getRecentDrawings(projectId: projectId, userId: userId);
      final result = await stream.first;

      // Assert
      expect(result.length, 2);
      expect(result[0].drawings.first.title, newItem1.title);
      expect(result[1].drawings.first.title, newItem2.title);
    });

    test('getRecentDrawings emits updates when data changes', () async {
      // Arrange
      const projectId = 'project1';
      const userId = 'user1';

      // Create and add a drawing log
      const newItem = DrawingViewLogItem(
        title: 'Title 1',
        subTitle: 'Subtitle 1',
        url: 'http://example.com/image1',
      );

      final log = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [newItem],
      );

      final logRef = await mockFirestore.collection('home_screens').add(log.toMap());

      // Act
      final stream = service.getRecentDrawings(projectId: projectId, userId: userId);
      final initialResult = await stream.first;

      // Assert initial result
      expect(initialResult.isNotEmpty, true);
      expect(initialResult.first.drawings.first.title, newItem.title);

      // Update the drawing log
      const updatedItem = DrawingViewLogItem(
        title: 'Updated Title',
        subTitle: 'Updated Subtitle',
        url: 'http://example.com/updated_image',
      );

      await mockFirestore.collection('home_screens').doc(logRef.id).update({
        'drawings': [updatedItem.toMap()],
      });

      // Wait for the stream to emit updated data
      final updatedResult = await stream.first;

      // Assert updated result
      expect(updatedResult.first.drawings.first.title, updatedItem.title);
    });
  });
}
