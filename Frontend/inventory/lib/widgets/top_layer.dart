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
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/providers/selection_provider.dart';
import 'package:inventory/screens/add_forms/add_asset.dart';
import 'package:inventory/screens/add_forms/add_consumable.dart';
import 'package:inventory/screens/add_forms/add_mmd.dart';
import 'package:inventory/screens/add_forms/add_tool.dart';
import 'package:inventory/services/export_service.dart';
import 'package:inventory/services/delete_service.dart';

class TopLayer extends ConsumerStatefulWidget {
  const TopLayer({super.key});

  @override
  ConsumerState<TopLayer> createState() => _TopLayerState();
}

class _TopLayerState extends ConsumerState<TopLayer> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current search query from pagination provider
    _searchController.text = ref.read(paginationProvider).searchText;
    
    // Listen to search controller changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer for debounced search
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      // Update pagination provider's search text (used by paginated master list)
      ref.read(paginationProvider.notifier).setSearchText(_searchController.text);
      // Also invalidate the paginated provider to trigger refresh
      ref.invalidate(paginatedMasterListProvider);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    // Clear search in pagination provider
    ref.read(paginationProvider.notifier).setSearchText('');
    // Invalidate to trigger refresh
    ref.invalidate(paginatedMasterListProvider);
  }

  @override
  Widget build(BuildContext context) {
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                    contentPadding: const EdgeInsets.only(left: 12, bottom: 2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xff909090),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xff909090),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xff00599A),
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(
                              Icons.clear,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              // Focus the text field when search icon is pressed
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            icon: SvgPicture.asset(
                              "assets/images/Vector.svg",
                              width: 12,
                            ),
                          ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) {
                    setState(() {}); // Rebuild to show/hide clear button
                  },
                ),
              ),

              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Delete Button
                    _buildOutlineButton(
                      text: "Delete",
                      onPressed: hasSelection ? () => _handleDelete(context, ref) : null,
                      isEnabled: hasSelection,
                    ),
                    const SizedBox(width: 20),

                    // Export Button  
                    _buildOutlineButton(
                      text: "Export",
                      onPressed: hasSelection ? () => _handleExport(context, ref) : null,
                      isEnabled: hasSelection,
                    ),
                    const SizedBox(width: 20),

                    // Add new item button
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
                                    // Small delay to ensure database transaction completes
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    // Force refresh both paginated and non-paginated master lists
                                    await ref.read(forceRefreshMasterListProvider)();
                                    ref.invalidate(paginatedMasterListProvider);
                                  },
                                ),
                              );
                            } else if (value == "asset") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddAsset(
                                  submit: () async {
                                    print('DEBUG: TopLayer - Asset submitted, refreshing master list');
                                    // Small delay to ensure database transaction completes
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    // Force refresh both paginated and non-paginated master lists
                                    await ref.read(forceRefreshMasterListProvider)();
                                    ref.invalidate(paginatedMasterListProvider);
                                  },
                                ),
                              );
                            } else if (value == "mmd") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddMmd(
                                  submit: () async {
                                    print('DEBUG: TopLayer - MMD submitted, refreshing master list');
                                    // Small delay to ensure database transaction completes
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    // Force refresh both paginated and non-paginated master lists
                                    await ref.read(forceRefreshMasterListProvider)();
                                    ref.invalidate(paginatedMasterListProvider);
                                  },
                                ),
                              );
                            } else if (value == "consumable") {
                              DialogPannelHelper().showAddPannel(
                                context: context,
                                addingItem: AddConsumable(
                                  submit: () async {
                                    print('DEBUG: TopLayer - Consumable submitted, refreshing master list');
                                    // Small delay to ensure database transaction completes
                                    await Future.delayed(const Duration(milliseconds: 300));
                                    // Force refresh both paginated and non-paginated master lists
                                    await ref.read(forceRefreshMasterListProvider)();
                                    ref.invalidate(paginatedMasterListProvider);
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

  // Helper method to build outline buttons with hover effects
  Widget _buildOutlineButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return SizedBox(
      width: 90, // Fixed width to match button size
      height: 42, // Same height as "Add new item" button
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        child: StatefulBuilder(
          builder: (context, setState) {
            bool isHovered = false;
            
            return MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: isEnabled 
                      ? (isHovered ? const Color(0xff00599A) : const Color(0xFF6B7280))
                      : const Color(0xFF9CA3AF),
                  side: BorderSide(
                    color: isEnabled 
                        ? (isHovered ? const Color(0xff00599A) : const Color(0xFFD1D5DB))
                        : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // Reduced horizontal padding, zero vertical padding
                  minimumSize: const Size(90, 42), // Ensure minimum size
                  fixedSize: const Size(90, 42), // Force exact size
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isEnabled 
                        ? (isHovered ? const Color(0xff00599A) : const Color(0xFF6B7280))
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
            );
          },
        ),
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
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${selectedItems.length} item(s)? They will be permanently removed from the inventory.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Delete'),
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
                  Text('Deleting items...'),
                ],
              ),
            ),
          );
        },
      );

      print('Loading dialog shown, starting delete process');

      // Get the current state of masterListAsync
      final asyncValue = masterListAsync;
      print('AsyncValue state: hasValue=${asyncValue.hasValue}, isLoading=${asyncValue.isLoading}, hasError=${asyncValue.hasError}');
      
      if (asyncValue.hasValue) {
        final items = asyncValue.value!;
        print('Found ${items.length} items in master list');
        
        // Create map of selected items with their types
        Map<String, String> itemsToDelete = {};
        for (String selectedId in selectedItems) {
          try {
            final item = items.firstWhere((item) => item.refId == selectedId);
            itemsToDelete[selectedId] = item.itemType;
            print('Found item: ${item.refId} of type: ${item.itemType}');
          } catch (e) {
            print('Error finding item with ID $selectedId: $e');
            continue;
          }
        }

        print('Items to delete: $itemsToDelete');

        if (itemsToDelete.isEmpty) {
          print('No valid items to delete');
          if (isDialogOpen) {
            Navigator.of(context, rootNavigator: true).pop();
            isDialogOpen = false;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid items found to delete'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        print('Starting delete operation...');
        final results = await DeleteService.deleteMultipleItems(itemsToDelete);
        
        print('Delete results: $results');
        
        // Count successful deletions
        int successCount = results.values.where((success) => success).length;
        int failCount = results.length - successCount;

        print('Success: $successCount, Failed: $failCount');

        // Close loading dialog using rootNavigator
        if (isDialogOpen) {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
          print('Loading dialog closed');
        }

        // Clear selection immediately
        ref.read(selectedItemsProvider.notifier).clearAll();
        ref.read(selectAllProvider.notifier).set(false);

        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failCount == 0 
                  ? 'Successfully deleted $successCount item(s)'
                  : 'Deleted $successCount item(s), failed to delete $failCount item(s)',
            ),
            backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );

        print('Result snackbar shown');

        // Force refresh both master list providers using the helper providers
        await ref.read(forceRefreshMasterListProvider)();
        await ref.read(refreshPaginatedMasterListProvider)();
        print('List refreshed');
        
      } else if (asyncValue.isLoading) {
        print('Data is loading');
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
        print('Data has error: ${asyncValue.error}');
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
      print('Exception in _handleDelete: $e');
      // Ensure dialog is closed on any exception
      if (isDialogOpen) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          isDialogOpen = false;
        } catch (popError) {
          print('Error closing dialog: $popError');
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting items: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    print('_handleDelete completed');
  }

  void _handleExport(BuildContext context, WidgetRef ref) async {
    print('_handleExport called');
    final selectedItems = ref.read(selectedItemsProvider);
    final masterListAsync = ref.read(masterListProvider);
    
    // Check if any items are selected
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to export'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    try {
      print('Starting export for ${selectedItems.length} selected items');

      // Get the current state of masterListAsync
      final asyncValue = masterListAsync;
      print('AsyncValue state: hasValue=${asyncValue.hasValue}, isLoading=${asyncValue.isLoading}, hasError=${asyncValue.hasError}');
      
      if (asyncValue.hasValue) {
        final allItems = asyncValue.value!;
        print('Found ${allItems.length} total items');
        
        // Filter to only selected items
        final itemsToExport = allItems.where((item) => selectedItems.contains(item.refId)).toList();
        print('Filtered to ${itemsToExport.length} selected items for export');
        
        if (itemsToExport.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selected items not found in current data'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        
        // Use the ExportService
        final result = await ExportService.exportToExcel(itemsToExport);
        
        if (result != null) {
          print('Export successful: $result');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(kIsWeb 
                ? 'Excel file downloaded successfully! (${itemsToExport.length} items)'
                : 'Excel file saved successfully! (${itemsToExport.length} items)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          print('Export failed');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export failed. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        
      } else if (asyncValue.isLoading) {
        print('Data is still loading');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data is still loading, please wait...'),
            backgroundColor: Colors.orange,
          ),
        );
      } else if (asyncValue.hasError) {
        print('Data has error: ${asyncValue.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${asyncValue.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print(' Exception in _handleExport: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    print(' _handleExport completed');
  }
}
