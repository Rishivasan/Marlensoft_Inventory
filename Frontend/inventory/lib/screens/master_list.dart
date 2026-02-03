import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/selection_provider.dart';
import 'package:inventory/providers/search_provider.dart';
import 'package:inventory/providers/sorting_provider.dart';
import 'package:inventory/providers/product_state_provider.dart';
import 'package:inventory/utils/sorting_utils.dart';
import 'package:inventory/widgets/top_layer.dart';
import 'package:inventory/widgets/generic_paginated_table.dart';
import 'package:inventory/widgets/sortable_header.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/model/master_list_model.dart';

@RoutePage()
class MasterListScreen extends ConsumerWidget {
  const MasterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the master list async for loading states
    final masterListAsync = ref.watch(masterListProvider);
    // Watch the search query
    final searchQuery = ref.watch(masterListSearchQueryProvider);
    // Watch the sort state
    final sortState = ref.watch(sortProvider);

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
              data: (rawItems) {
                // Apply search filtering first
                List<MasterListModel> filteredItems = rawItems;
                if (searchQuery.isNotEmpty) {
                  filteredItems = filterMasterListItems(rawItems, searchQuery);
                }

                // Apply sorting to filtered data
                final sortedAndFilteredItems = SortingUtils.sortMasterList(
                  filteredItems,
                  sortState.sortColumn,
                  sortState.direction,
                );

                // Show message if no results found after filtering
                if (sortedAndFilteredItems.isEmpty && rawItems.isNotEmpty) {
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
                    data:
                        sortedAndFilteredItems, // Use directly sorted and filtered data
                    rowsPerPage: 7,
                    minWidth: 1570,
                    showCheckboxColumn: true,
                    onRowTap: (item) {
                      // Navigate to product detail screen when row is clicked
                      context.router.push(ProductDetailRoute(id: item.refId));
                    },
                    onSelectionChanged: (selectedItems) {
                      print("Selected ${selectedItems.length} items");
                      // Update the global selection provider
                      final selectedIds = selectedItems
                          .map((item) => item.refId)
                          .toSet();
                      ref.read(selectedItemsProvider.notifier).state =
                          selectedIds;
                    },
                    headers: [
                      SortableHeader(
                        title: "Item ID",
                        sortKey: "itemId",
                        width: 150,
                        sortProvider: sortProvider,
                      ),
                      SortableHeader(
                        title: "Type",
                        sortKey: "type",
                        width: 120,
                        sortProvider: sortProvider,
                      ),
                      SortableHeader(
                        title: "Item Name",
                        sortKey: "itemName",
                        width: 180,
                        sortProvider: sortProvider,
                      ),
                      SortableHeader(
                        title: "Supplier",
                        sortKey: "vendor",
                        width: 160,
                        sortProvider: sortProvider,
                      ),
                      SortableHeader(
                        title: "Location",
                        sortKey: "storageLocation",
                        width: 160,
                        sortProvider: sortProvider,
                      ),
                      // SortableHeader(
                      //   title: "Created Date",
                      //   sortKey: "createdDate",
                      //   width: 150,
                      //   sortProvider: sortProvider,
                      // ),
                      SortableHeader(
                        title: "Responsible Team",
                        sortKey: "responsibleTeam",
                        width: 180,
                        sortProvider: sortProvider,
                      ),

                      SortableHeader(
                        title: "Next Service Due",
                        sortKey: "nextServiceDue",
                        width: 150,
                        sortProvider: sortProvider,
                      ),
                      SortableHeader(
                        title: "Status",
                        sortKey: "availabilityStatus",
                        width: 140,
                        sortProvider: sortProvider,
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
                      // Container(
                      //   width: 150,
                      //   alignment: Alignment.centerLeft,
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: Text(
                      //     "${item.createdDate.day}/${item.createdDate.month}/${item.createdDate.year}",
                      //     style: Theme.of(context).textTheme.displayMedium!.copyWith(
                      //       fontWeight: FontWeight.w400,
                      //       fontSize: 11
                      //     ),
                      //   ),
                      // ),
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
                            // Watch for reactive state changes
                            final productState = ref.watch(productStateByIdProvider(item.assetId));
                            
                            // Use reactive state if available, otherwise fall back to item data
                            final nextServiceDue = productState?.nextServiceDue ?? 
                                (item.nextServiceDue != null
                                    ? "${item.nextServiceDue!.day}/${item.nextServiceDue!.month}/${item.nextServiceDue!.year}"
                                    : null);
                            
                            return Text(
                              nextServiceDue ?? "N/A",
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 11,
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
                            // Watch for reactive state changes
                            final productState = ref.watch(productStateByIdProvider(item.assetId));
                            
                            // Use reactive state if available, otherwise fall back to item data
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
