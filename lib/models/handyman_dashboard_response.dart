import 'package:trade/main.dart';
import 'package:trade/models/booking_detail_response.dart';
import 'package:trade/models/booking_list_response.dart';
import 'package:trade/models/revenue_chart_data.dart';
import 'package:nb_utils/nb_utils.dart';

import 'dashboard_response.dart';

class HandymanDashBoardResponse {
  Commission? commission;

  List<RatingData>? handymanReviews;
  bool? status;
  num? todayBooking;
  num? totalBooking;
  num? totalRevenue;
  num? todayCashAmount;
  List<BookingData>? upcomingBookings;
  List<double>? chartArray;
  List<int>? monthData;
  int? isHandymanAvailable;
  int? completedBooking;

  List<LanguageOption>? languageOption;
  List<Configurations>? configurations;
  Configurations? privacyPolicy;
  Configurations? termConditions;

  AppDownload? appDownload;
  num? notificationUnreadCount;
  String? inquiryEmail;
  String? helplineNumber;

  HandymanDashBoardResponse({
    this.commission,
    this.handymanReviews,
    this.status,
    this.todayBooking,
    this.totalBooking,
    this.totalRevenue,
    this.upcomingBookings,
    this.todayCashAmount,
    this.chartArray,
    this.monthData,
    this.isHandymanAvailable,
    this.completedBooking,
    this.languageOption,
    this.configurations,
    this.privacyPolicy,
    this.termConditions,
    this.appDownload,
    this.notificationUnreadCount,
    this.inquiryEmail,
    this.helplineNumber,
  });

  HandymanDashBoardResponse.fromJson(Map<String, dynamic> json) {
    commission = json['commission'] != null ? Commission.fromJson(json['commission']) : null;
    handymanReviews = json['handyman_reviews'] != null ? (json['handyman_reviews'] as List).map((i) => RatingData.fromJson(i)).toList() : null;
    status = json['status'];
    todayBooking = json['today_booking'];
    todayCashAmount = json['today_cash'];
    totalBooking = json['total_booking'];
    totalRevenue = json['total_revenue'];
    upcomingBookings = json['upcomming_booking'] != null ? (json['upcomming_booking'] as List).map((i) => BookingData.fromJson(i)).toList() : null;

    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'July', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];
    isHandymanAvailable = json['isHandymanAvailable'];
    completedBooking = json['completed_booking'];

    chartArray = [];
    monthData = [];
    Iterable it = json['monthly_revenue']['revenueData'];

    it.forEachIndexed((element, index) {
      if ((element as Map).containsKey('${index + 1}')) {
        chartArray!.add(element[(index + 1).toString()].toString().toDouble());
        monthData!.add(index);
        chartData.add(RevenueChartData(month: months[index], revenue: element[(index + 1).toString()].toString().toDouble()));
      } else {
        chartData.add(RevenueChartData(month: months[index], revenue: 0));
      }
    });
    languageOption = json['language_option'] != null ? (json['language_option'] as List).map((i) => LanguageOption.fromJson(i)).toList() : null;
    configurations = json['configurations'] != null ? (json['configurations'] as List).map((i) => Configurations.fromJson(i)).toList() : null;
    privacyPolicy = json['privacy_policy'] != null ? Configurations.fromJson(json['privacy_policy']) : null;
    termConditions = json['term_conditions'] != null ? Configurations.fromJson(json['term_conditions']) : null;
    appDownload = json['app_download'] != null ? AppDownload.fromJson(json['app_download']) : null;

    notificationUnreadCount = json['notification_unread_count'];

    inquiryEmail = json['inquriy_email'];

    helplineNumber = json['helpline_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['today_booking'] = todayBooking;
    data['total_booking'] = totalBooking;
    data['total_booking'] = totalBooking;
    data['completed_booking'] = completedBooking;

    if (upcomingBookings != null) {
      data['upcomming_booking'] = upcomingBookings!.map((v) => v.toJson()).toList();
    }
    if (commission != null) {
      data['commission'] = commission!.toJson();
    }

    if (handymanReviews != null) {
      data['handyman_reviews'] = handymanReviews!.map((v) => v.toJson()).toList();
    }

    data['isHandymanAvailable'] = isHandymanAvailable;
    if (languageOption != null) {
      data['language_option'] = languageOption!.map((v) => v.toJson()).toList();
    }

    if (configurations != null) {
      data['configurations'] = configurations!.map((v) => v.toJson()).toList();
    }
    if (privacyPolicy != null) {
      data['privacy_policy'] = privacyPolicy;
    }
    if (termConditions != null) {
      data['term_conditions'] = termConditions;
    }
    if (appDownload != null) {
      data['app_download'] = appDownload;
    }
    data['notification_unread_count'] = notificationUnreadCount;

    data['inquriy_email'] = inquiryEmail;

    data['helpline_number'] = helplineNumber;
    data['today_cash'] = todayCashAmount;

    return data;
  }
}

class Commission {
  int? commission;
  String? createdAt;
  String? deletedAt;
  int? id;
  String? name;
  int? status;
  String? type;
  String? updatedAt;

  Commission({this.commission, this.createdAt, this.deletedAt, this.id, this.name, this.status, this.type, this.updatedAt});

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      commission: json['commission'],
      createdAt: json['created_at'],
      deletedAt: json['deleted_at'],
      id: json['id'],
      name: json['name'],
      status: json['status'],
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commission'] = commission;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['type'] = type;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    return data;
  }
}

class Configurations {
  Country? country;
  int? id;
  String? key;
  String? type;
  String? value;

  Configurations({this.country, this.id, this.key, this.type, this.value});

  factory Configurations.fromJson(Map<String, dynamic> json) {
    return Configurations(
      country: json['country'] != null ? Country.fromJson(json['country']) : null,
      id: json['id'],
      key: json['key'],
      type: json['type'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['key'] = key;
    data['type'] = type;
    if (country != null) {
      data['country'] = country!.toJson();
    }
    if (value != null) {
      data['value'] = value;
    }
    return data;
  }
}

class Country {
  int? id;
  String? code;
  String? name;
  int? dialCode;
  String? currencyName;
  String? symbol;
  String? currencyCode;

  Country({this.id, this.code, this.name, this.dialCode, this.currencyName, this.symbol, this.currencyCode});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    name = json['name'];
    dialCode = json['dial_code'];
    currencyName = json['currency_name'];
    symbol = json['symbol'];
    currencyCode = json['currency_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['name'] = name;
    data['dial_code'] = dialCode;
    data['currency_name'] = currencyName;
    data['symbol'] = symbol;
    data['currency_code'] = currencyCode;
    return data;
  }
}

class AppDownload {
  String? appstoreUrl;
  String? createdAt;
  String? description;
  int? id;
  String? playStoreUrl;
  String? providerAppstoreUrl;
  String? providerPlayStoreUrl;
  String? title;
  String? updatedAt;

  AppDownload({
    this.appstoreUrl,
    this.createdAt,
    this.description,
    this.id,
    this.playStoreUrl,
    this.providerAppstoreUrl,
    this.providerPlayStoreUrl,
    this.title,
    this.updatedAt,
  });

  factory AppDownload.fromJson(Map<String, dynamic> json) {
    return AppDownload(
      appstoreUrl: json['appstore_url'],
      createdAt: json['created_at'],
      description: json['description'],
      id: json['id'],
      playStoreUrl: json['playstore_url'],
      providerAppstoreUrl: json['provider_appstore_url'],
      providerPlayStoreUrl: json['provider_playstore_url'],
      title: json['title'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appstore_url'] = appstoreUrl;
    data['created_at'] = createdAt;
    data['description'] = description;
    data['id'] = id;
    data['playstore_url'] = playStoreUrl;
    data['provider_appstore_url'] = providerAppstoreUrl;
    data['provider_playstore_url'] = providerPlayStoreUrl;
    data['title'] = title;
    data['updated_at'] = updatedAt;
    return data;
  }
}
