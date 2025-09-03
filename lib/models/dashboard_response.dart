import 'package:trade/main.dart';
import 'package:trade/models/booking_list_response.dart';
import 'package:trade/models/service_model.dart';
import 'package:trade/models/user_data.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/jobRequest/models/post_job_data.dart';
import 'provider_subscription_model.dart';
import 'revenue_chart_data.dart';

class DashboardResponse {
  bool? status;
  int? totalBooking;
  int? totalService;
  num? todayCashAmount;
  int? totalHandyman;
  int? openRequests;
  List<ServiceData>? service;
  List<CategoryData>? category;
  List<UserData>? handyman;
  num? totalRevenue;
  int? inprogessInspection;
  List<double>? chartArray;
  List<int>? monthData;
  Commission? commission;
  String? earningType;
  int? totalInspections;
  int? openInspections;

  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'July',
    'Aug',
    'Sept',
    'Oct',
    'Nov',
    'Dec'
  ];

  int? isSubscribed;
  ProviderSubscriptionModel? subscription;

  //Local
  bool? isPlanAboutToExpire;
  bool? userNeverPurchasedPlan;
  bool? isPlanExpired;
  ProviderWallet? providerWallet;
  List<String>? onlineHandyman;
  List<PostJobData>? myPostJobData;
  List<BookingData>? upcomingBookings;

  List<LanguageOption>? languageOption;
  AppDownload? appDownload;
  num? notificationUnreadCount;
  String? isAdvancedPaymentAllowed;
  bool? enableUserWallet;
  Configurations? privacyPolicy;
  Configurations? termConditions;
  String? inquiryEmail;
  String? helplineNumber;
  List<Configurations>? configurations;

  DashboardResponse({
    this.chartArray,
    this.monthData,
    this.status,
    this.totalBooking,
    this.service,
    this.category,
    this.totalService,
    this.totalHandyman,
    this.handyman,
    this.totalRevenue,
    this.inprogessInspection,
    this.commission,
    this.providerWallet,
    this.onlineHandyman,
    this.myPostJobData,
    this.upcomingBookings,
    this.earningType,
    this.languageOption,
    this.privacyPolicy,
    this.termConditions,
    this.inquiryEmail,
    this.helplineNumber,
    this.notificationUnreadCount,
    this.appDownload,
    this.isAdvancedPaymentAllowed,
    this.enableUserWallet,
    this.todayCashAmount,
    this.configurations,
    this.openRequests,
    this.totalInspections,
    this.openInspections,
  });

  DashboardResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalBooking = json['total_booking'];
    totalRevenue = json['total_revenue'];
    inprogessInspection = json['inprogess_inspection'];
    totalService = json['total_service'];
    totalHandyman = json['total_handyman'];
    openRequests = json['open_requests'];
    todayCashAmount = json['today_cash'];
    totalInspections = json['total_inspections'];
    openInspections = json['open_inspections'];
    commission = json['commission'] != null
        ? Commission.fromJson(json['commission'])
        : null;
    if (json['service'] != null) {
      service = [];
      json['service'].forEach((v) {
        service!.add(ServiceData.fromJson(v));
      });
    }
    if (json['category'] != null) {
      category = [];
      json['category'].forEach((v) {
        category!.add(CategoryData.fromJson(v));
      });
    }
    if (json['handyman'] != null) {
      handyman = [];
      json['handyman'].forEach((v) {
        handyman!.add(UserData.fromJson(v));
      });
    }

    chartArray = [];
    monthData = [];
    Iterable it = json['monthly_revenue']['revenueData'];

    it.forEachIndexed((element, index) {
      if ((element as Map).containsKey('${index + 1}')) {
        chartArray!.add(element[(index + 1).toString()].toString().toDouble());
        monthData!.add(index);
        chartData.add(RevenueChartData(
            month: months[index],
            revenue: element[(index + 1).toString()].toString().toDouble()));
      } else {
        chartData.add(RevenueChartData(month: months[index], revenue: 0));
      }
    });

    providerWallet = json['provider_wallet'] != null
        ? ProviderWallet.fromJson(json['provider_wallet'])
        : null;

    onlineHandyman = json['online_handyman']?.cast<String>();
    myPostJobData = json['post_requests'] != null
        ? (json['post_requests'] as List)
            .map((i) => PostJobData.fromJson(i))
            .toList()
        : null;
    upcomingBookings = json['upcomming_booking'] != null
        ? (json['upcomming_booking'] as List)
            .map((i) => BookingData.fromJson(i))
            .toList()
        : null;
    earningType = json['earning_type'];
    isSubscribed = json['is_subscribed'] ?? 0;
    subscription = json['subscription'] != null
        ? ProviderSubscriptionModel.fromJson(json['subscription'])
        : null;

    isPlanAboutToExpire = isSubscribed == 1;
    userNeverPurchasedPlan = isSubscribed == 0 && subscription == null;
    isPlanExpired = isSubscribed == 0 && subscription != null;
    languageOption = json['language_option'] != null
        ? (json['language_option'] as List)
            .map((i) => LanguageOption.fromJson(i))
            .toList()
        : null;
    notificationUnreadCount = json['notification_unread_count'];
    privacyPolicy = json['privacy_policy'] != null
        ? Configurations.fromJson(json['privacy_policy'])
        : null;
    termConditions = json['term_conditions'] != null
        ? Configurations.fromJson(json['term_conditions'])
        : null;
    inquiryEmail = json['inquriy_email'];
    helplineNumber = json['helpline_number'];
    appDownload = json['app_download'] != null
        ? AppDownload.fromJson(json['app_download'])
        : null;
    isAdvancedPaymentAllowed = json['is_advanced_payment_allowed'];
    enableUserWallet = json['enable_user_wallet'] == '1';
    configurations = json['configurations'] != null
        ? (json['configurations'] as List)
            .map((i) => Configurations.fromJson(i))
            .toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['total_booking'] = totalBooking;
    data['total_service'] = totalService;
    data['today_cash'] = todayCashAmount;
    data['total_inspections'] = totalInspections;
    data['open_inspections'] = openInspections;
    if (commission != null) {
      data['commission'] = commission!.toJson();
    }
    data['total_handyman'] = totalHandyman;
    data['open_requests'] = openRequests;
    if (service != null) {
      data['service'] = service!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.map((v) => v.toJson()).toList();
    }
    if (handyman != null) {
      data['handyman'] = handyman!.map((v) => v.toJson()).toList();
    }
    data['total_revenue'] = totalRevenue;
    data['online_handyman'] = onlineHandyman;
    if (providerWallet != null) {
      data['provider_wallet'] = providerWallet!.toJson();
    }

    if (myPostJobData != null) {
      data['post_requests'] =
          myPostJobData!.map((v) => v.toJson()).toList();
    }

    if (upcomingBookings != null) {
      data['upcomming_booking'] =
          upcomingBookings!.map((v) => v.toJson()).toList();
    }
    data['earning_type'] = earningType;
    if (languageOption != null) {
      data['language_option'] =
          languageOption!.map((v) => v.toJson()).toList();
    }
    data['notification_unread_count'] = notificationUnreadCount;
    if (privacyPolicy != null) {
      data['privacy_policy'] = privacyPolicy;
    }
    if (termConditions != null) {
      data['term_conditions'] = termConditions;
    }
    data['inquriy_email'] = inquiryEmail;
    data['helpline_number'] = helplineNumber;

    if (appDownload != null) {
      data['app_download'] = appDownload;
    }
    data['is_advanced_payment_allowed'] = isAdvancedPaymentAllowed;
    data['enable_user_wallet'] = enableUserWallet;

    if (configurations != null) {
      data['configurations'] =
          configurations!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class CategoryData {
  int? id;
  String? name;
  int? status;
  String? description;
  int? isFeatured;
  String? color;
  String? categoryImage;

  CategoryData(
      {this.id,
      this.name,
      this.status,
      this.description,
      this.isFeatured,
      this.color,
      this.categoryImage});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    description = json['description'];
    isFeatured = json['is_featured'];
    color = json['color'];
    categoryImage = json['category_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['description'] = description;
    data['is_featured'] = isFeatured;
    data['color'] = color;
    data['category_image'] = categoryImage;
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

  Commission(
      {this.commission,
      this.createdAt,
      this.deletedAt,
      this.id,
      this.name,
      this.status,
      this.type,
      this.updatedAt});

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

class ProviderWallet {
  int? id;
  String? title;
  int? userId;
  num? amount;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderWallet(this.id, this.title, this.userId, this.amount, this.status,
      this.createdAt, this.updatedAt);

  ProviderWallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    userId = json['user_id'];
    amount = json['amount'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
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
      country:
          json['country'] != null ? Country.fromJson(json['country']) : null,
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

class ServiceAddressMapping {
  int? id;
  int? serviceId;
  int? providerAddressId;
  String? createdAt;
  String? updatedAt;
  ProviderAddressMapping? providerAddressMapping;

  ServiceAddressMapping(
      {this.id,
      this.serviceId,
      this.providerAddressId,
      this.createdAt,
      this.updatedAt,
      this.providerAddressMapping});

  ServiceAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    providerAddressId = json['provider_address_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    providerAddressMapping = json['provider_address_mapping'] != null
        ? ProviderAddressMapping.fromJson(json['provider_address_mapping'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['provider_address_id'] = providerAddressId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (providerAddressMapping != null) {
      data['provider_address_mapping'] = providerAddressMapping!.toJson();
    }
    return data;
  }
}

class ProviderAddressMapping {
  int? id;
  int? providerId;
  String? address;
  String? latitude;
  String? longitude;
  int? status;
  String? createdAt;
  String? updatedAt;

  ProviderAddressMapping(
      {this.id,
      this.providerId,
      this.address,
      this.latitude,
      this.longitude,
      this.status,
      this.createdAt,
      this.updatedAt});

  ProviderAddressMapping.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class MonthlyRevenue {
  List<RevenueData>? revenueData;

  MonthlyRevenue({this.revenueData});

  MonthlyRevenue.fromJson(Map<String, dynamic> json) {
    if (json['revenueData'] != null) {
      revenueData = [];
      json['revenueData'].forEach((v) {
        revenueData!.add(RevenueData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (revenueData != null) {
      data['revenueData'] = revenueData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RevenueData {
  var i;

  RevenueData({this.i});

  RevenueData.fromJson(Map<String, dynamic> json) {
    for (int i = 1; i <= 12; i++) {
      i = json['$i'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    for (int i = 1; i <= 12; i++) {
      data['$i'] = this.i;
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

  Country(
      {this.id,
      this.code,
      this.name,
      this.dialCode,
      this.currencyName,
      this.symbol,
      this.currencyCode});

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

class LanguageOption {
  String? flagImage;
  String? id;
  String? title;

  LanguageOption({this.flagImage, this.id, this.title});

  factory LanguageOption.fromJson(Map<String, dynamic> json) {
    return LanguageOption(
      flagImage: json['flag_image'],
      id: json['id'],
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['flag_image'] = flagImage;
    data['id'] = id;
    data['title'] = title;
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
