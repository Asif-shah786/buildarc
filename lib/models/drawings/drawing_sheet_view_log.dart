import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DrawingSheetViewLog extends Equatable {
  final String projectId;
  final String userId;
  final List<DrawingViewLogItem> drawings;

  const DrawingSheetViewLog({
    required this.projectId,
    required this.userId,
    required this.drawings,
  });

  factory DrawingSheetViewLog.fromMap(Map<String, dynamic> map) {
    return DrawingSheetViewLog(
      projectId: map['project_id'] ?? '',
      userId: map['user_id'] ?? '',
      drawings: List<DrawingViewLogItem>.from(
        map['drawings']?.map((item) => DrawingViewLogItem.fromMap(item)) ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'user_id': userId,
      'drawings': drawings.map((item) => item.toMap()).toList(),
    };
  }

  // From Firestore
  factory DrawingSheetViewLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return DrawingSheetViewLog(
      projectId: data?['project_id'] ?? '',
      userId: data?['user_id'] ?? '',
      drawings: List<DrawingViewLogItem>.from(
        (data?['drawings'] as List?)?.map((item) => DrawingViewLogItem.fromMap(item)) ?? [],
      ),
    );
  }

  // To Firestore
  static Map<String, dynamic> toFirestore(
    DrawingSheetViewLog log,
    SetOptions? options,
  ) {
    return {
      'project_id': log.projectId,
      'user_id': log.userId,
      'drawings': log.drawings.map((item) => item.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [projectId, userId, drawings];
}

class DrawingViewLogItem extends Equatable {
  final String title;
  final String subTitle;
  final String url;

  const DrawingViewLogItem({
    required this.title,
    required this.subTitle,
    required this.url,
  });

  factory DrawingViewLogItem.fromMap(Map<String, dynamic> map) {
    return DrawingViewLogItem(
      title: map['title'] ?? '',
      subTitle: map['subtitle'] ?? '',
      url: map['drawingThumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subTitle,
      'drawingThumbnailUrl': url,
    };
  }

  @override
  List<Object?> get props => [title, subTitle, url];
}
