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
import 'package:inventory/widgets/top_layer.dart';
import 'package:inventory/routers/app_router.dart';

@RoutePage()
class MasterListScreen extends ConsumerWidget {
  const MasterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masterAsync = ref.watch(masterListProvider);
    final selectedItems = ref.watch(selectedItemsProvider);
    final selectAll = ref.watch(selectAllProvider);

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
            child: masterAsync.when(
              data: (items) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 50,
                      dataRowMaxHeight: 54,
                      columns: [
                        DataColumn(
                          label: Transform.scale(
                            scale: 0.7,
                            child: Checkbox(
                              value: selectAll,
                              onChanged: (val) {
                                ref.read(selectAllProvider.notifier).toggle();
                                if (val == true) {
                                  ref.read(selectedItemsProvider.notifier).selectAll(items);
                                } else {
                                  ref.read(selectedItemsProvider.notifier).clearAll();
                                }
                              },
                            ),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text("Item ID",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text("Type",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 150,
                            child: Text("Item Name",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text("Vendor",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text("Created Date",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text("Responsible Team",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text("Storage Location",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 100,
                            child: Text("Next Service Due",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 120,
                            child: Text("Availability Status",
                                style: Theme.of(context).textTheme.titleSmall),
                          ),
                        ),
                        const DataColumn(label: Text("")),
                      ],
                      rows: items.map((e) {
                        final isSelected = ref.read(selectedItemsProvider.notifier).isSelected(e.refId);
                        
                        return DataRow(
                          cells: [
                            DataCell(
                              Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  value: isSelected,
                                  onChanged: (val) {
                                    ref.read(selectedItemsProvider.notifier).toggleItem(e.refId);
                                    
                                    // Update select all state
                                    final selectedCount = ref.read(selectedItemsProvider).length;
                                    if (selectedCount == items.length) {
                                      ref.read(selectAllProvider.notifier).set(true);
                                    } else {
                                      ref.read(selectAllProvider.notifier).set(false);
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Item ID
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.assetId,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Type
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: Text(
                                  e.type,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Item Name
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  e.assetName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Vendor
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.supplier,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Created Date
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  "${e.createdDate.day}/${e.createdDate.month}/${e.createdDate.year}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Responsible Team
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Text(
                                  e.responsibleTeam,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Storage Location
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.location,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Next Service Due
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  e.nextServiceDue != null 
                                      ? "${e.nextServiceDue!.day}/${e.nextServiceDue!.month}/${e.nextServiceDue!.year}"
                                      : "N/A",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(fontWeight: FontWeight.w400, fontSize: 11),
                                ),
                              ),
                            ),
                            // Availability Status
                            DataCell(
                              SizedBox(
                                width: 120,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: e.availabilityStatus.toLowerCase() == 'available' 
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: e.availabilityStatus.toLowerCase() == 'available' 
                                          ? Colors.green
                                          : Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    e.availabilityStatus,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w500, 
                                          fontSize: 10,
                                          color: e.availabilityStatus.toLowerCase() == 'available' 
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            // Action button
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  context.router.push(ProductDetailRoute(id: e.refId));
                                },
                                child: SvgPicture.asset(
                                  "assets/images/Select_arrow.svg",
                                  width: 12,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),

          const Divider(
            height: 2,
            color: Color(0xffD9D9D9),
            indent: 24,
            endIndent: 24,
          ),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.centerLeft,
            child: const Text("show 10 entries", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
