import 'package:trade/models/pagination_model.dart';

class UserTypeResponse {
  List<UserTypeData>? userTypeData;
  Pagination? pagination;

  UserTypeResponse({this.userTypeData, this.pagination});

  factory UserTypeResponse.fromJson(Map<String, dynamic> json) {
    return UserTypeResponse(
      userTypeData: json['data'] != null ? (json['data'] as List).map((i) => UserTypeData.fromJson(i)).toList() : null,
      pagination: json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userTypeData != null) {
      data['data'] = userTypeData!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class UserTypeData {
  String? createdAt;
  int? id;
  String? name;
  String? updatedAt;

  UserTypeData({this.createdAt, this.id, this.name, this.updatedAt});

  factory UserTypeData.fromJson(Map<String, dynamic> json) {
    return UserTypeData(
      createdAt: json['created_at'],
      id: json['id'],
      name: json['name'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['created_at'] = createdAt;
    data['id'] = id;
    data['name'] = name;
    data['updated_at'] = updatedAt;
    return data;
  }
}
