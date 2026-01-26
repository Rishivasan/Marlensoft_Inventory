// class MasterListModel {
//   final int sno;
//   final String itemType;
//   final String refId;

//   final String assetId;
//   final String type;
//   final String assetName;
//   final String supplier;
//   final String location;

//   MasterListModel({
//     required this.sno,
//     required this.itemType,
//     required this.refId,
//     required this.assetId,
//     required this.type,
//     required this.assetName,
//     required this.supplier,
//     required this.location,
//   });

//   factory MasterListModel.fromJson(Map<String, dynamic> json) {
//     return MasterListModel(
//       sno: json["sNo"] ?? 0,
//       itemType: json["itemType"] ?? "",
//       refId: json["refId"] ?? "",

//       assetId: json["assetId"] ?? "",
//       type: json["type"] ?? "",
//       assetName: json["assetName"] ?? "",
//       supplier: json["supplier"] ?? "",
//       location: json["location"] ?? "",
//     );
//   }
// }



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

  // factory MasterListModel.fromJson(Map<String, dynamic> json) {
  //   String itemType = (json["itemType"] ?? "").toString();

  //   // Common fields
  //   String assetId = (json["refId"] ?? "").toString();

  //   // Map based on type
  //   String type = "";
  //   String name = "";
  //   String supplier = "";
  //   String location = "";

  //   if (itemType == "Tool") {
  //     type = (json["toolType"] ?? "").toString();
  //     name = (json["toolName"] ?? "").toString();
  //     supplier = (json["vendorName"] ?? "").toString();
  //     location = (json["storageLocation"] ?? "").toString();
  //   } else if (itemType == "Asset") {
  //     type = (json["category"] ?? "").toString();
  //     name = (json["assetName"] ?? "").toString();
  //     supplier = (json["vendor"] ?? "").toString();
  //     location = (json["storageLocation"] ?? "").toString();
  //   } else if (itemType == "Consumable") {
  //     type = "Consumable";
  //     name = (json["assetName"] ?? "").toString();
  //     supplier = (json["vendor"] ?? "").toString();
  //     location = (json["storageLocation"] ?? "").toString();
  //   } else if (itemType == "MMD") {
  //     type = "MMD";
  //     name = (json["modelNumber"] ?? json["mmdId"] ?? "").toString();
  //     supplier = (json["vendor"] ?? "").toString();
  //     location = (json["location"] ?? "").toString();
  //   }

  //   return MasterListModel(
  //     sno: int.tryParse(json["sNo"].toString()) ?? 0,
  //     itemType: itemType,
  //     refId: (json["refId"] ?? "").toString(),
  //     assetId: assetId,
  //     type: type,
  //     name: name,
  //     supplier: supplier,
  //     location: location,
  //   );
  //}

 factory MasterListModel.fromJson(Map<String, dynamic> json) {
    final itemType = (json["itemType"] ?? json["type"] ?? "").toString();

    return MasterListModel(
      sno: int.tryParse(json["sNo"].toString()) ?? 0,
      itemType: itemType,
      refId: (json["refId"] ?? json["itemID"] ?? "").toString(),
      assetId: (json["displayId"] ?? json["refId"] ?? json["itemID"] ?? "").toString(),

      type: (json["type"] ??
              json["toolType"] ??
              json["category"] ??
              itemType)
          .toString(),

      name: (json["name"] ??
              json["itemName"] ??
              json["toolName"] ??
              json["assetName"] ??
              json["modelNumber"] ??
              "")
          .toString(),

      supplier:
          (json["supplier"] ?? json["vendor"] ?? json["vendorName"] ?? "")
              .toString(),

      location: (json["location"] ?? json["storageLocation"] ?? "").toString(),
      
      // New enhanced fields
      createdDate: DateTime.tryParse(json["createdDate"]?.toString() ?? "") ?? DateTime.now(),
      responsibleTeam: (json["responsibleTeam"] ?? "").toString(),
      nextServiceDue: json["nextServiceDue"] != null 
          ? DateTime.tryParse(json["nextServiceDue"].toString()) 
          : null,
      availabilityStatus: (json["availabilityStatus"] ?? "Available").toString(),
    );
  }

}
