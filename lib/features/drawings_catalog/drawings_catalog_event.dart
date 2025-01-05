import 'package:ardennes/models/drawings/drawings_catalog_data.dart';
import 'package:ardennes/models/projects/project_metadata.dart';

sealed class DrawingsCatalogEvent {}

class InitEvent extends DrawingsCatalogEvent {}

class FetchDrawingsCatalogEvent extends DrawingsCatalogEvent {
  final ProjectMetadata selectedProject;
  FetchDrawingsCatalogEvent(this.selectedProject);
}

class UpdateSelectedVersionEvent extends DrawingsCatalogEvent {
  final DrawingVersion? selectedVersion;
  UpdateSelectedVersionEvent(this.selectedVersion);
}

class UpdateSelectedCollectionEvent extends DrawingsCatalogEvent {
  final DrawingCollection? selectedCollection;
  UpdateSelectedCollectionEvent(this.selectedCollection);
}

class UpdateSelectedDisciplineEvent extends DrawingsCatalogEvent {
  final DrawingDiscipline? selectedDiscipline;
  UpdateSelectedDisciplineEvent(this.selectedDiscipline);
}

class UpdateSelectedTagEvent extends DrawingsCatalogEvent {
  final DrawingTag? selectedTag;
  UpdateSelectedTagEvent(this.selectedTag);
}

class SearchDrawingsCatalogEvent extends DrawingsCatalogEvent {
  final String searchQuery;
  SearchDrawingsCatalogEvent(this.searchQuery);
}
