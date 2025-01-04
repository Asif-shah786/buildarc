import 'package:json_annotation/json_annotation.dart';
part 'project_metadata.g.dart';

@JsonSerializable()
class ProjectMetadata {
  final String? id;
  final String? name;

  ProjectMetadata({this.id, this.name});

  factory ProjectMetadata.fromMap(Map<String, dynamic> map) {
    return ProjectMetadata(
      id: map['project_id'] as String?,
      name: map['project_name'] as String?,
    );
  }

  // Json serialization
  factory ProjectMetadata.fromJson(Map<String, dynamic> json) => _$ProjectMetadataFromJson(json);
  Map<String, dynamic> toJson() => _$ProjectMetadataToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProjectMetadata && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
