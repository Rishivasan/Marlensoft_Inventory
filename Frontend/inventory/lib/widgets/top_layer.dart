// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:inventory/dialogs/dialog_pannel_helper.dart';
// import 'package:inventory/providers/master_list_provider.dart';
// import 'package:inventory/screens/add_forms/add_asset.dart';
// import 'package:inventory/screens/add_forms/add_consumable.dart';
// import 'package:inventory/screens/add_forms/add_mmd.dart';
// import 'package:inventory/screens/add_forms/add_tool.dart';

// class TopLayer extends ConsumerWidget {
//   const TopLayer({super.key});

//   bool get isButtonEnabled => true;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               SizedBox(
//                 width: 440,
//                 height: 35,
//                 child: SearchBar(
//                   elevation: const WidgetStatePropertyAll(0),
//                   backgroundColor: const WidgetStatePropertyAll(Colors.white),
//                   hintText: 'Search',
//                   padding: const WidgetStatePropertyAll(
//                     EdgeInsetsGeometry.only(left: 6, bottom: 2),
//                   ),
//                   hintStyle: WidgetStatePropertyAll(
//                     Theme.of(context).textTheme.bodyMedium,
//                   ),
//                   shape: WidgetStatePropertyAll(
//                     RoundedRectangleBorder(
//                       side: const BorderSide(color: Color(0xff909090), width: 1),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                   ),
//                   trailing: [
//                     IconButton(
//                       onPressed: () {},
//                       icon: SvgPicture.asset("assets/images/Vector.svg", width: 12),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     MaterialButton(
//                       onPressed: () {},
//                       height: 45,
//                       minWidth: 90,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: BorderSide(
//                           color: isButtonEnabled
//                               ? Theme.of(context).primaryColor
//                               : const Color.fromRGBO(144, 144, 144, 100),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         "Delete",
//                         style: TextStyle(
//                           color: isButtonEnabled
//                               ? Theme.of(context).primaryColor
//                               : const Color.fromRGBO(144, 144, 144, 100),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     MaterialButton(
//                       onPressed: () {},
//                       height: 45,
//                       minWidth: 90,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: BorderSide(
//                           color: isButtonEnabled
//                               ? Theme.of(context).primaryColor
//                               : const Color.fromRGBO(144, 144, 144, 1),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         "Export",
//                         style: TextStyle(
//                           color: isButtonEnabled
//                               ? Theme.of(context).primaryColor
//                               : const Color.fromRGBO(144, 144, 144, 1),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 20),

//                     SizedBox(
//                       width: 160,
//                       height: 42,
//                       child: PopupMenuButton<String>(
//                         color: Colors.white,
//                         elevation: 0,
//                         offset: const Offset(0, 45),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           side: const BorderSide(color: Color(0xff00599A), width: 1),
//                         ),
//                         onSelected: (value) {
//                           Future.delayed(const Duration(milliseconds: 150), () {
//                             if (value == "tool") {
//                               DialogPannelHelper().showAddPannel(
//                                 context: context,
//                                 addingItem: AddTool(
//                                   submit: () {
//                                     // ✅ STEP 6: Refresh list after submit
//                                     ref.invalidate(masterListProvider);
//                                   },
//                                 ),
//                               );
//                             } else if (value == "asset") {
//                               DialogPannelHelper().showAddPannel(
//                                 context: context,
//                                 addingItem: AddAsset(
//                                   submit: () {
//                                     ref.invalidate(masterListProvider);
//                                   },
//                                 ),
//                               );
//                             } else if (value == "mmd") {
//                               DialogPannelHelper().showAddPannel(
//                                 context: context,
//                                 addingItem: AddMmd(
//                                   submit: () {
//                                     ref.invalidate(masterListProvider);
//                                   },
//                                 ),
//                               );
//                             } else if (value == "consumable") {
//                               DialogPannelHelper().showAddPannel(
//                                 context: context,
//                                 addingItem: AddConsumable(
//                                   submit: () {
//                                     ref.invalidate(masterListProvider);
//                                   },
//                                 ),
//                               );
//                             }
//                           });
//                         },
//                         itemBuilder: (context) => const [
//                           PopupMenuItem(
//                             value: "tool",
//                             child: Text(
//                               "Add tool",
//                               style: TextStyle(
//                                 color: Color(0xff00599A),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           PopupMenuDivider(height: 1, thickness: 1, color: Color(0xff00599A)),
//                           PopupMenuItem(
//                             value: "asset",
//                             child: Text(
//                               "Add asset",
//                               style: TextStyle(
//                                 color: Color(0xff00599A),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           PopupMenuDivider(height: 1, thickness: 1, color: Color(0xff00599A)),
//                           PopupMenuItem(
//                             value: "mmd",
//                             child: Text(
//                               "Add MMD",
//                               style: TextStyle(
//                                 color: Color(0xff00599A),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                           PopupMenuDivider(height: 1, thickness: 1, color: Color(0xff00599A)),
//                           PopupMenuItem(
//                             value: "consumable",
//                             child: Text(
//                               "Add consumable",
//                               style: TextStyle(
//                                 color: Color(0xff00599A),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ],
//                         child: ElevatedButton(
//                           onPressed: null,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xff00599A),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Add new item",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               Icon(Icons.keyboard_arrow_down, color: Colors.white),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/dialogs/dialog_pannel_helper.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/selection_provider.dart';
import 'package:inventory/screens/add_forms/add_asset.dart';
import 'package:inventory/screens/add_forms/add_consumable.dart';
import 'package:inventory/screens/add_forms/add_mmd.dart';
import 'package:inventory/screens/add_forms/add_tool.dart';
import 'package:inventory/services/export_service.dart';
import 'package:inventory/services/delete_service.dart';

class TopLayer extends ConsumerWidget {
  const TopLayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedItems = ref.watch(selectedItemsProvider);
    final masterListAsync = ref.watch(masterListProvider);
    final hasSelection = selectedItems.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 440,
                height: 35,
                child: SearchBar(
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: const WidgetStatePropertyAll(Colors.white),
                  hintText: 'Search',
                  padding: const WidgetStatePropertyAll(
                    EdgeInsetsGeometry.only(left: 6, bottom: 2),
                  ),
                  hintStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.bodyMedium,
                  ),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Color(0xff909090),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  trailing: [
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        "assets/images/Vector.svg",
                        width: 12,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MaterialButton(
                      onPressed: hasSelection ? () => _handleDelete(context, ref) : null,
                      height: 45,
                      minWidth: 90,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: hasSelection
                              ? Theme.of(context).primaryColor
                              : const Color.fromRGBO(144, 144, 144, 1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Deactivate",
                        style: TextStyle(
                          color: hasSelection
                              ? Theme.of(context).primaryColor
                              : const Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),

                    MaterialButton(
                      onPressed: () => _handleExport(context, ref),
                      height: 45,
                      minWidth: 90,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Export",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    SizedBox(
                      width: 160,
                      height: 42,
                      child: PopupMenuButton<String>(
                        color: Colors.white,
                        elevation: 0,
                        offset: const Offset(0, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Color(0xff00599A),
                            width: 1,
                          ),
                        ),
                        onSelected: (value) {
                          Future.delayed(const Duration(milliseconds: 150), () {
                            if (value == "tool") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddTool(
                                  submit: () async {
                                    print('DEBUG: TopLayer - Tool submitted, refreshing master list');
                                    await ref.read(refreshMasterListProvider)();
                                  },
                                ),
                              );
                            } else if (value == "asset") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddAsset(
                                  submit: () async {
                                    print('DEBUG: TopLayer - Asset submitted, refreshing master list');
                                    await ref.read(refreshMasterListProvider)();
                                  },
                                ),
                              );
                            } else if (value == "mmd") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddMmd(
                                  submit: () async {
                                    print('DEBUG: TopLayer - MMD submitted, refreshing master list');
                                    await ref.read(refreshMasterListProvider)();
                                  },
                                ),
                              );
                            } else if (value == "consumable") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddConsumable(
                                  submit: () async {
                                    print('DEBUG: TopLayer - Consumable submitted, refreshing master list');
                                    await ref.read(refreshMasterListProvider)();
                                  },
                                ),
                              );
                            }
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: "tool",
                            child: Text(
                              "Add tool",
                              style: TextStyle(
                                color: Color(0xff00599A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const PopupMenuDivider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xff00599A),
                          ),
                          const PopupMenuItem(
                            value: "asset",
                            child: Text(
                              "Add asset",
                              style: TextStyle(
                                color: Color(0xff00599A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const PopupMenuDivider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xff00599A),
                          ),
                          const PopupMenuItem(
                            value: "mmd",
                            child: Text(
                              "Add MMD",
                              style: TextStyle(
                                color: Color(0xff00599A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const PopupMenuDivider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xff00599A),
                          ),
                          const PopupMenuItem(
                            value: "consumable",
                            child: Text(
                              "Add consumable",
                              style: TextStyle(
                                color: Color(0xff00599A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        child: ElevatedButton(
                          onPressed: null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff00599A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Add new item",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context, WidgetRef ref) async {
    print(' _handleDelete called');
    final selectedItems = ref.read(selectedItemsProvider);
    final masterListAsync = ref.read(masterListProvider);
    
    print(' Selected items: $selectedItems');
    
    if (selectedItems.isEmpty) {
      print(' No items selected, returning');
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: Text('Are you sure you want to deactivate ${selectedItems.length} item(s)? They will be hidden from the active inventory list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    print(' Confirmation result: $confirmed');
    if (confirmed != true) return;

    // Use a completer to control dialog lifecycle
    bool isDialogOpen = false;
    
    try {
      // Show loading dialog and track it
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          isDialogOpen = true;
          return WillPopScope(
            onWillPop: () async => false, // Prevent back button from closing
            child: const AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Deactivating items...'),
                ],
              ),
            ),
          );
        },
      );

      print('🔥 Loading dialog shown, starting delete process');

      // Get the current state of masterListAsync
      final asyncValue = masterListAsync;
      print('🔥 AsyncValue state: hasValue=${asyncValue.hasValue}, isLoading=${asyncValue.isLoading}, hasError=${asyncValue.hasError}');
      
      if (asyncValue.hasValue) {
        final items = asyncValue.value!;
        print('🔥 Found ${items.length} items in master list');
        
        // Create map of selected items with their types
        Map<String, String> itemsToDelete = {};
        for (String selectedId in selectedItems) {
          try {
            final item = items.firstWhere((item) => item.refId == selectedId);
            itemsToDelete[selectedId] = item.itemType;
            print('🔥 Found item: ${item.refId} of type: ${item.itemType}');
          } catch (e) {
            print('🔥 Error finding item with ID $selectedId: $e');
            continue;
          }
        }

        print('🔥 Items to delete: $itemsToDelete');

        if (itemsToDelete.isEmpty) {
          print('🔥 No valid items to delete');
          if (isDialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            isDialogOpen = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid items found to deactivate'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        print('🔥 Starting delete operation...');
        final results = await DeleteService.deleteMultipleItems(itemsToDelete);
        
        print('🔥 Delete results: $results');
        
        // Count successful deletions
        int successCount = results.values.where((success) => success).length;
        int failCount = results.length - successCount;

        print('🔥 Success: $successCount, Failed: $failCount');

        // Close loading dialog using rootNavigator
        if (isDialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
          print('🔥 Loading dialog closed');
        }

        // Clear selection immediately
        ref.read(selectedItemsProvider.notifier).clearAll();
        ref.read(selectAllProvider.notifier).set(false);

        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount == 0 
                  ? 'Successfully deactivated $successCount item(s)'
                  : 'Deactivated $successCount item(s), failed to deactivate $failCount item(s)',
            ),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        print('🔥 Result snackbar shown');

        // Refresh list
        ref.invalidate(masterListProvider);
        print('🔥 List refreshed');
        
      } else if (asyncValue.isLoading) {
        print('🔥 Data is loading');
        if (isDialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data is still loading, please wait...'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (asyncValue.hasError) {
        print('🔥 Data has error: ${asyncValue.error}');
        if (isDialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${asyncValue.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('🔥 Exception in _handleDelete: $e');
      // Ensure dialog is closed on any exception
      if (isDialogOpen) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
        } catch (popError) {
          print('🔥 Error closing dialog: $popError');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deactivating items: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    print('🔥 _handleDelete completed');
  }

  void _handleExport(BuildContext context, WidgetRef ref) async {
    print('🔥 _handleExport called');
    final masterListAsync = ref.read(masterListProvider);
    
    try {
      print('🔥 Starting export');

      // Get the current state of masterListAsync
      final asyncValue = masterListAsync;
      print('🔥 AsyncValue state: hasValue=${asyncValue.hasValue}, isLoading=${asyncValue.isLoading}, hasError=${asyncValue.hasError}');
      
      if (asyncValue.hasValue) {
        final items = asyncValue.value!;
        print('🔥 Found ${items.length} items to export');
        
        // Use the ExportService
        final result = await ExportService.exportToExcel(items);
        
        if (result != null) {
          print('🔥 Export successful: $result');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kIsWeb 
                ? 'CSV file downloaded successfully! (${items.length} items)'
                : 'CSV file saved successfully! (${items.length} items)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          print('🔥 Export failed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export failed. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
      } else if (asyncValue.isLoading) {
        print('🔥 Data is still loading');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data is still loading, please wait...'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (asyncValue.hasError) {
        print('🔥 Data has error: ${asyncValue.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${asyncValue.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('🔥 Exception in _handleExport: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    print('🔥 _handleExport completed');
  }
}
