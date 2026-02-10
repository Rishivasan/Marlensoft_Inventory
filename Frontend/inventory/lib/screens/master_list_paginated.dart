import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/pagination_provider.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/services/next_service_sync_service.dart';
import 'package:inventory/widgets/pagination_bar.dart';
import 'package:inventory/routers/app_router.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:provider/provider.dart' as provider;
//import 'package:intl/intl.dart';
import 'package:intl/intl.dart';


@RoutePage()
class MasterListPaginatedScreen extends ConsumerStatefulWidget {
  const MasterListPaginatedScreen({super.key});

  @override
  ConsumerState<MasterListPaginatedScreen> createState() => _MasterListPaginatedScreenState();
}

class _MasterListPaginatedScreenState extends ConsumerState<MasterListPaginatedScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Track selected items
  final Set<String> _selectedItems = {};
  bool _selectAll = false;
  bool _hasInitialSyncCompleted = false; // Track if we've done the initial sync

  @override
  void initState() {
    super.initState();
    // Trigger initial sync of Next Service Due dates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performInitialNextServiceSync();
    });
  }

  // Perform initial sync of Next Service Due dates from maintenance records
  Future<void> _performInitialNextServiceSync() async {
    if (_hasInitialSyncCompleted) return;
    
    try {
      print('DEBUG: Starting initial Next Service Due sync for master list');
      final syncService = ref.read(nextServiceSyncServiceProvider);
      
      // Get current pagination data to sync only visible items first
      final paginatedDataAsync = ref.read(paginatedMasterListProvider);
      
      paginatedDataAsync.whenData((paginationModel) async {
        if (paginationModel.items.isNotEmpty) {
          final assetIds = paginationModel.items.map((item) => item.assetId).toList();
          await syncService.syncNextServiceDueForAssets(assetIds, ref);
          print('DEBUG: Completed initial sync for ${assetIds.length} visible items');
          
          // Mark sync as completed
          _hasInitialSyncCompleted = true;
          
          // Optionally sync all other items in background (don't await)
          syncService.syncAllAssetsNextServiceDue(ref).then((_) {
            print('DEBUG: Background sync of all assets completed');
          }).catchError((e) {
            print('DEBUG: Background sync failed: $e');
          });
        }
      });
    } catch (e) {
      print('DEBUG: Error during initial Next Service Due sync: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _toggleSelectAll(bool? value, List<MasterListModel> items) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        // Select all items on current page
        _selectedItems.addAll(items.map((item) => item.assetId));
      } else {
        // Deselect all items on current page
        for (var item in items) {
          _selectedItems.remove(item.assetId);
        }
      }
    });
  }
  
  void _toggleItemSelection(String assetId, bool? value) {
    setState(() {
      if (value == true) {
        _selectedItems.add(assetId);
      } else {
        _selectedItems.remove(assetId);
        _selectAll = false; // Uncheck "select all" if any item is unchecked
      }
    });
  }

  void _onSearch() {
    ref.read(paginationProvider.notifier).setSearchText(_searchController.text);
    ref.invalidate(paginatedMasterListProvider);
  }

  void _onPageChanged() {
    ref.invalidate(paginatedMasterListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final paginatedDataAsync = ref.watch(paginatedMasterListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Table
            Expanded(
              child: paginatedDataAsync.when(
                data: (paginationModel) {
                  // Populate NextServiceProvider and sync Next Service Due dates
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final nextServiceProvider = provider.Provider.of<NextServiceProvider>(context, listen: false);
                    for (final item in paginationModel.items) {
                      if (item.nextServiceDue != null) {
                        nextServiceProvider.updateNextServiceDate(item.assetId, item.nextServiceDue!);
                      }
                    }
                    
                    // Sync Next Service Due dates for items on this page (if not already done)
                    if (!_hasInitialSyncCompleted) {
                      _performInitialNextServiceSync();
                    } else {
                      // For subsequent page loads, sync just the new items
                      final syncService = ref.read(nextServiceSyncServiceProvider);
                      final assetIds = paginationModel.items.map((item) => item.assetId).toList();
                      syncService.syncNextServiceDueForAssets(assetIds, ref).then((_) {
                        print('DEBUG: Synced Next Service Due for page items');
                      }).catchError((e) {
                        print('DEBUG: Page sync failed: $e');
                      });
                    }
                  });

                  if (paginationModel.items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildTable(paginationModel.items);
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(paginatedMasterListProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pagination Bar
            PaginationBar(onPageChanged: _onPageChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Title
          const Text(
            'Tools, Assets, MMDs & Consumables Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),

          // Search
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Search'),
          ),
          const SizedBox(width: 12),

          // Add New Item Button
          ElevatedButton.icon(
            onPressed: () {
              // Add new item logic
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add new Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066CC),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(List<MasterListModel> items) {
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(50),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1),
          3: FlexColumnWidth(1.5),
          4: FlexColumnWidth(1.5),
          5: FlexColumnWidth(1.5),
          6: FlexColumnWidth(1.5),
          7: FlexColumnWidth(1.5),
          8: FlexColumnWidth(1),
          9: FixedColumnWidth(80),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          // Header Row
          TableRow(
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
            ),
            children: [
              _buildHeaderCellWithCheckbox(items),
              _buildHeaderCell('Item ID'),
              _buildHeaderCell('Type'),
              _buildHeaderCell('Item Name'),
              _buildHeaderCell('Supplier'),
              _buildHeaderCell('Location'),
              _buildHeaderCell('Responsible Team'),
              _buildHeaderCell('Next Service Due'),
              _buildHeaderCell('Status'),
              _buildHeaderCell(''),
            ],
          ),

          // Data Rows
          ...items.map((item) => _buildDataRow(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCellWithCheckbox(List<MasterListModel> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Checkbox(
        value: _selectAll,
        onChanged: (value) => _toggleSelectAll(value, items),
        activeColor: const Color(0xFF0066CC),
      ),
    );
  }

  TableRow _buildDataRow(MasterListModel item) {
    final isSelected = _selectedItems.contains(item.assetId);
    
    return TableRow(
      children: [
        _buildDataCell(
          Checkbox(
            value: isSelected,
            onChanged: (value) => _toggleItemSelection(item.assetId, value),
            activeColor: const Color(0xFF0066CC),
          ),
        ),
        _buildDataCell(Text(item.assetId)),
        _buildDataCell(Text(item.type)),
        _buildDataCell(Text(item.name)),
        _buildDataCell(Text(item.supplier)),
        _buildDataCell(Text(item.location)),
        _buildDataCell(Text(item.responsibleTeam)),
        _buildDataCell(
          Text(
            item.nextServiceDue != null
                ? DateFormat('yyyy-MM-dd').format(item.nextServiceDue!)
                : '-',
          ),
        ),
        _buildDataCell(_buildStatusBadge(item.availabilityStatus)),
        _buildDataCell(
          IconButton(
            icon: const Icon(Icons.arrow_forward, size: 18),
            onPressed: () {
              context.router.push(
                ProductDetailRoute(id: item.refId),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: child,
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'available':
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'allocated':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'in use':
        backgroundColor = const Color(0xFFFED7AA);
        textColor = const Color(0xFF9A3412);
        break;
      default:
        backgroundColor = const Color(0xFFE5E7EB);
        textColor = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
