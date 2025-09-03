import 'dart:convert';

// class PaginationHomeOwner {
//   final int? totalItems;
//   final int? perPage;
//   final int? currentPage;
//   final int? totalPages;
//   final int? from;
//   final int? to;
//   final dynamic nextPage;
//   final dynamic previousPage;

//   PaginationHomeOwner({
//     this.totalItems,
//     this.perPage,
//     this.currentPage,
//     this.totalPages,
//     this.from,
//     this.to,
//     this.nextPage,
//     this.previousPage,
//   });

//   factory PaginationHomeOwner.fromJson(Map<String, dynamic> json) {
//     return PaginationHomeOwner(
//       totalItems: json['total_items'],
//       perPage: json['per_page'],
//       currentPage: json['currentPage'],
//       totalPages: json['totalPages'],
//       from: json['from'],
//       to: json['to'],
//       nextPage: json['next_page'],
//       previousPage: json['previous_page'],
//     );
//   }
// }

class UserDataHomeOwner {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? address;
  final String? lastNotificationSeen;

  UserDataHomeOwner({
    this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.address,
    this.lastNotificationSeen,
  });

  factory UserDataHomeOwner.fromJson(Map<String, dynamic> json) {
    return UserDataHomeOwner(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
      address: json['address'],
      lastNotificationSeen: json['last_notification_seen'],
    );
  }
}

class UserDataListModel {
  // final PaginationHomeOwner? pagination;
  final List<UserDataHomeOwner>? data;

  UserDataListModel({
    // this.pagination,
    this.data,
  });

  factory UserDataListModel.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return UserDataListModel(
      // pagination: PaginationHomeOwner.fromJson(json['pagination']),
      data: List<UserDataHomeOwner>.from(
        (json['data'] as List)
            .map((userData) => UserDataHomeOwner.fromJson(userData)),
      ),
    );
  }
}
