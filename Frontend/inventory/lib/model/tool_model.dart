class ToolModel {
  final String toolsId;
  final String toolType;
  final String toolName;
  final String vendorName;
  final String storageLocation;

  ToolModel({
    required this.toolsId,
    required this.toolType,
    required this.toolName,
    required this.vendorName,
    required this.storageLocation,
  });

  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      toolsId: json["toolsId"] ?? 0,
      toolType: json["toolType"] ?? "",
      toolName: json["toolName"] ?? "",
      vendorName: json["vendorName"] ?? "",
      storageLocation: json["storageLocation"] ?? "",
    );
  }
}
