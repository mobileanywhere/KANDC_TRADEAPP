import 'package:trade/models/Package_response.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/models/service_detail_response.dart';
import 'package:trade/provider/timeSlots/models/slot_data.dart';
import 'package:trade/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/model_keys.dart';

class ServiceData {
  int? id;
  String? name;
  int? categoryId;
  int? subCategoryId;
  int? providerId;
  num? price;
  var priceFormat;
  String? type;
  num? discount;
  String? duration;
  int? status;
  String? description;
  int? isFeatured;
  String? providerName;
  String? providerImage;
  int? cityId;
  String? categoryName;
  List<String>? imageAttachments;
  List<Attachments>? attchments;
  num? totalReview;
  num? totalRating;
  int? isFavourite;
  List<ServiceAddressMapping>? serviceAddressMapping;

  //Set Values
  num? totalAmount;
  num? discountPrice;
  num? taxAmount;
  num? couponDiscountAmount;
  String? dateTimeVal;
  String? couponId;
  num? qty;
  String? address;
  int? bookingAddressId;
  CouponData? appliedCouponData;
  num? isSlot;
  List<SlotData>? providerSlotData;
  List<PackageData>? servicePackage;
  num? advancePaymentSetting;
  num? isEnableAdvancePayment;
  num? advancePaymentAmount;
  num? advancePaymentPercentage;

  //Local
  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isFreeService => price.validate() == 0;

  bool get isAdvancePayment => isEnableAdvancePayment.validate() == 1;

  bool get isAdvancePaymentSetting => advancePaymentSetting.validate() == 1;

  String? subCategoryName;

  bool? isSelected;

  ServiceData({
    this.id,
    this.name,
    this.imageAttachments,
    this.providerSlotData,
    this.categoryId,
    this.providerId,
    this.price,
    this.priceFormat,
    this.type,
    this.discount,
    this.duration,
    this.status,
    this.isSlot,
    this.description,
    this.isFeatured,
    this.providerName,
    this.subCategoryId,
    this.providerImage,
    this.cityId,
    this.categoryName,
    this.attchments,
    this.totalReview,
    this.totalRating,
    this.isFavourite,
    this.serviceAddressMapping,
    this.totalAmount,
    this.discountPrice,
    this.taxAmount,
    this.couponDiscountAmount,
    this.dateTimeVal,
    this.couponId,
    this.subCategoryName,
    this.qty,
    this.address,
    this.bookingAddressId,
    this.appliedCouponData,
    this.isSelected,
    this.servicePackage,
    this.advancePaymentSetting,
    this.isEnableAdvancePayment,
    this.advancePaymentAmount,
    this.advancePaymentPercentage,
  });

  ServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    providerImage = json['provider_image'];
    categoryId = json['category_id'];
    subCategoryId = json['subcategory_id'];
    providerId = json['provider_id'];
    price = json['price'];
    priceFormat = json['price_format'];
    type = json['type'];
    discount = json['discount'];
    duration = json['duration'];
    status = json['status'];
    isSlot = json['is_slot'];
    description = json['description'];
    isFeatured = json['is_featured'];
    providerName = json['provider_name'];
    cityId = json['city_id'];
    categoryName = json['category_name'];
    //image_attchments = json['attchments'];
    imageAttachments = json['attchments'] != null ? List<String>.from(json['attchments']) : null;
    attchments = json['attchments_array'] != null ? (json['attchments_array'] as List).map((i) => Attachments.fromJson(i)).toList() : null;
    providerSlotData = json['slots'] != null ? (json['slots'] as List).map((i) => SlotData.fromJson(i)).toList() : null;
    subCategoryName = json['subcategory_name'];

    totalReview = json['total_review'];
    totalRating = json['total_rating'];
    isFavourite = json['is_favourite'];

    if (json['service_address_mapping'] != null) {
      serviceAddressMapping = [];
      json['service_address_mapping'].forEach((v) {
        serviceAddressMapping!.add(ServiceAddressMapping.fromJson(v));
      });
    }
    servicePackage = json['servicePackage'] != null ? (json['servicePackage'] as List).map((i) => PackageData.fromJson(i)).toList() : null;
    advancePaymentSetting = json[AdvancePaymentKey.advancePaymentSetting];
    isEnableAdvancePayment = json[AdvancePaymentKey.isEnableAdvancePayment];
    advancePaymentAmount = json[AdvancePaymentKey.advancePaymentAmount];
    advancePaymentPercentage = json[AdvancePaymentKey.advancePaymentAmount];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['provider_image'] = providerImage;
    data['category_id'] = categoryId;
    data['provider_id'] = providerId;
    data['is_slot'] = isSlot;
    data['price'] = price;
    data['price_format'] = priceFormat;
    data['type'] = type;
    data['discount'] = discount;
    data['duration'] = duration;
    data['status'] = status;
    data['description'] = description;
    data['is_featured'] = isFeatured;
    data['provider_name'] = providerName;
    data['city_id'] = cityId;
    data['subcategory_id'] = subCategoryId;
    data['subcategory_name'] = subCategoryName;

    data['category_name'] = categoryName;
    if (imageAttachments != null) {
      data['attchments'] = imageAttachments;
    }
    if (providerSlotData != null) {
      data['slots'] = providerSlotData;
    }
    if (servicePackage != null) {
      data['servicePackage'] = servicePackage!.map((v) => v.toJson()).toList();
    }
    data['total_review'] = totalReview;
    data['total_rating'] = totalRating;
    data['is_favourite'] = isFavourite;
    if (serviceAddressMapping != null) {
      data['service_address_mapping'] = serviceAddressMapping!.map((v) => v.toJson()).toList();
    }
    if (attchments != null) {
      data['attchments_array'] = attchments!.map((v) => v.toJson()).toList();
    }
    data[AdvancePaymentKey.advancePaymentSetting] = advancePaymentSetting;
    data[AdvancePaymentKey.isEnableAdvancePayment] = isEnableAdvancePayment;
    data[AdvancePaymentKey.advancePaymentAmount] = advancePaymentAmount;
    data[AdvancePaymentKey.advancePaymentAmount] = advancePaymentPercentage;
    return data;
  }
}
