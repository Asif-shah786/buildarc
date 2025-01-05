//
// final user1 = <String, dynamic>{
//   "id": "NiYpNa0jt9EXooTcLRRv7qGMJLpd",
//   "company_id": "3ndmjoe8yhfhn2",
//   "projects": [
//     {"project_id": "dkm87fh3fdh30j", "project_name": "I-275 Reconstruction"},
//     {"project_id": "d8j3h8d7h3d8h", "project_name": "I-696 Reconstruction"}
//   ]
// };
//
import 'package:cloud_firestore/cloud_firestore.dart';

void populateHomeScreens() {
  final users = FirebaseFirestore.instance.collection("home_screens");
  for (final homeScreen in [fakeRecentlyViewedDrawingsOfProject1, fakeRecentlyViewedDrawingsOfProject2]) {
    users.doc("project_${homeScreen["project_id"]}_user_${homeScreen["user_id"]}").set(homeScreen);
  }
}

const String _project1Id = "dkm87fh3fdh30j";
const String _project2Id = "d8j3h8d7h3d8h";
const String _companyId = "3ndmjoe8yhfhn2";
const String _userId = "NiYpNa0jt9EXooTcLRRv7qGMJLpd";

final fakeRecentlyViewedDrawingsOfProject1 = <String, dynamic>{
  "project_id": _project1Id,
  "user_id": _userId,
  "drawings": List.generate(
      3,
      (index) => {
            "title": "A10$index",
            "subtitle": "FACTORY FLOOR P",
            "drawingThumbnailUrl": "drawing_images/$_companyId/$_project1Id/recently_viewed_drawings_${index + 1}.jpg"
          }),
};

final fakeRecentlyViewedDrawingsOfProject2 = <String, dynamic>{
  "project_id": _project2Id,
  "user_id": _userId,
  "drawings": List.generate(
      2,
      (index) => {
            "title": "A10${index + 3}",
            "subtitle": "OFFICE FLOOR PLAN",
            "drawingThumbnailUrl": "drawing_images/$_companyId/$_project2Id/recently_viewed_drawings_${index + 4}.jpg"
          }),
};
