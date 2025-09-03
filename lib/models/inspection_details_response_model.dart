class InspectionDetailsResponse {
  final InspectionDetailsData? data;

  InspectionDetailsResponse({this.data});

  factory InspectionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InspectionDetailsResponse(
      data: json['data'] != null
          ? InspectionDetailsData.fromJson(json['data'])
          : null,
    );
  }
}

class InspectionDetailsData {
  final int? id;
  final String? address;
  final int? customerId;
  final int? technicianId;
  final int? propertyId;
  final int? providerId;
  final String? date;
  final String? status;
  final String? description;
  final String? customerName;
  final String? technicianName;

  InspectionDetailsData({
    this.id,
    this.address,
    this.customerId,
    this.technicianId,
    this.propertyId,
    this.providerId,
    this.date,
    this.status,
    this.description,
    this.customerName,
    this.technicianName,
  });

  factory InspectionDetailsData.fromJson(Map<String, dynamic> json) {
    return InspectionDetailsData(
      id: json['id'],
      address: json['address'],
      customerId: json['customer_id'],
      technicianId: json['technician_id'],
      propertyId: json['property_id'],
      providerId: json['provider_id'],
      date: json['date'],
      status: json['status'],
      description: json['description'],
      customerName: json['customer_name'],
      technicianName: json['technician_name'],
    );
  }
}
