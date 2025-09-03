import 'dart:convert';

import 'package:trade/models/provider_subscription_model.dart';
import 'package:nb_utils/nb_utils.dart';

class UserData {
  int? id;
  String? uid;
  String? username;
  String? firstName;
  String? lastName;
  String? email;
  String? emailVerifiedAt;
  String? userType;
  String? contactNumber;
  int? countryId;
  int? stateId;
  int? cityId;
  String? address;
  int? providerId;
  String? playerId;
  int? status;
  int? providertypeId;
  int? isFeatured;
  String? displayName;
  String? timeZone;
  String? lastNotificationSeen;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? apiToken;
  String? profileImage;
  String? description;
  String? knownLanguages;
  String? skills;
  int? serviceAddressId;
  num? handymanRating;
  int? isSubscribe;
  String? designation;
  String? password;
  String? cityName;
  num? providerServiceRating;
  String? providerType;
  bool? isHandymanAvailable;
  String? loginType;
  String? handymanType;
  num? slotsForAllServices;
  int? isOnline;
  List<String>? userRole;
  ProviderSubscriptionModel? subscription;

  //Local
  bool isActive = false;

  bool get isUserActive => status == 0;

  ///  This is to check if the provider's all services have time slot or not.
  bool get isSlotsForAllServices => slotsForAllServices == 1;

  List<String> get knownLanguagesArray => buildKnownLanguages();

  List<String> get skillsArray => buildSkills();

  List<String> buildKnownLanguages() {
    List<String> array = [];
    String tempLanguages = knownLanguages.validate();
    if (tempLanguages.isNotEmpty && tempLanguages.isJson()) {
      Iterable it1 = jsonDecode(knownLanguages.validate());
      array.addAll(it1.map((e) => e.toString()).toList());
    }

    return array;
  }

  List<String> buildSkills() {
    List<String> array = [];
    String tempSkills = skills.validate();
    if (tempSkills.isNotEmpty && tempSkills.isJson()) {
      Iterable it2 = jsonDecode(skills.validate());
      array.addAll(it2.map((e) => e.toString()).toList());
    }

    return array;
  }

  UserData({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.emailVerifiedAt,
    this.userType,
    this.contactNumber,
    this.countryId,
    this.providerServiceRating,
    this.stateId,
    this.cityId,
    this.address,
    this.providerId,
    this.playerId,
    this.slotsForAllServices,
    this.status,
    this.providertypeId,
    this.isFeatured,
    this.displayName,
    this.timeZone,
    this.lastNotificationSeen,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.userRole,
    this.apiToken,
    this.profileImage,
    this.description,
    this.knownLanguages,
    this.skills,
    this.serviceAddressId,
    this.handymanRating,
    this.subscription,
    this.isSubscribe,
    this.uid,
    this.designation,
    this.cityName,
    this.providerType,
    this.handymanType,
    this.isHandymanAvailable,
    this.loginType,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    slotsForAllServices = json['slots_for_all_services'] ?? 0;
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    providerServiceRating = json['providers_service_rating'];
    isOnline = json['isOnline'];
    userType = json['user_type'];
    contactNumber = json['contact_number'];
    countryId = json['country_id'];
    stateId = json['state_id'];
    cityId = json['city_id'];
    address = json['address'];
    providerId = json['provider_id'];
    playerId = json['player_id'];
    status = json['status'];
    isActive = status == 1;
    serviceAddressId = json['service_address_id'];
    handymanRating = json['handyman_rating'];
    isFeatured = json['is_featured'];
    displayName = json['display_name'];
    timeZone = json['time_zone'];
    lastNotificationSeen = json['last_notification_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    apiToken = json['api_token'];
    profileImage = json['profile_image'];
    description = json['description'];
    knownLanguages = json['known_languages'];
    skills = json['skills'];
    uid = json['uid'];
    subscription = json['subscription'] != null ? ProviderSubscriptionModel.fromJson(json['subscription']) : null;
    isSubscribe = json['is_subscribe'];
    designation = json['designation'];
    cityName = json['city_name'];
    providerType = json['providertype'];
    handymanType = json['handymantype'];
    isHandymanAvailable = json['isHandymanAvailable'] != null ? json['isHandymanAvailable'] == 1 : false;
    loginType = json['login_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (slotsForAllServices != null) data['slots_for_all_services'] = slotsForAllServices;
    if (username != null) data['username'] = username;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;
    if (providerServiceRating != null) data['providers_service_rating'] = providerServiceRating;
    if (serviceAddressId != null) data['service_address_id'] = serviceAddressId;
    if (handymanRating != null) data['handyman_rating'] = handymanRating;
    if (emailVerifiedAt != null) data['email_verified_at'] = emailVerifiedAt;
    if (userType != null) data['user_type'] = userType;
    if (contactNumber != null) data['contact_number'] = contactNumber;
    if (countryId != null) data['country_id'] = countryId;
    if (isOnline != null) data['isOnline'] = isOnline;
    if (handymanType != null) data['handymantype'] = handymanType;
    if (stateId != null) data['state_id'] = stateId;
    if (cityId != null) data['city_id'] = cityId;
    if (address != null) data['address'] = address;
    if (providerId != null) data['provider_id'] = providerId;
    if (playerId != null) data['player_id'] = playerId;
    if (status != null) data['status'] = status;
    if (providertypeId != null) data['providertype_id'] = providertypeId;
    if (isFeatured != null) data['is_featured'] = isFeatured;
    if (displayName != null) data['display_name'] = displayName;
    if (timeZone != null) data['time_zone'] = timeZone;
    if (lastNotificationSeen != null) data['last_notification_seen'] = lastNotificationSeen;
    if (createdAt != null) data['created_at'] = createdAt;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (deletedAt != null) data['deleted_at'] = deletedAt;
    if (userRole != null) data['user_role'] = userRole;
    if (apiToken != null) data['api_token'] = apiToken;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (description != null) data['description'] = description;
    if (knownLanguages != null) data['known_languages'] = knownLanguages;
    if (skills != null) data['skills'] = skills;
    if (uid != null) data['uid'] = uid;
    if (isSubscribe != null) data['is_subscribe'] = isSubscribe;
    if (cityName != null) data['city_name'] = cityName;
    if (providerType != null) data['providertype'] = providerType;
    if (isHandymanAvailable != null) data['isHandymanAvailable'] = isHandymanAvailable;
    if (loginType != null) data['login_type'] = loginType;

    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (designation != null) data['designation'] = designation;
    return data;
  }

  Map<String, dynamic> toFirebaseJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (uid != null) data['uid'] = uid;
    if (apiToken != null) data['api_token'] = apiToken;
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (email != null) data['email'] = email;
    if (displayName != null) data['display_name'] = displayName;
    if (password != null) data['password'] = password;
    if (playerId != null) data['player_id'] = playerId;
    if (profileImage != null) data['profile_image'] = profileImage;
    if (isOnline != null) data['isOnline'] = isOnline;
    if (updatedAt != null) data['updated_at'] = updatedAt;
    if (createdAt != null) data['created_at'] = createdAt;
    return data;
  }
}
