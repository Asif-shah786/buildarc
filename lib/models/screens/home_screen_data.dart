import 'package:cloud_firestore/cloud_firestore.dart';

class RecentlyViewedDrawingTile {
  final String title;
  final String subtitle;
  final String drawingThumbnailUrl;

  RecentlyViewedDrawingTile({
    required this.title,
    required this.subtitle,
    required this.drawingThumbnailUrl,
  });
}

class HomeScreenData {
  HomeScreenData({this.drawings});

  final List<RecentlyViewedDrawingTile>? drawings;

  factory HomeScreenData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    return HomeScreenData(
      drawings: data?['drawings'] is Iterable
          ? List.from(data?['drawings'])
              .map((drawingMap) => RecentlyViewedDrawingTile(
                    title: drawingMap['title'] ?? '',
                    subtitle: drawingMap['subtitle'] ?? '',
                    drawingThumbnailUrl: drawingMap['drawingThumbnailUrl'] ?? '',
                  ))
              .toList()
          : null,
    );
  }

  static Map<String, Object?> toFirestore(Object? homeScreenData, SetOptions? options) {
    if (homeScreenData is HomeScreenData) {
      return {
        if (homeScreenData.drawings != null)
          "drawings": homeScreenData.drawings
              ?.map((drawing) => {
                    "title": drawing.title,
                    "subtitle": drawing.subtitle,
                    "drawingThumbnailUrl": drawing.drawingThumbnailUrl,
                  })
              .toList(),
      };
    } else {
      throw ArgumentError("homeScreenData is not an instance of HomeScreenData");
    }
  }
}
