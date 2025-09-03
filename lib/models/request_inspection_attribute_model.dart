class RequestInspectionAttributes {
  List<RequestAttribute> attributes;

  RequestInspectionAttributes({required this.attributes});

  factory RequestInspectionAttributes.fromJson(List<dynamic> json) {
    List<RequestAttribute> attributesList = json.map((item) => RequestAttribute.fromJson(item)).toList();
    return RequestInspectionAttributes(attributes: attributesList);
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> attributesJson = attributes.map((attribute) => attribute.toJson()).toList();
    return {'inspection_attributes': attributesJson};
  }
}

class RequestAttribute {
  int attributeId;
  String value;

  RequestAttribute({required this.attributeId, required this.value});

  factory RequestAttribute.fromJson(Map<String, dynamic> json) {
    return RequestAttribute(
      attributeId: json['attribute_id'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'attribute_id': attributeId, 'value': value};
  }
}
