import 'package:nb_utils/nb_utils.dart';

class Pagination {
  var currentPage;
  var totalPages;
  var totalItems;

  Pagination({this.totalPages, this.totalItems, this.currentPage});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalPages: json['totalPages']?.toString().toInt(),
      totalItems: json['total_items']?.toString().toInt(),
      currentPage: json['currentPage']?.toString().toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['totalPages'] = totalPages;
    data['total_items'] = totalItems;
    data['currentPage'] = currentPage;
    return data;
  }
}
