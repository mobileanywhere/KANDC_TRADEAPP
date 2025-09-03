import 'package:trade/models/user_data.dart';

class UserUpdateResponse {
  UserData? data;
  String? message;

  UserUpdateResponse({this.data, this.message});

  UserUpdateResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? UserData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}
