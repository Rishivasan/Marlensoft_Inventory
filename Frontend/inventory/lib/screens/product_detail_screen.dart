import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/dialogs/dialog_pannel_helper.dart';
import 'package:inventory/screens/add_forms/add_maintenance_service.dart';
import 'package:inventory/screens/add_forms/add_allocation.dart';
import 'package:inventory/screens/add_forms/add_mmd.dart';
import 'package:inventory/screens/add_forms/add_tool.dart';
import 'package:inventory/screens/add_forms/add_asset.dart';
import 'package:inventory/screens/add_forms/add_consumable.dart';
import 'package:inventory/providers/header_state.dart';
import 'package:inventory/providers/search_provider.dart';
import 'package:inventory/providers/sorting_provider.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/product_state_provider.dart';
import 'package:inventory/widgets/generic_paginated_table.dart';
import 'package:inventory/widgets/sortable_header.dart';
import 'package:inventory/utils/sorting_utils.dart';
import 'package:auto_route/auto_route.dart';
import 'dart:async';

@RoutePage()
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with TickerProviderStateMixin {
  MasterListModel? productData;
  List<MaintenanceModel> maintenanceRecords = [];
  List<AllocationModel> allocationRecords = [];
  List<MaintenanceModel> filteredMaintenanceRecords = [];
  List<AllocationModel> filteredAllocationRecords = [];
  bool loading = true;
  bool loadingMaintenance = true;
  bool loadingAllocation = true;
  bool _isRefreshingMasterList = false; // Flag to prevent multiple simultaneous refreshes
  late TabController _tabController;

  // Search controllers
  final TextEditingController _maintenanceSearchController =
      TextEditingController();
  final TextEditingController _allocationSearchController =
      TextEditingController();
  Timer? _maintenanceDebounceTimer;
  Timer? _allocationDebounceTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize search controllers
    _maintenanceSearchController.addListener(_onMaintenanceSearchChanged);
    _allocationSearchController.addListener(_onAllocationSearchChanged);

    // Set header for Product Detail page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(headerProvider.notifier).state = const HeaderModel(
        title: "Products",
        subtitle:
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
      );
    });

    _loadProductData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _maintenanceSearchController.dispose();
    _allocationSearchController.dispose();
    _maintenanceDebounceTimer?.cancel();
    _allocationDebounceTimer?.cancel();

    // Reset header when leaving the page
    //  ref.read(headerProvider.notifier).state = const HeaderModel(
    //     title: "Dashboard",
    //     subtitle: "Welcome! Select a menu to view details.",
    //   );

    super.dispose();
  }

  void _onMaintenanceSearchChanged() {
    _maintenanceDebounceTimer?.cancel();
    _maintenanceDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredMaintenanceRecords = filterMaintenanceRecords(
          maintenanceRecords,
          _maintenanceSearchController.text,
        );
      });
    });
  }

  void _onAllocationSearchChanged() {
    _allocationDebounceTimer?.cancel();
    _allocationDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredAllocationRecords = filterAllocationRecords(
          allocationRecords,
          _allocationSearchController.text,
        );
      });
    });
  }

  void _clearMaintenanceSearch() {
    _maintenanceSearchController.clear();
    setState(() {
      filteredMaintenanceRecords = maintenanceRecords;
    });
  }

  void _clearAllocationSearch() {
    _allocationSearchController.clear();
    setState(() {
      filteredAllocationRecords = allocationRecords;
    });
  }

  Future<void> _loadProductData() async {
    print('DEBUG: Loading product data for ID: ${widget.id}');
    try {
      final apiService = ApiService();
      final data = await apiService.getMasterListById(widget.id);

      if (data != null) {
        print('DEBUG: Product data loaded successfully:');
        print('  - Name: ${data.name}');
        print('  - Type: ${data.type}');
        print('  - ItemType: ${data.itemType}');
        print('  - Supplier: ${data.supplier}');
        print('  - Location: ${data.location}');
        print('  - ResponsibleTeam: ${data.responsibleTeam}');
        print('  - AvailabilityStatus: ${data.availabilityStatus}');

        setState(() {
          productData = data;
          loading = false;
        });

        // Load maintenance and allocation data after product data is loaded
        print('DEBUG: Loading maintenance data for assetId: ${data.assetId}');
        _loadMaintenanceData(data.assetId);
        _loadAllocationData(data.assetId);
      } else {
        print('DEBUG: No product data found, using placeholder');
        // If no data found, create a placeholder with the ID
        setState(() {
          productData = _createPlaceholderData(widget.id);
          loading = false;
        });
        _loadMaintenanceData(widget.id);
        _loadAllocationData(widget.id);
      }
    } catch (e) {
      print('DEBUG: Error loading product data: $e');
      setState(() {
        productData = _createPlaceholderData(widget.id);
        loading = false;
      });
      _loadMaintenanceData(widget.id);
      _loadAllocationData(widget.id);
    }
  }

  MasterListModel _createPlaceholderData(String id) {
    return MasterListModel(
      sno: 0,
      itemType: 'Unknown',
      refId: id,
      assetId: id,
      type: 'Unknown',
      name: 'Item $id',
      supplier: 'Unknown',
      location: 'Unknown',
      createdDate: DateTime.now(),
      responsibleTeam: 'Unknown',
      nextServiceDue: null,
      availabilityStatus: 'Unknown',
    );
  }

  // Helper method to safely refresh master list data
  Future<void> _safeRefreshMasterList() async {
    print('DEBUG: _safeRefreshMasterList - Called');
    
    // Prevent multiple simultaneous refreshes
    if (_isRefreshingMasterList) {
      print('DEBUG: _safeRefreshMasterList - Already refreshing, skipping');
      return;
    }
    
    if (!mounted) {
      print('DEBUG: _safeRefreshMasterList - Widget not mounted, returning');
      return;
    }
    
    _isRefreshingMasterList = true;
    
    try {
      print('DEBUG: _safeRefreshMasterList - Calling forceRefreshMasterListProvider');
      await ref.read(forceRefreshMasterListProvider)();
      print('DEBUG: _safeRefreshMasterList - Successfully refreshed master list');
    } catch (e) {
      print('DEBUG: _safeRefreshMasterList - Error refreshing master list: $e');
    } finally {
      _isRefreshingMasterList = false;
    }
  }

  Future<void> _loadMaintenanceData(String assetId) async {
    print('DEBUG: _loadMaintenanceData called with assetId: $assetId');
    setState(() {
      loadingMaintenance = true;
    });

    try {
      final apiService = ApiService();
      print('DEBUG: Calling getMaintenanceByAssetId with: $assetId');
      final maintenance = await apiService.getMaintenanceByAssetId(assetId);

      print('DEBUG: Maintenance API returned ${maintenance.length} records');

      // If no data from API, add some sample data for testing UI
      List<MaintenanceModel> finalMaintenanceList = maintenance;
      if (maintenance.isEmpty) {
        print(
          'DEBUG: No maintenance data from API, adding sample data for UI testing',
        );
        finalMaintenanceList = [
          MaintenanceModel(
            maintenanceId: 1,
            assetType: 'MMD',
            assetId: assetId,
            itemName: 'Sample Item',
            serviceDate: DateTime(2024, 4, 6),
            serviceProviderCompany: 'ABC Calibration Lab',
            serviceEngineerName: 'Ravi',
            serviceType: 'Calibration',
            nextServiceDue: DateTime(2024, 12, 1),
            serviceNotes: 'Calibration completed',
            maintenanceStatus: 'Completed',
            cost: 5000.0,
            responsibleTeam: 'Production Team A',
            createdDate: DateTime.now(),
          ),
          MaintenanceModel(
            maintenanceId: 2,
            assetType: 'Tool',
            assetId: assetId,
            itemName: 'Sample Item',
            serviceDate: DateTime(2024, 3, 15),
            serviceProviderCompany: 'TechFix Pros',
            serviceEngineerName: 'Alex Turner',
            serviceType: 'Preventive',
            nextServiceDue: DateTime(2024, 9, 15),
            serviceNotes: 'Routine maintenance',
            maintenanceStatus: 'Completed',
            cost: 2300.0,
            responsibleTeam: 'Production Team B',
            createdDate: DateTime.now(),
          ),
        ];
      }

      setState(() {
        maintenanceRecords = finalMaintenanceList;
        filteredMaintenanceRecords =
            finalMaintenanceList; // Initialize filtered list
        loadingMaintenance = false;
      });

      if (finalMaintenanceList.isEmpty) {
        print('DEBUG: No maintenance records found for asset: $assetId');
      } else {
        print(
          'DEBUG: Found maintenance records: ${finalMaintenanceList.map((m) => '${m.serviceProviderCompany} - ${m.serviceType}').toList()}',
        );
      }
    } catch (e) {
      print('DEBUG: Error loading maintenance data: $e');
      setState(() {
        loadingMaintenance = false;
      });
    }
  }

  Future<void> _loadAllocationData(String assetId) async {
    print('DEBUG: _loadAllocationData called with assetId: $assetId');
    setState(() {
      loadingAllocation = true;
    });

    try {
      final apiService = ApiService();
      print('DEBUG: Calling getAllocationsByAssetId with: $assetId');
      final allocations = await apiService.getAllocationsByAssetId(assetId);

      print('DEBUG: Allocation API returned ${allocations.length} records');

      // If no data from API, add some sample data for testing UI
      List<AllocationModel> finalAllocationList = allocations;
      if (allocations.isEmpty) {
        print(
          'DEBUG: No allocation data from API, adding sample data for UI testing',
        );
        finalAllocationList = [
          AllocationModel(
            allocationId: 1,
            assetType: 'Tool',
            assetId: assetId,
            itemName: 'Sample Item',
            employeeId: 'EMP05322',
            employeeName: 'John Smith',
            teamName: 'Production Team A',
            purpose: 'Manufacturing',
            issuedDate: DateTime(2026, 1, 28),
            expectedReturnDate: DateTime(2026, 1, 29),
            actualReturnDate: DateTime(2026, 1, 30),
            availabilityStatus: 'Overdue',
            createdDate: DateTime.now(),
          ),
        ];
      }

      setState(() {
        allocationRecords = finalAllocationList;
        filteredAllocationRecords =
            finalAllocationList; // Initialize filtered list
        loadingAllocation = false;
      });

      if (finalAllocationList.isEmpty) {
        print('DEBUG: No allocation records found for asset: $assetId');
      } else {
        print(
          'DEBUG: Found allocation records: ${finalAllocationList.map((a) => '${a.employeeName} - ${a.purpose}').toList()}',
        );
      }
    } catch (e) {
      print('DEBUG: Error loading allocation data: $e');
      setState(() {
        loadingAllocation = false;
      });
    }
  }

  void _openEditDialog() {
    if (productData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product data not loaded yet. Please wait.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final itemType = productData!.itemType.toLowerCase();
    final assetType = productData!.type.toLowerCase();
    final itemName = productData!.name.toLowerCase();
    final assetId = productData!.assetId.toLowerCase();

    print(
      'DEBUG: Opening edit dialog for item type: $itemType, asset type: $assetType, name: $itemName, assetId: $assetId',
    );

    Widget? editForm;
    String dialogType = '';

    // Enhanced item type detection with priority order
    if (_isMMDType(itemType, assetType, itemName, assetId)) {
      dialogType = 'MMD';
      editForm = AddMmd(
        submit: () async {
          // Add small delay to ensure database transaction commits
          await Future.delayed(const Duration(milliseconds: 300));
          // Refresh product detail data
          await _loadProductData();
          
          // Check if widget is still mounted before using ref
          if (!mounted) return;
          
          // Small delay to ensure database transaction completes
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Check if widget is still mounted before using ref
          if (!mounted) return;
          
          // Force refresh master list to update grid/pagination immediately
          await _safeRefreshMasterList();
          
          print('DEBUG: ProductDetail - MMD updated, refreshed both product data and master list');
        },
        existingData: productData, // Pass existing data
      );
    } else if (_isToolType(itemType, assetType, itemName, assetId)) {
      dialogType = 'Tool';
      editForm = AddTool(
        submit: () async {
          // Add small delay to ensure database transaction commits
          await Future.delayed(const Duration(milliseconds: 300));
          // Refresh product detail data
          await _loadProductData();
          // Small delay to ensure database transaction completes
          await Future.delayed(const Duration(milliseconds: 300));
          // Force refresh master list to update grid/pagination immediately
          await _safeRefreshMasterList();
          print('DEBUG: ProductDetail - Tool updated, refreshed both product data and master list');
        },
        existingData: productData, // Pass existing data
      );
    } else if (_isConsumableType(itemType, assetType, itemName, assetId)) {
      dialogType = 'Consumable';
      editForm = AddConsumable(
        submit: () async {
          // Add small delay to ensure database transaction commits
          await Future.delayed(const Duration(milliseconds: 300));
          // Refresh product detail data
          await _loadProductData();
          // Small delay to ensure database transaction completes
          await Future.delayed(const Duration(milliseconds: 300));
          // Force refresh master list to update grid/pagination immediately
          await _safeRefreshMasterList();
          print('DEBUG: ProductDetail - Consumable updated, refreshed both product data and master list');
        },
        existingData: productData, // Pass existing data
      );
    } else if (_isAssetType(itemType, assetType, itemName, assetId)) {
      dialogType = 'Asset';
      editForm = AddAsset(
        submit: () async {
          // Add small delay to ensure database transaction commits
          await Future.delayed(const Duration(milliseconds: 300));
          // Refresh product detail data
          await _loadProductData();
          // Small delay to ensure database transaction completes
          await Future.delayed(const Duration(milliseconds: 300));
          // Force refresh master list to update grid/pagination immediately
          await _safeRefreshMasterList();
          print('DEBUG: ProductDetail - Asset updated, refreshed both product data and master list');
        },
        existingData: productData, // Pass existing data
      );
    } else {
      // Default to Tool if no specific type is detected
      print(
        'DEBUG: Could not determine specific item type. Defaulting to Tool. ItemType: $itemType, AssetType: $assetType',
      );
      dialogType = 'Tool';
      editForm = AddTool(
        submit: () async {
          // Add small delay to ensure database transaction commits
          await Future.delayed(const Duration(milliseconds: 300));
          // Refresh product detail data
          await _loadProductData();
          // Small delay to ensure database transaction completes
          await Future.delayed(const Duration(milliseconds: 300));
          // Force refresh master list to update grid/pagination immediately
          await _safeRefreshMasterList();
          print('DEBUG: ProductDetail - Tool (default) updated, refreshed both product data and master list');
        },
        existingData: productData, // Pass existing data
      );
    }

    print('DEBUG: Opening $dialogType dialog for item: ${productData!.name}');

    DialogPannelHelper().showAddPannel(context: context, addingItem: editForm);
  }

  bool _isMMDType(
    String itemType,
    String assetType,
    String itemName,
    String assetId,
  ) {
    const mmdKeywords = [
      'mmd',
      'measuring',
      'monitoring',
      'device',
      'calibration',
      'meter',
      'gauge',
    ];
    return mmdKeywords.any(
      (keyword) =>
          itemType.contains(keyword) ||
          assetType.contains(keyword) ||
          itemName.contains(keyword) ||
          assetId.contains(keyword),
    );
  }

  bool _isToolType(
    String itemType,
    String assetType,
    String itemName,
    String assetId,
  ) {
    const toolKeywords = [
      'tool',
      'equipment',
      'instrument',
      'wrench',
      'drill',
      'hammer',
    ];
    return toolKeywords.any(
      (keyword) =>
          itemType.contains(keyword) ||
          assetType.contains(keyword) ||
          itemName.contains(keyword) ||
          assetId.contains(keyword),
    );
  }

  bool _isConsumableType(
    String itemType,
    String assetType,
    String itemName,
    String assetId,
  ) {
    const consumableKeywords = [
      'consumable',
      'material',
      'supply',
      'chemical',
      'reagent',
      'disposable',
    ];
    return consumableKeywords.any(
      (keyword) =>
          itemType.contains(keyword) ||
          assetType.contains(keyword) ||
          itemName.contains(keyword) ||
          assetId.contains(keyword),
    );
  }

  bool _isAssetType(
    String itemType,
    String assetType,
    String itemName,
    String assetId,
  ) {
    const assetKeywords = [
      'asset',
      'machine',
      'equipment',
      'furniture',
      'computer',
      'vehicle',
    ];
    return assetKeywords.any(
      (keyword) =>
          itemType.contains(keyword) ||
          assetType.contains(keyword) ||
          itemName.contains(keyword) ||
          assetId.contains(keyword),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : _buildUnifiedCard(),
    );
  }

  Widget _buildUnifiedCard() {
    return Container(
      height:
          MediaQuery.of(context).size.height - 16, // Full height minus padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Card Section - Fixed (non-scrollable)
          _buildProductCardContent(),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color.fromRGBO(144, 144, 144, 1),indent: 15,endIndent: 15,),

          // Tabs Section - Fixed (non-scrollable)
          _buildTabs(),

          // Tab Content Section - Expandable to fill remaining space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(), // Disable sliding
              children: [
                _buildMaintenanceTabContent(),
                _buildAllocationTabContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16), // Reduced from 20
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100, // Reduced from 120
            height: 100, // Reduced from 120
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6), // Reduced from 8
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/under_construction.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 32, // Reduced from 40
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16), // Reduced from 20
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productData?.name ?? 'Item ${widget.id}',
                            style: const TextStyle(
                              fontSize: 16, // Reduced from 18
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 2), // Reduced from 4
                          Text(
                            productData?.assetId ?? widget.id,
                            style: const TextStyle(
                              fontSize: 12, // Reduced from 14
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge - Reactive
                    Consumer(
                      builder: (context, ref, child) {
                        // Watch for reactive state changes
                        final productState = ref.watch(productStateByIdProvider(productData?.assetId ?? widget.id));
                        
                        // Use reactive state if available, otherwise fall back to productData
                        final availabilityStatus = productState?.availabilityStatus ?? 
                            productData?.availabilityStatus ?? 'In use';
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ), // Reduced from 12,6
                          decoration: BoxDecoration(
                            color: _getStatusBadgeColor(availabilityStatus),
                            borderRadius: BorderRadius.circular(12), // Reduced from 16
                          ),
                          child: Text(
                            availabilityStatus,
                            style: TextStyle(
                              fontSize: 10, // Reduced from 12
                              fontWeight: FontWeight.w500,
                              color: _getStatusTextColor(availabilityStatus),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8), // Reduced from 12
                    // Edit Icon
                    GestureDetector(
                      onTap: () => _openEditDialog(),
                      child: Container(
                        padding: const EdgeInsets.all(6), // Reduced from 8
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // Reduced from 6
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14, // Reduced from 16
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced from 20
                // Product Info Grid - Two rows
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Item Type',
                        productData?.itemType ?? 'Main article',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Type/Category',
                        productData?.type ?? 'Manufacturing',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Asset ID',
                        productData?.assetId ?? widget.id,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Supplier',
                        productData?.supplier ?? 'Unknown',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Location',
                        productData?.location ?? 'Unknown',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced from 16
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Created Date',
                        productData != null
                            ? "${productData!.createdDate.day}/${productData!.createdDate.month}/${productData!.createdDate.year}"
                            : '27/1/2024',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Responsible Team',
                        productData?.responsibleTeam ?? 'Unknown',
                      ),
                    ),
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          // Watch for reactive state changes
                          final productState = ref.watch(productStateByIdProvider(productData?.assetId ?? widget.id));
                          
                          // Use reactive state if available, otherwise fall back to productData
                          final nextServiceDue = productState?.nextServiceDue ?? 
                              (productData?.nextServiceDue != null
                                  ? "${productData!.nextServiceDue!.day}/${productData!.nextServiceDue!.month}/${productData!.nextServiceDue!.year}"
                                  : null);
                          
                          return _buildInfoColumn(
                            'Next Service Due',
                            nextServiceDue ?? 'N/A',
                          );
                        },
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/under_construction.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 48,
                      color: Color(0xFF9CA3AF),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 24),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productData?.name ?? 'Item ${widget.id}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            productData?.assetId ?? widget.id,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusBadgeColor(
                          productData?.availabilityStatus,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        productData?.availabilityStatus ?? 'In use',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(
                            productData?.availabilityStatus,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Edit Icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Product Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Item Type',
                        productData?.itemType ?? 'Main article',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Type/Category',
                        productData?.type ?? 'Manufacturing',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Asset ID',
                        productData?.assetId ?? widget.id,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Supplier',
                        productData?.supplier ?? 'Unknown',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Location',
                        productData?.location ?? 'Unknown',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn(
                        'Created Date',
                        productData != null
                            ? "${productData!.createdDate.day}/${productData!.createdDate.month}/${productData!.createdDate.year}"
                            : '27/1/2024',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Responsible Team',
                        productData?.responsibleTeam ?? 'Unknown',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoColumn(
                        'Next Service Due',
                        productData?.nextServiceDue != null
                            ? "${productData!.nextServiceDue!.day}/${productData!.nextServiceDue!.month}/${productData!.nextServiceDue!.year}"
                            : 'N/A',
                      ),
                    ),
                    const Expanded(child: SizedBox()),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10, // Reduced from 12
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2), // Reduced from 4
        Text(
          value,
          style: const TextStyle(
            fontSize: 12, // Reduced from 14
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Color _getStatusBadgeColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return const Color(0xFFDCFCE7);
      case 'in use':
        return const Color(0xFFFEF3C7);
      case 'maintenance':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusTextColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return const Color(0xFF166534);
      case 'in use':
        return const Color(0xFF92400E);
      case 'maintenance':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF92400E);
    }
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 0,
      ), // Reduced from 20
      decoration: const BoxDecoration(
       //border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0)),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Color.fromRGBO(0,89, 154, 1),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color.fromRGBO(0,89, 154, 1),
        indicatorWeight: 1,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.only(
          right: 32,
          top: 0,
          bottom: 0,
        ), // Reduced padding
        isScrollable: true, // Enable scrollable to allow left alignment
        tabAlignment: TabAlignment.start, // Left align tabs
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 12, // Reduced from 14
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12, // Reduced from 14
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Maintenance & service management'),
          Tab(text: 'Usage & allocation management'),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTabContent() {
    return Column(
      children: [
        // Search and Add Button Row - Using master list search bar style
        Container(
          padding: const EdgeInsets.all(16), // Reduced from 20
          child: Row(
            children: [
              // Search Bar - Same style as master list
              SizedBox(
                width: 440,
                height: 35,
                child: TextField(
                  controller: _maintenanceSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search maintenance records...',
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
                    suffixIcon: _maintenanceSearchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearMaintenanceSearch,
                            icon: const Icon(
                              Icons.clear,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            icon: SvgPicture.asset(
                              "assets/images/Vector.svg",
                              width: 12,
                            ),
                          ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Spacer to push button to the right
              const Spacer(),

              // Add Button - Aligned to right
              ElevatedButton(
                onPressed: () {
                  DialogPannelHelper().showAddPannel(
                    context: context,
                    addingItem: AddMaintenanceService(
                      assetId: productData?.assetId ?? widget.id,
                      itemName: productData?.name ?? 'Unknown',
                      assetType: productData?.itemType ?? 'Unknown',
                      onServiceAdded: (String? nextServiceDue) async {
                        print('DEBUG: ProductDetail - Maintenance service added, updating reactive state with Next Service Due: $nextServiceDue');
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 1. Refresh maintenance data first
                        _loadMaintenanceData(productData?.assetId ?? widget.id);
                        
                        // 2. Get updated product data
                        await _loadProductData();
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 3. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                        print('DEBUG: Force refreshing master list data from database to get latest Next Service Due');
                        await _safeRefreshMasterList();
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 4. Update reactive state immediately for instant UI updates
                        final assetId = productData?.assetId ?? widget.id;
                        final updateProductState = ref.read(updateProductStateProvider);
                        
                        // Use the Next Service Due directly from form submission
                        updateProductState(assetId, nextServiceDue: nextServiceDue);
                        
                        print('DEBUG: ProductDetail - Maintenance added, refreshed database and updated reactive state');
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 89, 154, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ), // Reduced from 16,12
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new service',
                  style: TextStyle(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(child: _buildMaintenanceTable()),
      ],
    );
  }

  Widget _buildAllocationTabContent() {
    return Column(
      children: [
        // Search and Add Button Row - Using master list search bar style
        Container(
          padding: const EdgeInsets.all(16), // Reduced from 20
          child: Row(
            children: [
              // Search Bar - Same style as master list
              SizedBox(
                width: 440,
                height: 35,
                child: TextField(
                  controller: _allocationSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search allocation records...',
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
                    suffixIcon: _allocationSearchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: _clearAllocationSearch,
                            icon: const Icon(
                              Icons.clear,
                              size: 16,
                              color: Color(0xFF9CA3AF),
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                            },
                            icon: SvgPicture.asset(
                              "assets/images/Vector.svg",
                              width: 12,
                            ),
                          ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),

              // Spacer to push button to the right
              const Spacer(),

              // Add Button - Aligned to right
              ElevatedButton(
                onPressed: () {
                  DialogPannelHelper().showAddPannel(
                    context: context,
                    addingItem: AddAllocation(
                      assetId: productData?.assetId ?? widget.id,
                      itemName: productData?.name ?? 'Unknown',
                      assetType: productData?.itemType ?? 'Unknown',
                      onAllocationAdded: (String submittedStatus) async {
                        print('DEBUG: ProductDetail - Allocation added, updating reactive state with status: $submittedStatus');
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 1. Refresh allocation data first
                        _loadAllocationData(productData?.assetId ?? widget.id);
                        
                        // 2. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                        print('DEBUG: Force refreshing master list data from database to get latest allocation status');
                        await _safeRefreshMasterList();
                        
                        // 3. Update reactive state immediately for instant UI updates
                        final assetId = productData?.assetId ?? widget.id;
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        final updateAvailabilityStatus = ref.read(updateAvailabilityStatusProvider);
                        
                        // Use the status directly from form submission
                        updateAvailabilityStatus(assetId, submittedStatus);
                        
                        print('DEBUG: ProductDetail - Allocation added, refreshed database and updated reactive state');
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 89, 154, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ), // Reduced from 16,12
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new allocation',
                  style: TextStyle(
                    fontSize: 13, // Reduced from 14
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(child: _buildAllocationTable()),
      ],
    );
  }

  Widget _buildMaintenanceTab() {
    return Column(
      children: [
        // Search and Add Button Row
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Search Box
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Search Icon Button
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add Button
              ElevatedButton(
                onPressed: () {
                  DialogPannelHelper().showAddPannel(
                    context: context,
                    addingItem: AddMaintenanceService(
                      assetId: productData?.assetId ?? widget.id,
                      itemName: productData?.name ?? 'Unknown',
                      assetType: productData?.itemType ?? 'Unknown',
                      onServiceAdded: (String? nextServiceDue) async {
                        print('DEBUG: ProductDetail - Maintenance updated, updating reactive state with Next Service Due: $nextServiceDue');
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 1. Refresh maintenance data first
                        _loadMaintenanceData(productData?.assetId ?? widget.id);
                        
                        // 2. Get updated product data
                        await _loadProductData();
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 3. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                        print('DEBUG: Force refreshing master list data from database to get latest Next Service Due');
                        await _safeRefreshMasterList();
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 4. Update reactive state immediately for instant UI updates
                        final assetId = productData?.assetId ?? widget.id;
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        final updateProductState = ref.read(updateProductStateProvider);
                        
                        // Use the Next Service Due directly from form submission
                        updateProductState(assetId, nextServiceDue: nextServiceDue);
                        
                        print('DEBUG: ProductDetail - Maintenance updated, refreshed database and updated reactive state');
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 89, 154, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new service',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(child: _buildMaintenanceTable()),
      ],
    );
  }

  Widget _buildMaintenanceTable() {
    if (loadingMaintenance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredMaintenanceRecords.isEmpty && maintenanceRecords.isNotEmpty) {
      // Show no search results message
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              'No maintenance records found for "${_maintenanceSearchController.text}"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    if (filteredMaintenanceRecords.isEmpty) {
      return const Center(
        child: Text(
          'No maintenance records found for this item.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final sortState = ref.watch(maintenanceSortProvider);

        // Apply sorting to filtered data
        final sortedData = SortingUtils.sortMaintenanceList(
          filteredMaintenanceRecords,
          sortState.sortColumn,
          sortState.direction,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GenericPaginatedTable<MaintenanceModel>(
            data: sortedData, // Use sorted data
            rowsPerPage: 5,
            minWidth: 1330, // Increased minimum width for better spacing
            showCheckboxColumn: false,
            onRowTap: (record) {
              // Handle row tap - open maintenance dialog
              DialogPannelHelper().showAddPannel(
                context: context,
                addingItem: AddMaintenanceService(
                  assetId: productData?.assetId ?? widget.id,
                  itemName: productData?.name ?? 'Unknown',
                  assetType: productData?.itemType ?? 'Unknown',
                  existingMaintenance: record,
                  onServiceAdded: (String? nextServiceDue) async {
                    print('DEBUG: ProductDetail - Maintenance edited, updating reactive state with Next Service Due: $nextServiceDue');
                    
                    // Check if widget is still mounted before using ref
                    if (!mounted) return;
                    
                    // 1. Refresh maintenance data first
                    _loadMaintenanceData(productData?.assetId ?? widget.id);
                    
                    // 2. Get updated product data
                    await _loadProductData();
                    
                    // Check if widget is still mounted before using ref
                    if (!mounted) return;
                    
                    // 3. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                    print('DEBUG: Force refreshing master list data from database to get latest Next Service Due');
                    await _safeRefreshMasterList();
                    
                    // Check if widget is still mounted before using ref
                    if (!mounted) return;
                    
                    // 4. Update reactive state immediately for instant UI updates
                    final assetId = productData?.assetId ?? widget.id;
                    final updateProductState = ref.read(updateProductStateProvider);
                    
                    // Use the Next Service Due directly from form submission
                    updateProductState(assetId, nextServiceDue: nextServiceDue);
                    
                    print('DEBUG: ProductDetail - Maintenance edited, refreshed database and updated reactive state');
                  },
                ),
              );
            },
            headers: [
              SortableHeader(
                title: 'Service Date',
                sortKey: 'serviceDate',
                width: 140,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Service provider name',
                sortKey: 'serviceProvider',
                width: 200,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Service engineer name',
                sortKey: 'serviceEngineer',
                width: 200,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Service Type',
                sortKey: 'serviceType',
                width: 150,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Responsible Team',
                sortKey: 'responsibleTeam',
                width: 180,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Next Service Due',
                sortKey: 'nextServiceDue',
                width: 180,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Cost',
                sortKey: 'cost',
                width: 120,
                sortProvider: maintenanceSortProvider,
              ),
              SortableHeader(
                title: 'Status',
                sortKey: 'status',
                width: 140,
                sortProvider: maintenanceSortProvider,
              ),
              Container(
               width: 50,
                alignment: Alignment.center,
                child: const Text(""),
              ),
            ],
            rowBuilder: (record, isSelected, onChanged) => [
              Container(
                width: 140,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatDate(record.serviceDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 200,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.serviceProviderCompany,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 200,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.serviceEngineerName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 150,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.serviceType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
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
                  record.responsibleTeam,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
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
                  _formatDate(record.nextServiceDue),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 120,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '₹${record.cost.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 140,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMaintenanceStatusColor(record.maintenanceStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.maintenanceStatus,
                    style: TextStyle(
                      color: _getMaintenanceStatusTextColor(
                        record.maintenanceStatus,
                      ),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Center(
              //   child: IconButton(
              //     padding: EdgeInsets.zero,
              //     constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              //     onPressed: () {
              //       DialogPannelHelper().showAddPannel(
              //         context: context,
              //         addingItem: AddMaintenanceService(
              //           assetId: productData?.assetId ?? widget.id,
              //           itemName: productData?.name ?? 'Unknown',
              //           assetType: productData?.itemType ?? 'Unknown',
              //           existingMaintenance: record,
              //           onServiceAdded: () {
              //             _loadMaintenanceData(productData?.assetId ?? widget.id);
              //           },
              //         ),
              //       );
              //     },
              //     icon: const Icon(
              //       Icons.arrow_forward,

              //       size: 16,
              //       color: Color(0xFF2563EB),
              //     )
              //     ,
              //   ),
              // ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    DialogPannelHelper().showAddPannel(
                      context: context,
                      addingItem: AddMaintenanceService(
                        assetId: productData?.assetId ?? widget.id,
                        itemName: productData?.name ?? 'Unknown',
                        assetType: productData?.itemType ?? 'Unknown',
                        existingMaintenance: record,
                        onServiceAdded: (String? nextServiceDue) async {
                          print('DEBUG: ProductDetail - Maintenance row edited, updating reactive state with Next Service Due: $nextServiceDue');
                          
                          // Check if widget is still mounted before using ref
                          if (!mounted) return;
                          
                          // 1. Refresh maintenance data first
                          _loadMaintenanceData(productData?.assetId ?? widget.id);
                          
                          // 2. Get updated product data
                          await _loadProductData();
                          
                          // 3. Update reactive state immediately for instant UI updates
                          final assetId = productData?.assetId ?? widget.id;
                          
                          // Check if widget is still mounted before using ref
                          if (!mounted) return;
                          
                          // 3. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                          print('DEBUG: Force refreshing master list data from database to get latest Next Service Due');
                          await _safeRefreshMasterList();
                          
                          final updateProductState = ref.read(updateProductStateProvider);
                          
                          // Use the Next Service Due directly from form submission
                          updateProductState(assetId, nextServiceDue: nextServiceDue);
                          
                          print('DEBUG: ProductDetail - Maintenance row edited, refreshed database and updated reactive state');
                        },
                      ),
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
    );
  }

  Widget _buildAllocationTab() {
    return Column(
      children: [
        // Search and Add Button Row
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              // Search Box
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Search Icon Button
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Add Button
              ElevatedButton(
                onPressed: () {
                  DialogPannelHelper().showAddPannel(
                    context: context,
                    addingItem: AddAllocation(
                      assetId: productData?.assetId ?? widget.id,
                      itemName: productData?.name ?? 'Unknown',
                      assetType: productData?.itemType ?? 'Unknown',
                      onAllocationAdded: (String submittedStatus) async {
                        print('DEBUG: ProductDetail - Allocation updated, updating reactive state with status: $submittedStatus');
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        // 1. Refresh allocation data first
                        _loadAllocationData(productData?.assetId ?? widget.id);
                        
                        // 2. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                        print('DEBUG: Force refreshing master list data from database to get latest allocation status');
                        await _safeRefreshMasterList();
                        
                        // 3. Update reactive state immediately for instant UI updates
                        final assetId = productData?.assetId ?? widget.id;
                        
                        // Check if widget is still mounted before using ref
                        if (!mounted) return;
                        
                        final updateAvailabilityStatus = ref.read(updateAvailabilityStatusProvider);
                        
                        // Use the status directly from form submission
                        updateAvailabilityStatus(assetId, submittedStatus);
                        
                        print('DEBUG: ProductDetail - Allocation updated, refreshed database and updated reactive state');
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 89, 154, 1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new allocation',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(child: _buildAllocationTable()),
      ],
    );
  }

  Widget _buildAllocationTable() {
    if (loadingAllocation) {
      return const Center(child: CircularProgressIndicator());
    }

    if (filteredAllocationRecords.isEmpty && allocationRecords.isNotEmpty) {
      // Show no search results message
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 16),
            Text(
              'No allocation records found for "${_allocationSearchController.text}"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search terms',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      );
    }

    if (filteredAllocationRecords.isEmpty) {
      return const Center(
        child: Text(
          'No allocation records found for this item.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      );
    }

    return Consumer(
      builder: (context, ref, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final columnWidths = {
          'issueDate': screenWidth * 0.12,
          'employee': screenWidth * 0.16,
          'team': screenWidth * 0.14,
          'purpose': screenWidth * 0.16,
          'expected': screenWidth * 0.14,
          'actual': screenWidth * 0.14,
          'status': screenWidth * 0.10,
          'action': 50.0,
        };

        final sortState = ref.watch(allocationSortProvider);

        // Apply sorting to filtered data
        final sortedData = SortingUtils.sortAllocationList(
          filteredAllocationRecords,
          sortState.sortColumn,
          sortState.direction,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GenericPaginatedTable<AllocationModel>(
            data: sortedData, // Use sorted data
            rowsPerPage: 5,
            minWidth: 1370, // Increased minimum width for better spacing
            showCheckboxColumn: false,
            onRowTap: (record) {
              // Handle row tap - open allocation dialog
              DialogPannelHelper().showAddPannel(
                context: context,
                addingItem: AddAllocation(
                  assetId: productData?.assetId ?? widget.id,
                  itemName: productData?.name ?? 'Unknown',
                  assetType: productData?.itemType ?? 'Unknown',
                  existingAllocation: record,
                  onAllocationAdded: (String submittedStatus) async {
                    print('DEBUG: ProductDetail - Allocation edited, updating reactive state with status: $submittedStatus');
                    
                    // Check if widget is still mounted before using ref
                    if (!mounted) return;
                    
                    // 1. Refresh allocation data first
                    _loadAllocationData(productData?.assetId ?? widget.id);
                    
                    // 2. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                    print('DEBUG: Force refreshing master list data from database to get latest allocation status');
                    await _safeRefreshMasterList();
                    
                    // 3. Update reactive state immediately for instant UI updates
                    final assetId = productData?.assetId ?? widget.id;
                    
                    // Check if widget is still mounted before using ref
                    if (!mounted) return;
                    
                    final updateAvailabilityStatus = ref.read(updateAvailabilityStatusProvider);
                    
                    // Use the status directly from form submission
                    updateAvailabilityStatus(assetId, submittedStatus);
                    
                    print('DEBUG: ProductDetail - Allocation edited, refreshed database and updated reactive state');
                  },
                ),
              );
            },
            headers: [
              SortableHeader(
                title: 'Issue Date',
                sortKey: 'issueDate',
                width: 140,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Employee name',
                sortKey: 'employeeName',
                width: 180,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Team name',
                sortKey: 'teamName',
                width: 200,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Purpose',
                sortKey: 'purpose',
                width: 280,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Expected return date',
                sortKey: 'expectedReturnDate',
                width: 200,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Actual return date',
                sortKey: 'actualReturnDate',
                width: 180,
                sortProvider: allocationSortProvider,
              ),
              SortableHeader(
                title: 'Status',
                sortKey: 'status',
                width: 140,
                sortProvider: allocationSortProvider,
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: const Text(""),
              ),
            ],
            rowBuilder: (record, isSelected, onChanged) => [
              Container(
                width: 140,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatDate(record.issuedDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 180,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.employeeName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 200,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.teamName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 280,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  record.purpose,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 200,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatDate(record.expectedReturnDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 180,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _formatDate(record.actualReturnDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 140,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getAllocationStatusColor(record.availabilityStatus),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.availabilityStatus,
                    style: TextStyle(
                      color: _getAllocationStatusTextColor(
                        record.availabilityStatus,
                      ),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              // Container(
              //   width: 20,
              //   alignment: Alignment.center,
              //   padding: const EdgeInsets.all(8.0),
              //   child: IconButton(
              //     padding: EdgeInsets.zero,
              //     constraints: const BoxConstraints(
              //       minWidth: 20,
              //       minHeight: 20,
              //     ),
              //     onPressed: () {
              //       DialogPannelHelper().showAddPannel(
              //         context: context,
              //         addingItem: AddAllocation(
              //           assetId: productData?.assetId ?? widget.id,
              //           itemName: productData?.name ?? 'Unknown',
              //           assetType: productData?.itemType ?? 'Unknown',
              //           existingAllocation: record,
              //           onAllocationAdded: () {
              //             _loadAllocationData(
              //               productData?.assetId ?? widget.id,
              //             );
              //           },
              //         ),
              //       );
              //     },
              //     icon: const Icon(
              //       Icons.arrow_forward,
              //       size: 16,
              //       color: Color(0xFF2563EB),
              //     ),
              //   ),
              // ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    DialogPannelHelper().showAddPannel(
                      context: context,
                      addingItem: AddAllocation(
                        assetId: productData?.assetId ?? widget.id,
                        itemName: productData?.name ?? 'Unknown',
                        assetType: productData?.itemType ?? 'Unknown',
                        existingAllocation: record,
                        onAllocationAdded: (String submittedStatus) async {
                          print('DEBUG: ProductDetail - Allocation row edited, updating reactive state with status: $submittedStatus');
                          
                          // Check if widget is still mounted before using ref
                          if (!mounted) return;
                          
                          // 1. Refresh allocation data first
                          _loadAllocationData(productData?.assetId ?? widget.id);
                          
                          // 2. FORCE REFRESH MASTER LIST DATA FROM DATABASE (this is key!)
                          print('DEBUG: Force refreshing master list data from database to get latest allocation status');
                          await _safeRefreshMasterList();
                          
                          // 3. Update reactive state immediately for instant UI updates
                          final assetId = productData?.assetId ?? widget.id;
                          
                          // Check if widget is still mounted before using ref
                          if (!mounted) return;
                          
                          final updateAvailabilityStatus = ref.read(updateAvailabilityStatusProvider);
                          
                          // Use the status directly from form submission
                          updateAvailabilityStatus(assetId, submittedStatus);
                          
                          print('DEBUG: ProductDetail - Allocation row edited, refreshed database and updated reactive state');
                        },
                      ),
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
    );
  }

  Widget _buildTableHeaderWithFilter(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11, // Reduced from 12
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(width: 3), // Reduced from 4
          SvgPicture.asset(
            "assets/images/Icon_filter.svg",
            width: 14, // Reduced from 16
            height: 14,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 1), // Reduced from 2
          SvgPicture.asset(
            "assets/images/Icon_arrowdown.svg",
            width: 14, // Reduced from 16
            height: 14,
            colorFilter: const ColorFilter.mode(
              Color(0xFF9CA3AF),
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12, // Reduced from 13
          color: Color(0xFF111827),
        ),
      ),
    );
  }

  Widget _buildPagination(int totalItems) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ), // Reduced from 16,12
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Show $totalItems entries',
            style: const TextStyle(
              fontSize: 12, // Reduced from 14
              color: Color(0xFF6B7280),
            ),
          ),
          Row(
            children: [
              for (int i = 1; i <= (totalItems / 10).ceil() && i <= 5; i++)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 1,
                  ), // Reduced from 2
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: i == 1
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      foregroundColor: i == 1
                          ? Colors.white
                          : const Color(0xFF374151),
                      minimumSize: const Size(28, 28), // Reduced from 32,32
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      i.toString(),
                      style: const TextStyle(fontSize: 12), // Reduced from 14
                    ),
                  ),
                ),
              if (totalItems > 50) ...[
                const Text(
                  '...',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                ), // Reduced font size
                TextButton(
                  onPressed: () {},
                  child: Text(
                    ((totalItems / 10).ceil()).toString(),
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 12,
                    ), // Reduced font size
                  ),
                ),
              ],
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6B7280),
                  size: 18,
                ), // Reduced from default
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Test function to manually trigger master list refresh
  Future<void> _testMasterListRefresh() async {
    print('DEBUG: Manual test - Triggering master list refresh');
    try {
      await _safeRefreshMasterList();
      print('DEBUG: Manual test - Master list refresh completed successfully');
    } catch (e) {
      print('DEBUG: Manual test - Master list refresh failed: $e');
    }
  }

  Color _getMaintenanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFFDCFCE7);
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'over due':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getMaintenanceStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF166534);
      case 'pending':
        return const Color(0xFF92400E);
      case 'over due':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _getAllocationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'allocated':
        return const Color(0xFFFEF3C7);
      case 'returned':
        return const Color(0xFFDCFCE7);
      case 'overdue':
        return const Color(0xFFFEE2E2);
      case 'available':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getAllocationStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'allocated':
        return const Color(0xFF92400E);
      case 'returned':
        return const Color(0xFF166534);
      case 'overdue':
        return const Color(0xFF991B1B);
      case 'available':
        return const Color(0xFF166534);
      default:
        return const Color(0xFF6B7280);
    }
  }
}
