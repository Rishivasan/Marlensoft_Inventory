class MasterListModel {
  final int sno;
  final String itemType;
  final String refId;

  final String assetId;
  final String type;

  final String name;
  String get assetName => name;

  final String supplier;
  final String location;
  
  // New enhanced fields
  final DateTime createdDate;
  final String responsibleTeam;
  final DateTime? nextServiceDue;
  final String availabilityStatus;

  MasterListModel({
    required this.sno,
    required this.itemType,
    required this.refId,
    required this.assetId,
    required this.type,
    required this.name,
    required this.supplier,
    required this.location,
    required this.createdDate,
    required this.responsibleTeam,
    this.nextServiceDue,
    required this.availabilityStatus,
  });


 factory MasterListModel.fromJson(Map<String, dynamic> json) {
    final itemType = (json["itemType"] ?? json["type"] ?? "").toString();

    return MasterListModel(
      sno: int.tryParse(json["sNo"].toString()) ?? 0,
      itemType: itemType,
      refId: (json["refId"] ?? json["itemID"] ?? json["ItemID"] ?? "").toString(),
      assetId: (json["displayId"] ?? json["refId"] ?? json["itemID"] ?? json["ItemID"] ?? "").toString(),

      type: (json["type"] ??
              json["toolType"] ??
              json["category"] ??
              itemType)
          .toString(),

      name: (json["name"] ??
              json["itemName"] ??
              json["ItemName"] ??
              json["toolName"] ??
              json["assetName"] ??
              json["modelNumber"] ??
              "")
          .toString(),

      supplier:
          (json["supplier"] ?? 
           json["vendor"] ?? 
           json["Vendor"] ??
           json["vendorName"] ?? 
           "")
              .toString(),

      location: (json["location"] ?? 
                 json["storageLocation"] ?? 
                 json["StorageLocation"] ??
                 "").toString(),
      
      // New enhanced fields
      createdDate: DateTime.tryParse(json["createdDate"]?.toString() ?? json["CreatedDate"]?.toString() ?? "") ?? DateTime.now(),
      responsibleTeam: (json["responsibleTeam"] ?? json["ResponsibleTeam"] ?? "").toString(),
      nextServiceDue: json["nextServiceDue"] != null || json["NextServiceDue"] != null
          ? DateTime.tryParse((json["nextServiceDue"] ?? json["NextServiceDue"]).toString()) 
          : null,
      availabilityStatus: (json["availabilityStatus"] ?? json["AvailabilityStatus"] ?? "Available").toString(),
    );
  }

}
