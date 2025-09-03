import 'package:trade/main.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/booking_list_response.dart';
import 'package:trade/models/service_model.dart';
import 'package:trade/models/tax_list_response.dart';
import 'package:trade/models/user_data.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/jobRequest/models/post_job_data.dart';

class BookingDetailResponse {
  BookingData? bookingDetail;
  ServiceData? service;
  UserData? customer;
  List<BookingActivity>? bookingActivity;
  List<RatingData>? ratingData;
  UserData? providerData;
  List<UserData>? handymanData;
  CouponData? couponData;
  List<TaxData>? taxes;
  List<ServiceProof>? serviceProof;
  PostJobData? postRequestDetail;

  bool get isMe => handymanData.validate().isNotEmpty ? handymanData.validate().first.id.validate() == appStore.userId.validate() : false;

  BookingDetailResponse({
    this.bookingDetail,
    this.service,
    this.customer,
    this.bookingActivity,
    this.ratingData,
    this.providerData,
    this.handymanData,
    this.couponData,
    this.taxes,
    this.serviceProof,
    this.postRequestDetail,
  });

  BookingDetailResponse.fromJson(Map<String, dynamic> json) {
    bookingDetail = json['booking_detail'] != null ? BookingData.fromJson(json['booking_detail']) : null;
    service = json['service'] != null ? ServiceData.fromJson(json['service']) : null;
    customer = json['customer'] != null ? UserData.fromJson(json['customer']) : null;
    if (json['booking_activity'] != null) {
      bookingActivity = [];
      json['booking_activity'].forEach((v) {
        bookingActivity!.add(BookingActivity.fromJson(v));
      });
    }
    providerData = json['provider_data'] != null ? UserData.fromJson(json['provider_data']) : null;
    if (json['rating_data'] != null) {
      ratingData = [];
      json['rating_data'].forEach((v) {
        ratingData!.add(RatingData.fromJson(v));
      });
    }
    couponData = json['coupon_data'] != null ? CouponData.fromJson(json['coupon_data']) : null;

    if (json['handyman_data'] != null) {
      handymanData = [];
      json['handyman_data'].forEach((v) {
        handymanData!.add(UserData.fromJson(v));
      });
    }
    if (json['service_proof'] != null) {
      serviceProof = [];
      json['service_proof'].forEach((v) {
        serviceProof!.add(ServiceProof.fromJson(v));
      });
    }
    postRequestDetail = json['post_request_detail'] != null ? PostJobData.fromJson(json['post_request_detail']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bookingDetail != null) {
      data['booking_detail'] = bookingDetail!.toJson();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (bookingActivity != null) {
      data['booking_activity'] = bookingActivity!.map((v) => v.toJson()).toList();
    }
    if (ratingData != null) {
      data['rating_data'] = ratingData!.map((v) => v.toJson()).toList();
    }
    if (couponData != null) {
      data['coupon_data'] = couponData!.toJson();
    }
    if (providerData != null) {
      data['provider_data'] = providerData!.toJson();
    }
    if (handymanData != null) {
      data['handyman_data'] = handymanData!.map((v) => v.toJson()).toList();
    }
    if (serviceProof != null) {
      data['service_proof'] = serviceProof!.map((v) => v.toJson()).toList();
    }
    if (postRequestDetail != null) {
      data['post_request_detail'] = postRequestDetail?.toJson();
    }
    return data;
  }
}

class CouponData {
  int? bookingId;
  String? code;
  String? createdAt;
  String? deletedAt;
  int? discount;
  String? discountType;
  int? id;
  String? updatedAt;
  num? totalCalculatedValue;

  CouponData({this.bookingId, this.code, this.createdAt, this.deletedAt, this.discount, this.discountType, this.id, this.updatedAt, this.totalCalculatedValue});

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      bookingId: json['booking_id'],
      code: json['code'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      discount: json['discount'],
      discountType: json['discount_type'],
      id: json['id'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_id'] = bookingId;
    data['code'] = code;
    data['created_at'] = createdAt;
    data['discount'] = discount;
    data['deleted_at'] = deletedAt;
    data['discount_type'] = discountType;
    data['id'] = id;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BookingActivity {
  int? id;
  int? bookingId;
  String? datetime;
  String? activityType;
  String? activityMessage;
  String? activityData;
  String? createdAt;
  String? updatedAt;

  BookingActivity({this.id, this.bookingId, this.datetime, this.activityType, this.activityMessage, this.activityData, this.createdAt, this.updatedAt});

  BookingActivity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    datetime = json['datetime'];
    activityType = json['activity_type'];
    activityMessage = json['activity_message'];
    activityData = json['activity_data'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['datetime'] = datetime;
    data['activity_type'] = activityType;
    data['activity_message'] = activityMessage;
    data['activity_data'] = activityData;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class RatingData {
  num? id;
  num? rating;
  String? review;
  num? serviceId;
  num? bookingId;
  String? createdAt;
  String? customerName;
  String? profileImage;
  String? customerProfileImage;
  String? handymanProfileImage;

  String? serviceName;
  num? handymanId;
  num? customerId;
  String? handymanName;
  List<Attachments>? attachments;

  RatingData({
    this.id,
    this.rating,
    this.review,
    this.serviceId,
    this.bookingId,
    this.createdAt,
    this.customerName,
    this.profileImage,
    this.customerProfileImage,
    this.handymanProfileImage,
    this.serviceName,
    this.handymanId,
    this.customerId,
    this.handymanName,
    this.attachments,
  });

  RatingData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = json['rating'];
    review = json['review'];
    serviceId = json['service_id'];
    bookingId = json['booking_id'];
    createdAt = json['created_at'];
    customerName = json['customer_name'];
    profileImage = json['profile_image'];
    customerProfileImage = json['customer_profile_image'];
    handymanProfileImage = json['handyman_profile_image'];
    serviceName = json['service_name'];
    handymanId = json['handyman_id'];
    customerId = json['customer_id'];
    handymanName = json['handyman_name'];
    attachments = json['attchments_array'] != null ? (json['attchments_array'] as List).map((i) => Attachments.fromJson(i)).toList() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rating'] = rating;
    data['review'] = review;
    data['service_id'] = serviceId;
    data['booking_id'] = bookingId;
    data['created_at'] = createdAt;
    data['customer_name'] = customerName;
    data['profile_image'] = profileImage;
    data['customer_profile_image'] = customerProfileImage;
    data['handyman_profile_image'] = handymanProfileImage;
    data['service_name'] = serviceName;
    data['handyman_id'] = handymanId;
    data['customer_id'] = customerId;
    data['handyman_name'] = handymanName;
    if (attachments != null) {
      data['attchments_array'] = attachments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceProof {
  int? id;
  String? title;
  String? description;
  int? serviceId;
  int? bookingId;
  int? userId;
  String? handymanName;
  String? serviceName;
  List<String>? attachments;

  ServiceProof({
    this.id,
    this.title,
    this.description,
    this.serviceId,
    this.bookingId,
    this.userId,
    this.handymanName,
    this.serviceName,
    this.attachments,
  });

  ServiceProof.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    serviceId = json['service_id'];
    bookingId = json['booking_id'];
    userId = json['user_id'];
    handymanName = json['handyman_name'];
    serviceName = json['service_name'];
    attachments = json['attachments'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['service_id'] = serviceId;
    data['booking_id'] = bookingId;
    data['user_id'] = userId;
    data['handyman_name'] = handymanName;
    data['service_name'] = serviceName;
    data['attachments'] = attachments;
    return data;
  }
}
