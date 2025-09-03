class InspectionAttributeResponse {
  List<InspectionAttributeData>? data;

  InspectionAttributeResponse({
    required this.data,
  });

  factory InspectionAttributeResponse.fromJson(Map<String, dynamic> json) {
    List<dynamic>? dataList = json['data'];
    List<InspectionAttributeData>? inspectionData = dataList
        ?.map((data) => InspectionAttributeData.fromJson(data))
        .toList();

    return InspectionAttributeResponse(data: inspectionData ?? []);
  }
}

class InspectionAttributeData {
  String? tagName;
  List<InspectionAttributeValue>? value;

  InspectionAttributeData({
    required this.tagName,
    required this.value,
  });

  factory InspectionAttributeData.fromJson(Map<String, dynamic> json) {
    String? tagName = json['tag_name'];
    List<dynamic>? valueList = json['value'];
    List<InspectionAttributeValue>? attributeValue = valueList
        ?.map((value) => InspectionAttributeValue.fromJson(value))
        .toList();

    return InspectionAttributeData(
      tagName: tagName,
      value: attributeValue ?? [],
    );
  }
}

class InspectionAttributeValue {
  int? id;
  String? name;
  int? tagId;
  String? selectedOption;
  List<String>? options;
  InspectionTag? tag;

  InspectionAttributeValue({
    required this.id,
    required this.name,
    required this.tagId,
    required this.selectedOption,
    required this.options,
    required this.tag,
  });

  factory InspectionAttributeValue.fromJson(Map<String, dynamic> json) {
    return InspectionAttributeValue(
      id: json['id'],
      name: json['name'],
      tagId: json['tag_id'],
      selectedOption: json['selected_option'],
      options: List<String>.from(json['options']),
      tag: InspectionTag.fromJson(json['tag']),
    );
  }
}

class InspectionTag {
  int? id;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  InspectionTag({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.deletedAt,
  });

  factory InspectionTag.fromJson(Map<String, dynamic> json) {
    return InspectionTag(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
