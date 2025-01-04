import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../models/drawings/drawing_sheet_view_log.dart';

@Injectable()
class RecentDrawingService {
  RecentDrawingService();

  final firestore = FirebaseFirestore.instance;
  Stream<List<DrawingSheetViewLog>> getRecentDrawings({required String projectId, required String userId}) {
    final query = firestore
        .collection('home_screens')
        .where('project_id', isEqualTo: projectId)
        .where('user_id', isEqualTo: userId)
        .withConverter(
          fromFirestore: DrawingSheetViewLog.fromFirestore,
          toFirestore: DrawingSheetViewLog.toFirestore,
        );

    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<void> logDrawingView({
    required String projectId,
    required String userId,
    required DrawingViewLogItem newItem,
  }) async {
    final logCollection = firestore.collection('home_screens');
    final querySnapshot =
        await logCollection.where('project_id', isEqualTo: projectId).where('user_id', isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final log = DrawingSheetViewLog.fromMap(doc.data());
      log.drawings.remove(newItem);
      log.drawings.insert(0, newItem);

      await logCollection.doc(doc.id).update(log.toMap());
    } else {
      final newLog = DrawingSheetViewLog(
        projectId: projectId,
        userId: userId,
        drawings: [newItem],
      );

      await logCollection.add(newLog.toMap());
    }
  }
}
