import 'package:trade/models/booking_list_response.dart';

class InvoiceDataModel {
  String? message;
  List<InvoiceLineItemData>? lineitemData;
  InvoiceBookingData? bookingData;

  InvoiceDataModel({this.message, this.lineitemData, this.bookingData});

  factory InvoiceDataModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDataModel(
      message: json['message'],
      lineitemData: json['lineitem_data'] != null
          ? (json['lineitem_data'] as List)
              .map((item) => InvoiceLineItemData.fromJson(item))
              .toList()
          : null,
      bookingData: json['booking_data'] != null
          ? InvoiceBookingData.fromJson(json['booking_data'])
          : null,
    );
  }
}

class InvoiceLineItemData {
  int? customerId;
  int? bookingId;
  int? lineItemId;
  String? lineItemName;
  int? lineItemQty;
  String? lineItemPrice;
  int? subTotal;

  InvoiceLineItemData({
    this.customerId,
    this.bookingId,
    this.lineItemId,
    this.lineItemName,
    this.lineItemQty,
    this.lineItemPrice,
    this.subTotal,
  });

  factory InvoiceLineItemData.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItemData(
      customerId: json['customer_id'],
      bookingId: json['booking_id'],
      lineItemId: json['line_item_id'],
      lineItemName: json['line_item_name'],
      lineItemQty: json['line_item_qty'],
      lineItemPrice: json['line_item_price'],
      subTotal: json['sub_total'],
    );
  }
}

class InvoiceBookingData {
  int? customerId;
  BookingData? booking;
  Payment? payment;
  Service? service;

  InvoiceBookingData({
    this.customerId,
    this.booking,
    this.payment,
    this.service,
  });

  factory InvoiceBookingData.fromJson(Map<String, dynamic> json) {
    return InvoiceBookingData(
      customerId: json['customer_id'],
      booking:
          json['booking'] != null ? BookingData.fromJson(json['booking']) : null,
      payment:
          json['payment'] != null ? Payment.fromJson(json['payment']) : null,
      service:
          json['service'] != null ? Service.fromJson(json['service']) : null,
    );
  }
}

// class Booking {
//   int? id;
//   int? customerId;
//   int? serviceId;
//   int? providerId;
//   int? propertyId;
//   dynamic planId;
//   String? date;
//   String? startAt;
//   String? endAt;
//   int? quantity;
//   int? amount;
//   dynamic discount;
//   int? totalAmount;
//   dynamic description;
//   dynamic reason;
//   dynamic couponId;
//   String? status;
//   dynamic address;
//   int? paymentId;
//   String? durationDiff;
//   dynamic deletedAt;
//   String? createdAt;
//   String? updatedAt;
//   dynamic bookingAddressId;
//   dynamic tax;
//   String? type;
//   dynamic postRequestId;
//   dynamic bookingSlot;
//   dynamic bookingDay;
//   dynamic bookingPackage;
//   dynamic advancePaidAmount;
//   int? finalTotalServicePrice;
//   int? finalTotalTax;
//   int? finalSubTotal;
//   int? finalDiscountAmount;
//   int? finalCouponDiscountAmount;
//   dynamic typeId;
//   dynamic subtypeId;
//   dynamic categoryId;
//   dynamic subcategoryId;
//   dynamic userTrade;

//   Booking({
//     this.id,
//     this.customerId,
//     this.serviceId,
//     this.providerId,
//     this.propertyId,
//     this.planId,
//     this.date,
//     this.startAt,
//     this.endAt,
//     this.quantity,
//     this.amount,
//     this.discount,
//     this.totalAmount,
//     this.description,
//     this.reason,
//     this.couponId,
//     this.status,
//     this.address,
//     this.paymentId,
//     this.durationDiff,
//     this.deletedAt,
//     this.createdAt,
//     this.updatedAt,
//     this.bookingAddressId,
//     this.tax,
//     this.type,
//     this.postRequestId,
//     this.bookingSlot,
//     this.bookingDay,
//     this.bookingPackage,
//     this.advancePaidAmount,
//     this.finalTotalServicePrice,
//     this.finalTotalTax,
//     this.finalSubTotal,
//     this.finalDiscountAmount,
//     this.finalCouponDiscountAmount,
//     this.typeId,
//     this.subtypeId,
//     this.categoryId,
//     this.subcategoryId,
//     this.userTrade,
//   });

//   factory Booking.fromJson(Map<String, dynamic> json) {
//     return Booking(
//       id: json['id'],
//       customerId: json['customer_id'],
//       serviceId: json['service_id'],
//       providerId: json['provider_id'],
//       propertyId: json['property_id'],
//       planId: json['plan_id'],
//       date: json['date'],
//       startAt: json['start_at'],
//       endAt: json['end_at'],
//       quantity: json['quantity'],
//       amount: json['amount'],
//       discount: json['discount'],
//       totalAmount: json['total_amount'],
//       description: json['description'],
//       reason: json['reason'],
//       couponId: json['coupon_id'],
//       status: json['status'],
//       address: json['address'],
//       paymentId: json['payment_id'],
//       durationDiff: json['duration_diff'],
//       deletedAt: json['deleted_at'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       bookingAddressId: json['booking_address_id'],
//       tax: json['tax'],
//       type: json['type'],
//       postRequestId: json['post_request_id'],
//       bookingSlot: json['booking_slot'],
//       bookingDay: json['booking_day'],
//       bookingPackage: json['booking_package'],
//       advancePaidAmount: json['advance_paid_amount'],
//       finalTotalServicePrice: json['final_total_service_price'],
//       finalTotalTax: json['final_total_tax'],
//       finalSubTotal: json['final_sub_total'],
//       finalDiscountAmount: json['final_discount_amount'],
//       finalCouponDiscountAmount: json['final_coupon_discount_amount'],
//       typeId: json['type_id'],
//       subtypeId: json['subtype_id'],
//       categoryId: json['category_id'],
//       subcategoryId: json['subcategory_id'],
//       userTrade: json['user_trade'],
//     );
//   }
// }

class Service {
  int? id;
  String? name;
  int? categoryId;
  int? providerId;
  int? price;
  String? type;
  String? duration;
  int? discount;
  int? status;
  String? description;
  int? isFeatured;
  int? addedBy;
  dynamic deletedAt;
  String? createdAt;
  String? updatedAt;
  int? subcategoryId;
  String? serviceType;
  int? isSlot;
  int? isEnableAdvancePayment;
  double? advancePaymentAmount;

  Service({
    this.id,
    this.name,
    this.categoryId,
    this.providerId,
    this.price,
    this.type,
    this.duration,
    this.discount,
    this.status,
    this.description,
    this.isFeatured,
    this.addedBy,
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.subcategoryId,
    this.serviceType,
    this.isSlot,
    this.isEnableAdvancePayment,
    this.advancePaymentAmount,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      providerId: json['provider_id'],
      price: json['price'],
      type: json['type'],
      duration: json['duration'],
      discount: json['discount'],
      status: json['status'],
      description: json['description'],
      isFeatured: json['is_featured'],
      addedBy: json['added_by'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      subcategoryId: json['subcategory_id'],
      serviceType: json['service_type'],
      isSlot: json['is_slot'],
      isEnableAdvancePayment: json['is_enable_advance_payment'],
      advancePaymentAmount: json['advance_payment_amount'],
    );
  }
}

class Payment {
  int? id;
  int? customerId;
  int? bookingId;
  String? datetime;
  int? discount;
  double? totalAmount;
  String? paymentType;
  String? txnId;
  String? paymentStatus;
  dynamic otherTransactionDetail;
  String? createdAt;
  String? updatedAt;
  dynamic deletedAt;

  Payment({
    this.id,
    this.customerId,
    this.bookingId,
    this.datetime,
    this.discount,
    this.totalAmount,
    this.paymentType,
    this.txnId,
    this.paymentStatus,
    this.otherTransactionDetail,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      customerId: json['customer_id'],
      bookingId: json['booking_id'],
      datetime: json['datetime'],
      discount: json['discount'],
      totalAmount: (json['total_amount'] as num).toDouble(),
      paymentType: json['payment_type'],
      txnId: json['txn_id'],
      paymentStatus: json['payment_status'],
      otherTransactionDetail: json['other_transaction_detail'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}
