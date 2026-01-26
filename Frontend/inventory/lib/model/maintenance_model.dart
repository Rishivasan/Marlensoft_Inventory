class MaintenanceModel {
  final int maintenanceId;
  final String assetType;
  final String assetId;
  final String itemName;
  final DateTime? serviceDate;
  final String serviceProviderCompany;
  final String serviceEngineerName;
  final String serviceType;
  final DateTime? nextServiceDue;
  final String serviceNotes;
  final String maintenanceStatus;
  final double cost;
  final String responsibleTeam;
  final DateTime createdDate;

  MaintenanceModel({
    required this.maintenanceId,
    required this.assetType,
    required this.assetId,
    required this.itemName,
    this.serviceDate,
    required this.serviceProviderCompany,
    required this.serviceEngineerName,
    required this.serviceType,
    this.nextServiceDue,
    required this.serviceNotes,
    required this.maintenanceStatus,
    required this.cost,
    required this.responsibleTeam,
    required this.createdDate,
  });

  factory MaintenanceModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceModel(
      maintenanceId: json['maintenanceId'] ?? 0,
      assetType: json['assetType'] ?? '',
      assetId: json['assetId'] ?? '',
      itemName: json['itemName'] ?? '',
      serviceDate: json['serviceDate'] != null 
          ? DateTime.tryParse(json['serviceDate'].toString())
          : null,
      serviceProviderCompany: json['serviceProviderCompany'] ?? '',
      serviceEngineerName: json['serviceEngineerName'] ?? '',
      serviceType: json['serviceType'] ?? '',
      nextServiceDue: json['nextServiceDue'] != null 
          ? DateTime.tryParse(json['nextServiceDue'].toString())
          : null,
      serviceNotes: json['serviceNotes'] ?? '',
      maintenanceStatus: json['maintenanceStatus'] ?? '',
      cost: (json['cost'] ?? 0.0).toDouble(),
      responsibleTeam: json['responsibleTeam'] ?? '',
      createdDate: DateTime.tryParse(json['createdDate']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maintenanceId': maintenanceId,
      'assetType': assetType,
      'assetId': assetId,
      'itemName': itemName,
      'serviceDate': serviceDate?.toIso8601String(),
      'serviceProviderCompany': serviceProviderCompany,
      'serviceEngineerName': serviceEngineerName,
      'serviceType': serviceType,
      'nextServiceDue': nextServiceDue?.toIso8601String(),
      'serviceNotes': serviceNotes,
      'maintenanceStatus': maintenanceStatus,
      'cost': cost,
      'responsibleTeam': responsibleTeam,
      'createdDate': createdDate.toIso8601String(),
    };
  }
}