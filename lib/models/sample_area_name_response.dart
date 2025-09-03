class SampleAreaNameResponse {
  int? areaId;
  int? id;
  String? name;

  SampleAreaNameResponse({this.areaId, this.id, this.name});

  factory SampleAreaNameResponse.fromJson(Map<String, dynamic> json) {
    return SampleAreaNameResponse(
      areaId: json['area_id'],
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['area_id'] = areaId;
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
