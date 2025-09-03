class InspectionAreasModel {
  List<AreaData?>? data;

  InspectionAreasModel({required this.data});

  factory InspectionAreasModel.fromJson(Map<String, dynamic> json) {
    return InspectionAreasModel(
      data: (json['data'] as List?)
          ?.map((areaData) => AreaData.fromJson(areaData))
          .toList(),
    );
  }
}

class AreaData {
  int? id;
  String? name;
  int? floorType;
  String? size;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  AreaData({
    required this.id,
    required this.name,
    required this.floorType,
    required this.size,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory AreaData.fromJson(Map<String, dynamic>? json) {
    return AreaData(
      id: json?['id'],
      name: json?['name'],
      floorType: json?['floor_type'],
      size: json?['size'],
      description: json?['description'],
      createdAt: json?['created_at'],
      updatedAt: json?['updated_at'],
      deletedAt: json?['deleted_at'],
    );
  }
}
