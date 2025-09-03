class HouseInspectionModel {
  String? message;
  List<HouseInspectionData>? data;

  HouseInspectionModel({
    required this.message,
    this.data,
  });

  factory HouseInspectionModel.fromJson(Map<String, dynamic> json) {
    return HouseInspectionModel(
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => HouseInspectionData.fromJson(item))
          .toList(),
    );
  }
}

class HouseInspectionData {
  String? floor;
  List<HouseInspectionAreaData>? areaData;

  HouseInspectionData({
    required this.floor,
    this.areaData,
  });

  factory HouseInspectionData.fromJson(Map<String, dynamic> json) {
    return HouseInspectionData(
      floor: json['floor'] ?? '',
      areaData: (json['areaData'] as List?)
          ?.map((item) => HouseInspectionAreaData.fromJson(item))
          .toList(),
    );
  }
}

class HouseInspectionAreaData {
  String? area;
  int? houseareaId;
  List<HouseInspectionItemsData>? houseItems;
  List<HouseInspectionItemsData>? data;

  HouseInspectionAreaData({
    required this.area,
    this.houseareaId,
    this.houseItems,
    this.data,
  });

  factory HouseInspectionAreaData.fromJson(Map<String, dynamic> json) {
    return HouseInspectionAreaData(
      area: json['area'] ?? '',
      houseareaId: json['housearea_id'] ?? 0,
      houseItems: (json['houseitems'] as List?)
          ?.map((item) => HouseInspectionItemsData.fromJson(item))
          .toList(),
      data: (json['data'] as List?)
          ?.map((item) => HouseInspectionItemsData.fromJson(item))
          .toList(),
    );
  }
}

class HouseInspectionItemsData {
  String? item;
  String? size;
  String? description;
  int? houseareaId;

  HouseInspectionItemsData(
      {required this.item,
      this.houseareaId,
      this.size,
      required this.description});

  factory HouseInspectionItemsData.fromJson(Map<String, dynamic> json) {
    return HouseInspectionItemsData(
      item: json['item'] ?? '',
      size: json['size'] ?? '',
      description: json['description'] ?? '',
      houseareaId: json['housearea_id'] ?? 0,
    );
  }
}
