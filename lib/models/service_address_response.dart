import 'package:trade/models/pagination_model.dart';

class ServiceAddressesResponse {
  Pagination? pagination;
  List<AddressResponse>? addressResponse;

  ServiceAddressesResponse({this.pagination, this.addressResponse});

  ServiceAddressesResponse.fromJson(Map<String, dynamic> json) {
    pagination = json['pagination'] != null ? Pagination.fromJson(json['pagination']) : null;
    if (json['data'] != null) {
      addressResponse = [];
      json['data'].forEach((v) {
        addressResponse!.add(AddressResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    if (addressResponse != null) {
      data['data'] = addressResponse!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AddressResponse {
  int? id;
  int? providerId;
  String? latitude;
  String? longitude;
  int? status;
  String? address;
  String? providerName;
  bool? isSelected;

  AddressResponse({this.id, this.providerId, this.latitude, this.longitude, this.status, this.address, this.providerName, this.isSelected});

  AddressResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    address = json['address'];
    providerName = json['provider_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['address'] = address;
    data['provider_name'] = providerName;
    return data;
  }
}
