class AllocationModel {
  final int allocationId;
  final String assetType;
  final String assetId;
  final String itemName;
  final String employeeId;
  final String employeeName;
  final String teamName;
  final String purpose;
  final DateTime? issuedDate;
  final DateTime? expectedReturnDate;
  final DateTime? actualReturnDate;
  final String availabilityStatus;
  final DateTime createdDate;

  AllocationModel({
    required this.allocationId,
    required this.assetType,
    required this.assetId,
    required this.itemName,
    required this.employeeId,
    required this.employeeName,
    required this.teamName,
    required this.purpose,
    this.issuedDate,
    this.expectedReturnDate,
    this.actualReturnDate,
    required this.availabilityStatus,
    required this.createdDate,
  });

  factory AllocationModel.fromJson(Map<String, dynamic> json) {
    return AllocationModel(
      allocationId: json['allocationId'] ?? 0,
      assetType: json['assetType'] ?? '',
      assetId: json['assetId'] ?? '',
      itemName: json['itemName'] ?? '',
      employeeId: json['employeeId'] ?? '',
      employeeName: json['employeeName'] ?? '',
      teamName: json['teamName'] ?? '',
      purpose: json['purpose'] ?? '',
      issuedDate: json['issuedDate'] != null 
          ? DateTime.tryParse(json['issuedDate'].toString())
          : null,
      expectedReturnDate: json['expectedReturnDate'] != null 
          ? DateTime.tryParse(json['expectedReturnDate'].toString())
          : null,
      actualReturnDate: json['actualReturnDate'] != null 
          ? DateTime.tryParse(json['actualReturnDate'].toString())
          : null,
      availabilityStatus: json['availabilityStatus'] ?? '',
      createdDate: DateTime.tryParse(json['createdDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allocationId': allocationId,
      'assetType': assetType,
      'assetId': assetId,
      'itemName': itemName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'teamName': teamName,
      'purpose': purpose,
      'issuedDate': issuedDate?.toIso8601String(),
      'expectedReturnDate': expectedReturnDate?.toIso8601String(),
      'actualReturnDate': actualReturnDate?.toIso8601String(),
      'availabilityStatus': availabilityStatus,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}