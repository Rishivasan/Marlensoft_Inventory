// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:inventory/model/assets_table_model.dart';
// import 'package:inventory/widgets/top_layer.dart';

// @RoutePage()
// class MasterListScreen extends StatelessWidget {
//    MasterListScreen({super.key});
//   final List<EmployeeTableModel> employees = [
//     EmployeeTableModel(
//       Asset: 101,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
//     EmployeeTableModel(
//       Asset: 102,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
//     EmployeeTableModel(
//       Asset: 103,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
//     EmployeeTableModel(
//       Asset: 103,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
//     EmployeeTableModel(
//       Asset: 103,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
//     EmployeeTableModel(
//       Asset: 103,
//       Type:"Weightbalance",
//       AssetName: "LPA",
//       Supplier: "TATA",
//       Location: "Chennai",
//     ),
    
    
   
//   ];



//   @override
//   Widget build(BuildContext context) {
//     return  Container(
//       padding: EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           TopLayer(),
//           Container(
//             decoration: BoxDecoration(color: Colors.white),
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(horizontal: 24),
//             child: DataTable(
//               headingRowHeight: 50,
//               dataRowMaxHeight: 54,
    
//               columns: [
//                 DataColumn(
//                   label: Transform.scale(
//                     scale: 0.7,
//                     child: Checkbox(value: false, onChanged: (val) {}),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(
//                     width: 120,
//                     child: Text(
//                       "Asset ID",
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(
//                     width: 40,
//                     child: Text(
//                       "Type",
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(
//                     width: 180,
//                     child: Text(
//                       "Asset Name",
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(
//                     width: 60,
//                     child: Text(
//                       "Supplier",
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: SizedBox(
//                     width: 70,
//                     child: Text(
//                       "Location",
//                       style: Theme.of(context).textTheme.titleSmall,
//                     ),
//                   ),
//                 ),
//                 DataColumn(label: Text('')),
//               ],
//               rows: employees.map((e) {
//                 return DataRow(
//                   cells: [
//                     DataCell(
//                       Transform.scale(
//                         scale: 0.7,
//                         child: Checkbox(
//                           value: false,
//                           onChanged: (val) {},
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Container(
//                         width: 80,
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           e.Asset.toString(),
//                           textAlign: TextAlign.start,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium!
//                               .copyWith(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 11,
//                               ),
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       SizedBox(
//                         width: 140,
//                         child: Text(
//                           e.Type,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium!
//                               .copyWith(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 11,
//                               ),
//                         ),
//                       ),
//                     ),
                 
//                      DataCell(
//                       SizedBox(
//                         width: 120,
//                         child: Text(
//                           e.AssetName,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium!
//                               .copyWith(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                               ),
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       SizedBox(
//                         width: 120,
//                         child: Text(
//                           e.Supplier,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium!
//                               .copyWith(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                               ),
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       SizedBox(
//                         child: Text(
//                           e.Location,
//                           style: Theme.of(context)
//                               .textTheme
//                               .displayMedium!
//                               .copyWith(
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: 12,
//                               ),
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       SvgPicture.asset(
//                         "assets/images/Select_arrow.svg",
//                         width: 12,
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//           Divider(
//             height: 2,
//             color: Color(0xffD9D9D9),
//             indent: 24,
//             endIndent: 24,
//           ),
//           Container(
//             height: 40,
//             padding: EdgeInsets.symmetric(horizontal: 24),
//             alignment: Alignment.center,
//             child: Stack(
//               children: [
//                 Positioned(
//                   child: Row(
//                     spacing: 10,
//                     children: [
//                       Text(
//                         "show",
//                         style: TextStyle(
//                           color: Color(0xff000000),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                       Text("10"),
//                       Text(
//                         "entries",
//                         style: TextStyle(
//                           color: Color(0xff000000),
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';

// import 'package:inventory/providers/master_list_provider.dart';
// import 'package:inventory/widgets/top_layer.dart';

// @RoutePage()
// class MasterListScreen extends ConsumerWidget {
//   const MasterListScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final toolsAsync = ref.watch(masterListProvider);

//     return Container(
//       padding: const EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           const TopLayer(),

//           Expanded(
//             child: toolsAsync.when(
//               data: (employees) {
//                 return SingleChildScrollView(
//                   child: Container(
//                     decoration: const BoxDecoration(color: Colors.white),
//                     width: double.infinity,
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: DataTable(
//                       headingRowHeight: 50,
//                       dataRowMaxHeight: 54,
//                       columns: [
//                         DataColumn(
//                           label: Transform.scale(
//                             scale: 0.7,
//                             child: Checkbox(value: false, onChanged: (val) {}),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 120,
//                             child: Text(
//                               "Asset ID",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 40,
//                             child: Text(
//                               "Type",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 180,
//                             child: Text(
//                               "Asset Name",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 60,
//                             child: Text(
//                               "Supplier",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 70,
//                             child: Text(
//                               "Location",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         const DataColumn(label: Text('')),
//                       ],
//                       rows: employees.map((e) {
//                         return DataRow(
//                           cells: [
//                             DataCell(
//                               Transform.scale(
//                                 scale: 0.7,
//                                 child: Checkbox(
//                                   value: false,
//                                   onChanged: (val) {},
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               Container(
//                                 width: 80,
//                                 alignment: Alignment.centerLeft,
//                                 child: Text(
//                                   e.Asset.toString(),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 11,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 140,
//                                 child: Text(
//                                   e.Type,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 11,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   e.AssetName,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   e.Supplier,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               Text(
//                                 e.Location,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .displayMedium!
//                                     .copyWith(
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 12,
//                                     ),
//                               ),
//                             ),
//                             DataCell(
//                               SvgPicture.asset(
//                                 "assets/images/Select_arrow.svg",
//                                 width: 12,
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//               loading: () => const Expanded(
//                 child: Center(child: CircularProgressIndicator()),
//               ),
//               error: (err, stack) => Expanded(
//                 child: Center(
//                   child: Text(
//                     "Error: $err",
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           const Divider(
//             height: 2,
//             color: Color(0xffD9D9D9),
//             indent: 24,
//             endIndent: 24,
//           ),

//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             alignment: Alignment.center,
//             child: const Row(
//               children: [
//                 Text(
//                   "show 10 entries",
//                   style: TextStyle(
//                     color: Color(0xff000000),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:inventory/providers/master_list_provider.dart';
// import 'package:inventory/widgets/top_layer.dart';
// import 'package:inventory/providers/tool_provider.dart';
// import 'package:inventory/model/tool_model.dart';

// @RoutePage()
// class MasterListScreen extends ConsumerWidget {
//   const MasterListScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final toolsAsync = ref.watch(masterListProvider);

//     return Container(
//       padding: const EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           TopLayer(),

//           Expanded(
//             child: toolsAsync.when(
//               data: (tools) {
//                 return Container(
//                   decoration: const BoxDecoration(color: Colors.white),
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: SingleChildScrollView(
//                     child: DataTable(
//                       headingRowHeight: 50,
//                       dataRowMaxHeight: 54,
//                       columns: [
//                         DataColumn(
//                           label: Transform.scale(
//                             scale: 0.7,
//                             child: Checkbox(value: false, onChanged: (val) {}),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 120,
//                             child: Text("Asset ID",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 40,
//                             child: Text("Type",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 180,
//                             child: Text("Asset Name",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 60,
//                             child: Text("Supplier",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 70,
//                             child: Text("Location",
//                                 style: Theme.of(context).textTheme.titleSmall),
//                           ),
//                         ),
//                         const DataColumn(label: Text('')),
//                       ],
//                       rows: tools.map<DataRow>((tool) {
//                         return DataRow(
//                           cells: [
//                             DataCell(
//                               Transform.scale(
//                                 scale: 0.7,
//                                 child: Checkbox(value: false, onChanged: (val) {}),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 80,
//                                 child: Text(
//                                   tool["toolsId"].toString(),
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 140,
//                                 child: Text(
//                                   tool["toolType"] ?? "",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   tool["toolName"] ?? "",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(fontWeight: FontWeight.w400, fontSize: 12),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   tool["vendorName"] ?? "",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(fontWeight: FontWeight.w400, fontSize: 12),
//                                 ),
//                               ),
//                             ),
//                             DataCell(
//                               Text(
//                                 tool["storageLocation"] ?? "",
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .displayMedium!
//                                     .copyWith(fontWeight: FontWeight.w400, fontSize: 12),
//                               ),
//                             ),
//                             DataCell(
//                               SvgPicture.asset(
//                                 "assets/images/Select_arrow.svg",
//                                 width: 12,
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text("Error: $e")),
//             ),
//           ),

//           const Divider(
//             height: 2,
//             color: Color(0xffD9D9D9),
//             indent: 24,
//             endIndent: 24,
//           ),
//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             alignment: Alignment.center,
//             child: Row(
//               children: const [
//                 Text("show", style: TextStyle(fontSize: 12)),
//                 SizedBox(width: 10),
//                 Text("10"),
//                 SizedBox(width: 10),
//                 Text("entries", style: TextStyle(fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// import 'package:inventory/providers/tool_provider.dart';
// import 'package:inventory/widgets/top_layer.dart';

// @RoutePage()
// class MasterListScreen extends ConsumerWidget {
//   const MasterListScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ✅ Use NEW provider (MODEL based)
//     final toolsAsync = ref.watch(toolListProvider);

//     return Container(
//       padding: const EdgeInsets.only(top: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Column(
//         children: [
//           const TopLayer(),

//           Expanded(
//             child: toolsAsync.when(
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (e, _) => Center(child: Text("Error: $e")),
//               data: (tools) {
//                 return Container(
//                   decoration: const BoxDecoration(color: Colors.white),
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   child: SingleChildScrollView(
//                     child: DataTable(
//                       headingRowHeight: 50,
//                       dataRowMaxHeight: 54,
//                       columns: [
//                         DataColumn(
//                           label: Transform.scale(
//                             scale: 0.7,
//                             child: Checkbox(value: false, onChanged: (val) {}),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 120,
//                             child: Text(
//                               "Asset ID",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 40,
//                             child: Text(
//                               "Type",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 180,
//                             child: Text(
//                               "Asset Name",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 60,
//                             child: Text(
//                               "Supplier",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         DataColumn(
//                           label: SizedBox(
//                             width: 70,
//                             child: Text(
//                               "Location",
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                           ),
//                         ),
//                         const DataColumn(label: Text('')),
//                       ],

//                       // ✅ MODEL usage here (NO tool["..."])
//                       rows: tools.map((tool) {
//                         return DataRow(
//                           cells: [
//                             DataCell(
//                               Transform.scale(
//                                 scale: 0.7,
//                                 child: Checkbox(
//                                   value: false,
//                                   onChanged: (val) {},
//                                 ),
//                               ),
//                             ),

//                             DataCell(
//                               SizedBox(
//                                 width: 80,
//                                 child: Text(
//                                   tool.toolsId,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 11,
//                                       ),
//                                 ),
//                               ),
//                             ),

//                             DataCell(
//                               SizedBox(
//                                 width: 140,
//                                 child: Text(
//                                   tool.toolType,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 11,
//                                       ),
//                                 ),
//                               ),
//                             ),

//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   tool.toolName,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                 ),
//                               ),
//                             ),

//                             DataCell(
//                               SizedBox(
//                                 width: 120,
//                                 child: Text(
//                                   tool.vendorName,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .displayMedium!
//                                       .copyWith(
//                                         fontWeight: FontWeight.w400,
//                                         fontSize: 12,
//                                       ),
//                                 ),
//                               ),
//                             ),

//                             DataCell(
//                               Text(
//                                 tool.storageLocation,
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .displayMedium!
//                                     .copyWith(
//                                       fontWeight: FontWeight.w400,
//                                       fontSize: 12,
//                                     ),
//                               ),
//                             ),

//                             DataCell(
//                               SvgPicture.asset(
//                                 "assets/images/Select_arrow.svg",
//                                 width: 12,
//                               ),
//                             ),
//                           ],
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const Divider(
//             height: 2,
//             color: Color(0xffD9D9D9),
//             indent: 24,
//             endIndent: 24,
//           ),

//           Container(
//             height: 40,
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             alignment: Alignment.center,
//             child: Row(
//               children: const [
//                 Text("show", style: TextStyle(fontSize: 12)),
//                 SizedBox(width: 10),
//                 Text("10"),
//                 SizedBox(width: 10),
//                 Text("entries", style: TextStyle(fontSize: 12)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/selection_provider.dart';
import 'package:inventory/providers/search_provider.dart';
import 'package:inventory/widgets/top_layer.dart';
import 'package:inventory/widgets/generic_paginated_table.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/model/master_list_model.dart';

@RoutePage()
class MasterListScreen extends ConsumerWidget {
  const MasterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use filtered data instead of raw data
    final filteredItems = ref.watch(filteredMasterListProvider);
    final masterListAsync = ref.watch(masterListProvider);
    
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          TopLayer(),

          Expanded(
            child: masterListAsync.when(
              data: (items) {
                // Show message if no results found
                if (filteredItems.isEmpty && items.isNotEmpty) {
                  final searchQuery = ref.watch(masterListSearchQueryProvider);
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "$searchQuery"',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your search terms',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GenericPaginatedTable<MasterListModel>(
                    data: filteredItems, // Use filtered data
                    rowsPerPage: 7,
                    minWidth: 1800,
                    showCheckboxColumn: true,
                    onSelectionChanged: (selectedItems) {
                      print("Selected ${selectedItems.length} items");
                    },
                    headers: [
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Item ID", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 120,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Type", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Item Name", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Vendor", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Created Date", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Responsible Team", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Storage Location", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Next Service Due", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Availability Status", 
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SvgPicture.asset("assets/images/Icon_filter.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                            const SizedBox(width: 1),
                            SvgPicture.asset("assets/images/Icon_arrowdown.svg", width: 14, height: 14, colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn)),
                          ],
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: const Text(""),
                      ),
                    ],
                    rowBuilder: (item, isSelected, onChanged) => [
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.assetId,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.type,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.assetName,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.supplier,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${item.createdDate.day}/${item.createdDate.month}/${item.createdDate.year}",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.responsibleTeam,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.location,
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 150,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.nextServiceDue != null 
                              ? "${item.nextServiceDue!.day}/${item.nextServiceDue!.month}/${item.nextServiceDue!.year}"
                              : "N/A",
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            fontWeight: FontWeight.w400, 
                            fontSize: 11
                          ),
                        ),
                      ),
                      Container(
                        width: 180,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.availabilityStatus.toLowerCase() == 'available' 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.availabilityStatus.toLowerCase() == 'available' 
                                  ? Colors.green
                                  : Colors.orange,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item.availabilityStatus,
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              fontWeight: FontWeight.w500, 
                              fontSize: 10,
                              color: item.availabilityStatus.toLowerCase() == 'available' 
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            context.router.push(ProductDetailRoute(id: item.refId));
                          },
                          child: SvgPicture.asset(
                            "assets/images/Select_arrow.svg",
                            width: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
    );
  }
}
