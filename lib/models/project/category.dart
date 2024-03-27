import 'package:render_studio/models/cloud.dart';

class CategoryGroup {

  final String id;
  final String name;
  final List<String> tags;
  final List<ProjectCategory> types;

  static List<CategoryGroup>? _groups;

  CategoryGroup._({
    required this.id,
    required this.name,
    required this.tags,
    required this.types
  });

  factory CategoryGroup.fromJSON(Map<String, dynamic> json) {
    return CategoryGroup._(
      id: json['id'],
      name: json['category'],
      tags: List<String>.from(json['tags']),
      types: List<ProjectCategory>.from(json['types'].map((type) => ProjectCategory.fromJSON(type)))
    );
  }

  static Future<List<CategoryGroup>> getGroups() async {
    if (_groups != null) return _groups!;
    var response = await Cloud.get('template/categories');
    print(response.data);
    List raw_groups = response.data;
    _groups = raw_groups.map((group) => CategoryGroup.fromJSON(group)).toList();
    return _groups!;
  }

}

class ProjectCategory {

  final String id;
  final String name;
  final String description;

  ProjectCategory._({
    required this.id,
    required this.name,
    required this.description
  });

  factory ProjectCategory.fromJSON(Map<String, dynamic> json) {
    return ProjectCategory._(
      id: json['id'],
      name: json['title'],
      description: json['description']
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': name,
      'description': description
    };
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectCategory && other.id == id;
  }

}