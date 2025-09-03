class InspectionAreaItemsModel {
  List<AreaItem?>? data;

  InspectionAreaItemsModel({required this.data});

  factory InspectionAreaItemsModel.fromJson(Map<String, dynamic> json) {
    return InspectionAreaItemsModel(
      data: (json['data'] as List?)
          ?.map((areaItem) => AreaItem.fromJson(areaItem))
          .toList(),
    );
  }
}

class AreaItem {
  int? id;
  String? name;
  String? size;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  AreaItem({
    required this.id,
    required this.name,
    required this.size,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory AreaItem.fromJson(Map<String, dynamic>? json) {
    return AreaItem(
      id: json?['id'],
      name: json?['name'],
      size: json?['size'],
      description: json?['description'],
      createdAt: json?['created_at'],
      updatedAt: json?['updated_at'],
      deletedAt: json?['deleted_at'],
    );
  }
}
