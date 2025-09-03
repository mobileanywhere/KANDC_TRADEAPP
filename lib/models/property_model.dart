class PropertyModel {
  List<PropertyData>? data;

  PropertyModel({this.data});

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      data: json['data'] != null
          ? List<PropertyData>.from(json['data'].map((propertyData) =>
              PropertyData.fromJson(propertyData as Map<String, dynamic>)))
          : null,
    );
  }
}

class PropertyData {
  int? id;
  int? userId;
  String? name;
  String? address;
  String? squareFootage;
  int? stateId;
  int? cityId;
  String? zipCode;
  String? bedrooms;
  String? levels;
  int? pool;
  String? gateCode;
  int? isDogs;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;

  PropertyData({
    this.id,
    this.userId,
    this.name,
    this.address,
    this.squareFootage,
    this.stateId,
    this.cityId,
    this.zipCode,
    this.bedrooms,
    this.levels,
    this.pool,
    this.gateCode,
    this.isDogs,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory PropertyData.fromJson(Map<String, dynamic> json) {
    return PropertyData(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      address: json['address'],
      squareFootage: json['size'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      zipCode: json['zip_code'],
      bedrooms: json['bedrooms'],
      levels: json['levels'],
      pool: json['pool'],
      gateCode: json['gate_code'],
      isDogs: json['is_dogs'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
