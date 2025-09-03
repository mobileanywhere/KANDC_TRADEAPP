import 'package:trade/models/Package_response.dart';
import 'package:trade/models/attachment_model.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/models/extra_charges_model.dart';
import 'package:trade/models/pagination_model.dart';
import 'package:trade/models/tax_list_response.dart';
import 'package:trade/models/user_data.dart';
import 'package:trade/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/model_keys.dart';

class BookingListResponse {
  List<BookingData>? data;
  Pagination? pagination;

  BookingListResponse({required this.data, required this.pagination});

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      data: json['data'] != null
          ? (json['data'] as List).map((i) => BookingData.fromJson(i)).toList()
          : null,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class BookingData {
  List<String>? attachments;
  int? id;
  String? address;
  int? customerId;
  int? serviceId;
  int? categoryId;
  int? subCategoryId;
  int? providerId;
  int? quantity;
  String? type;
  num? discount;
  num? amount;
  String? status;
  String? statusLabel;
  String? description;
  String? summary;
  String? bookingSlot;
  String? providerName;
  String? customerName;
  String? serviceName;
  String? paymentStatus;
  String? paymentMethod;
  String? date;
  String? durationDiff;
  int? paymentId;
  int? isInvoiceGenerated;
  int? bookingAddressId;
  List<TaxData>? taxes;
  num? totalAmount;
  num? paidAmount;

  String? durationDiffHour;
  List<Handyman>? handyman;
  List<String>? imageAttachments;
  List<Attachments>? serviceAttachments;
  CouponData? couponData;
  num? totalCalculatedPrice;

  int? totalReview;
  num? totalRating;
  int? isCancelled;
  String? reason;
  String? startAt;
  String? endAt;
  List<ExtraChargesModel>? extraCharges;
  String? bookingType;
  PackageData? bookingPackage;

  num? finalTotalServicePrice;
  num? finalTotalTax;
  num? finalSubTotal;
  num? finalDiscountAmount;
  num? finalCouponDiscountAmount;

  //Local
  double get totalAmountWithExtraCharges =>
      totalAmount.validate() +
      extraCharges
          .validate()
          .sumByDouble((e) => e.qty.validate() * e.price.validate());

  bool get isHourlyService => type.validate() == SERVICE_TYPE_HOURLY;

  bool get isFreeService => type.validate() == SERVICE_TYPE_FREE;

  bool get isPostJob => bookingType == BOOKING_TYPE_USER_POST_JOB;

  bool get isPackageBooking => bookingPackage != null;

  bool get isAdvancePaymentDone => paidAmount.validate() != 0;

  bool get isFixedService => type.validate() == SERVICE_TYPE_FIXED;

  bool get canCustomerContact =>
      status != BookingStatusKeys.pending &&
      status != BookingStatusKeys.cancelled &&
      status != BookingStatusKeys.failed &&
      status != BookingStatusKeys.rejected &&
      status != BookingStatusKeys.waitingAdvancedPayment;

  num get totalExtraChargeAmount =>
      extraCharges.validate().sumByDouble((e) => e.total.validate());

  BookingData({
    this.isInvoiceGenerated,
    this.attachments,
    this.address,
    this.imageAttachments,
    this.customerId,
    this.bookingSlot,
    this.customerName,
    this.date,
    this.description,
    this.summary,
    this.discount,
    this.amount,
    this.durationDiff,
    this.durationDiffHour,
    this.handyman,
    this.couponData,
    this.id,
    this.paymentId,
    this.paymentMethod,
    this.paymentStatus,
    this.providerId,
    this.providerName,
    //this.serviceAttachments,
    this.taxes,
    this.serviceId,
    this.categoryId,
    this.subCategoryId,
    this.serviceName,
    this.status,
    this.statusLabel,
    this.type,
    this.quantity,
    this.totalCalculatedPrice,
    this.bookingAddressId,
    this.totalAmount,
    this.totalReview,
    this.totalRating,
    this.isCancelled,
    this.reason,
    this.startAt,
    this.endAt,
    this.extraCharges,
    this.bookingType,
    this.bookingPackage,
    this.paidAmount,
    this.finalTotalServicePrice,
    this.finalTotalTax,
    this.finalSubTotal,
    this.finalDiscountAmount,
    this.finalCouponDiscountAmount,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      attachments: json['attchment'] != null
          ? List<String>.from(json['attchment'])
          : null,
      isInvoiceGenerated: json['is_invoice_generated']??0,
      address: json['address'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      date: json['date'] ?? '${DateTime.now()}',
      description: json['description'],
      summary: json['summary'],
      discount: json['discount'],
      amount: json['amount'],
      bookingSlot: json['booking_slot'],
      durationDiff: json['duration_diff'],
      durationDiffHour: json['duration_diff_hour'],
      handyman: json['handyman'] != null
          ? (json['handyman'] as List).map((i) => Handyman.fromJson(i)).toList()
          : [],
      id: json['id'],
      paymentId: json['payment_id'],
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'],
      providerId: json['provider_id'],
      providerName: json['provider_name'],
      // service_attchments: json['service_attchments'] != null ? (json['service_attchments'] as List).map((i) => Attachments.fromJson(i)).toList() : null,
      //  image_attchments :json['attchments'],
      imageAttachments: json['service_attchments'] != null
          ? List<String>.from(json['service_attchments'])
          : null,
      //service_attchments: json['service_attchments'] != null ? new List<String>.from(json['service_attchments']) : null,
      taxes: json['taxes'] != null
          ? (json['taxes'] as List).map((i) => TaxData.fromJson(i)).toList()
          : null,
      couponData: json['coupon_data'] != null
          ? CouponData.fromJson(json['coupon_data'])
          : null,
      serviceId: json['service_id'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      serviceName: json['service_name'],
      status: json['status'],
      statusLabel: json['status_label'],
      quantity: json['quantity'],
      type: json['type'],
      bookingAddressId: json['booking_address_id'],
      totalAmount: json['total_amount'],
      totalReview: json['total_review'],
      totalRating: json['total_rating'],
      isCancelled: json['is_cancelled'],
      reason: json['reason'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      extraCharges: json['extra_charges'] != null
          ? (json['extra_charges'] as List)
              .map((i) => ExtraChargesModel.fromJson(i))
              .toList()
          : null,
      bookingType: json['booking_type'],
      bookingPackage: json['booking_package'] != null
          ? PackageData.fromJson(json['booking_package'])
          : null,
      paidAmount: json[AdvancePaymentKey.advancePaidAmount],
      finalTotalServicePrice: json['final_total_service_price'],
      finalTotalTax: json['final_total_tax'],
      finalSubTotal: json['final_sub_total'],
      finalDiscountAmount: json['final_discount_amount'],
      finalCouponDiscountAmount: json['final_coupon_discount_amount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_invoice_generated'] = isInvoiceGenerated;
    data['customer_id'] = customerId;
    data['customer_name'] = customerName;
    data['date'] = date;
    data['discount'] = discount;
    data['amount'] = amount;
    data['duration_diff'] = durationDiff;
    data['id'] = id;
    data['booking_slot'] = bookingSlot;
    data['provider_id'] = providerId;
    data['provider_name'] = providerName;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['status'] = status;
    data['status_label'] = statusLabel;
    data['type'] = type;
    data['address'] = address;
    data['description'] = description;
    data['summary'] = summary;
    data['duration_diff_hour'] = durationDiffHour;
    data['handyman'] = handyman;
    data['payment_id'] = paymentId;
    data['payment_method'] = paymentMethod;
    data['payment_status'] = paymentStatus;
    // data['service_attchments'] = this.service_attchments;
    //  data['attchments'] = this.image_attchments;
    if (imageAttachments != null) {
      data['service_attchments'] = imageAttachments;
    }
    if (attachments != null) {
      data['attchment'] = attachments;
    }
    /* if (this.service_attchments != null) {
      data['service_attchments'] = this.service_attchments!.map((v) => v.toJson()).toList();
    }*/
    data['booking_address_id'] = bookingAddressId;
    data['quantity'] = quantity;
    if (taxes != null) {
      data['taxes'] = taxes!.map((v) => v.toJson()).toList();
    }
    if (couponData != null) {
      data['coupon_data'] = couponData!.toJson();
    }
    data['total_amount'] = totalAmount;
    data['total_review'] = totalReview;
    data['total_rating'] = totalRating;
    data['reason'] = reason;
    data['is_cancelled'] = isCancelled;
    data['start_at'] = startAt;
    data['end_at'] = endAt;
    if (extraCharges != null) {
      data['extra_charges'] =
          extraCharges!.map((v) => v.toJson()).toList();
    }
    data['booking_type'] = bookingType;
    data[AdvancePaymentKey.advancePaidAmount] = amount;
    if (bookingPackage != null) {
      data['booking_package'] = bookingPackage!.toJson();
    }
    data['final_total_service_price'] = finalTotalServicePrice;
    data['final_total_tax'] = finalTotalTax;
    data['final_sub_total'] = finalSubTotal;
    data['final_discount_amount'] = finalDiscountAmount;
    data['final_coupon_discount_amount'] = finalCouponDiscountAmount;
    return data;
  }
}

class Handyman {
  int? id;
  int? bookingId;
  int? handymanId;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  UserData? handyman;

  Handyman(
      {this.id,
      this.bookingId,
      this.handymanId,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.handyman});

  Handyman.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    handymanId = json['handyman_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    handyman = json['handyman'] != null
        ? UserData.fromJson(json['handyman'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['handyman_id'] = handymanId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    if (handyman != null) {
      data['handyman'] = handyman!.toJson();
    }
    return data;
  }
}
