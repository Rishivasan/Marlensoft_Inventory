import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/providers/selection_provider.dart';
import 'package:inventory/providers/search_provider.dart';
import 'package:inventory/providers/sorting_provider.dart';
import 'package:inventory/providers/product_state_provider.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/widgets/top_layer.dart';
import 'package:inventory/widgets/sortable_header.dart';
import 'package:inventory/widgets/pagination_controls.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:provider/provider.dart' as provider;

@RoutePage()
class MasterListScreen extends ConsumerStatefulWidget {
  const MasterListScreen({super.key});

  @override
  ConsumerState<MasterListScreen> createState() => _MasterListScreenState();
}

class _MasterListScreenState extends ConsumerState<MasterListScreen> {
  
  void _toggleSelectAll(bool? value, List<MasterListModel> items) {
    final selectAllNotifier = ref.read(selectAllProvider.notifier);
    final selectedItemsNotifier = ref.read(selectedItemsProvider.notifier);
    
    final shouldSelectAll = value ?? false;
    selectAllNotifier.set(shouldSelectAll);
    
    if (shouldSelectAll) {
      // Select all items on current page using refId
      selectedItemsNotifier.selectAll(items);
    } else {
      // Deselect all items
      selectedItemsNotifier.clearAll();
    }
  }
  
  void _toggleItemSelection(String refId, bool? value) {
    print('DEBUG: _toggleItemSelection called for $refId with value $value');
    final selectedItemsNotifier = ref.read(selectedItemsProvider.notifier);
    final selectAllNotifier = ref.read(selectAllProvider.notifier);
    
    selectedItemsNotifier.toggleItem(refId);
    
    if (value == false) {
      // Uncheck "select all" if any item is unchecked
      selectAllNotifier.set(false);
    }
    
    print('DEBUG: Selected items count: ${ref.read(selectedItemsProvider).length}');
  }

  @override
  Widget build(BuildContext context) {
    // Watch the PAGINATED master list async for loading states
    final paginatedDataAsync = ref.watch(paginatedMasterListProvider);
    // Watch pagination state
    final paginationState = ref.watch(paginationProvider);
    // Watch the search query
    final searchQuery = ref.watch(masterListSearchQueryProvider);
    // Watch selection state
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
            child: paginatedDataAsync.when(
              data: (paginationModel) {
                final rawItems = paginationModel.items;
                
                // Populate NextServiceProvider with next service dates from the fetched data
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final nextServiceProvider = provider.Provider.of<NextServiceProvider>(context, listen: false);
                  for (final item in rawItems) {
                    if (item.nextServiceDue != null) {
                      nextServiceProvider.updateNextServiceDate(item.assetId, item.nextServiceDue!);
                    }
                  }
                });
                
                // Show message if no results found
                if (rawItems.isEmpty) {
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
                          searchQuery.isNotEmpty 
                              ? 'No results found for "$searchQuery"'
                              : 'No items found',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Try adjusting your search terms'
                              : 'Add items to get started',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildTable(context, ref, rawItems, selectedItems, selectAll),
                      ),
                    ),
                    
                    // Server-side pagination controls
                    PaginationControls(
                      currentPage: paginationState.currentPage,
                      totalPages: paginationState.totalPages,
                      rowsPerPage: paginationState.pageSize,
                      totalItems: paginationModel.totalCount,
                      onPageChanged: (page) {
                        ref.read(paginationProvider.notifier).setPage(page);
                        ref.invalidate(paginatedMasterListProvider);
                      },
                      onRowsPerPageChanged: (size) {
                        ref.read(paginationProvider.notifier).setPageSize(size);
                        ref.invalidate(paginatedMasterListProvider);
                      },
                    ),
                  ],
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

  Widget _buildTable(BuildContext context, WidgetRef ref, List<MasterListModel> items, Set<String> selectedItems, bool selectAll) {
    final ScrollController horizontalScrollController = ScrollController();

    return SingleChildScrollView(
      controller: horizontalScrollController,
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: 0.7,
                    child: Checkbox(
                      value: selectAll,
                      tristate: false,
                      onChanged: (val) => _toggleSelectAll(val, items),
                      activeColor: const Color(0xFF00599A),
                      checkColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                SortableHeader(
                  title: "Item ID",
                  sortKey: "itemId",
                  width: 150,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "itemId";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "itemId") {
                      // Same column clicked - toggle direction
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      // Different column clicked - start with ascending
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Type",
                  sortKey: "type",
                  width: 120,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "type";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "type") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Item Name",
                  sortKey: "itemName",
                  width: 180,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "itemName";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "itemName") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Supplier",
                  sortKey: "vendor",
                  width: 160,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "vendor";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "vendor") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Location",
                  sortKey: "storageLocation",
                  width: 160,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "storageLocation";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "storageLocation") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Responsible Team",
                  sortKey: "responsibleTeam",
                  width: 180,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "responsibleTeam";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "responsibleTeam") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Next Service Due",
                  sortKey: "nextServiceDue",
                  width: 150,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "nextServiceDue";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "nextServiceDue") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                SortableHeader(
                  title: "Status",
                  sortKey: "availabilityStatus",
                  width: 140,
                  sortProvider: sortProvider,
                  onTap: () {
                    final sortState = ref.read(sortProvider);
                    String sortColumn = "availabilityStatus";
                    String sortDirection;
                    
                    if (sortState.sortColumn == "availabilityStatus") {
                      sortDirection = sortState.direction == SortDirection.ascending ? "desc" : "asc";
                    } else {
                      sortDirection = "asc";
                    }
                    
                    ref.read(paginationProvider.notifier).setSorting(sortColumn, sortDirection);
                    ref.invalidate(paginatedMasterListProvider);
                  },
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: const Text(""),
                ),
              ],
            ),
          ),
          // Data rows
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: items.map((item) {
                  return InkWell(
                    onTap: () {
                      context.router.push(ProductDetailRoute(id: item.refId));
                    },
                    hoverColor: Colors.grey.shade100,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          // Checkbox with its own tap handler to prevent row click
                          GestureDetector(
                            onTap: () {
                              print('DEBUG: GestureDetector onTap called for ${item.refId}');
                              // Toggle checkbox without navigating
                              _toggleItemSelection(item.refId, !selectedItems.contains(item.refId));
                            },
                            child: Container(
                              width: 60,
                              alignment: Alignment.center,
                              color: Colors.transparent, // Make the entire area clickable
                              child: Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  value: selectedItems.contains(item.refId),
                                  onChanged: (value) => _toggleItemSelection(item.refId, value),
                                  activeColor: const Color(0xFF00599A),
                                  checkColor: Colors.white,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 150,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.assetId,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 120,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.type,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.assetName,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 160,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.supplier,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 160,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.location,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 180,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.responsibleTeam,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            width: 150,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final productState = ref.watch(productStateByIdProvider(item.assetId));
                                final nextServiceDue = productState?.nextServiceDue ?? 
                                    (item.nextServiceDue != null
                                        ? "${item.nextServiceDue!.year}-${item.nextServiceDue!.month.toString().padLeft(2, '0')}-${item.nextServiceDue!.day.toString().padLeft(2, '0')}"
                                        : null);
                                
                                return Text(
                                  nextServiceDue ?? "N/A",
                                  style: Theme.of(context).textTheme.displayMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 11,
                                        color: Colors.black,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 140,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(8.0),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final productState = ref.watch(productStateByIdProvider(item.assetId));
                                final availabilityStatus = productState?.availabilityStatus ?? item.availabilityStatus;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: availabilityStatus.toLowerCase() == 'available'
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: availabilityStatus.toLowerCase() == 'available'
                                          ? Colors.green
                                          : Colors.orange,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    availabilityStatus,
                                    style: Theme.of(context).textTheme.displayMedium!
                                        .copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          color: availabilityStatus.toLowerCase() == 'available'
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 50,
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () {
                                context.router.push(
                                  ProductDetailRoute(id: item.refId),
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/images/Select_arrow.svg",
                                width: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
