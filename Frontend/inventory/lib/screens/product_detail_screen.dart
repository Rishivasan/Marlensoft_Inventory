import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/dialogs/dialog_pannel_helper.dart';
import 'package:inventory/screens/add_forms/add_maintenance_service.dart';
import 'package:inventory/screens/add_forms/add_allocation.dart';
import 'package:inventory/providers/header_state.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.id});
  
  final String id;
  
  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> with TickerProviderStateMixin {
  MasterListModel? productData;
  List<MaintenanceModel> maintenanceRecords = [];
  List<AllocationModel> allocationRecords = [];
  bool loading = true;
  bool loadingMaintenance = true;
  bool loadingAllocation = true;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Set header for Product Detail page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(headerProvider.notifier).state = const HeaderModel(
        title: "Products",
        subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.",
      );
    });
    
    _loadProductData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    
    // Reset header when leaving the page
    ref.read(headerProvider.notifier).state = const HeaderModel(
      title: "Dashboard",
      subtitle: "Welcome! Select a menu to view details.",
    );
    
    super.dispose();
  }
  
  Future<void> _loadProductData() async {
    print('DEBUG: Loading product data for ID: ${widget.id}');
    try {
      final apiService = ApiService();
      final data = await apiService.getMasterListById(widget.id);
      
      if (data != null) {
        print('DEBUG: Product data loaded successfully: ${data.name}');
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
        print('DEBUG: No maintenance data from API, adding sample data for UI testing');
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
        loadingMaintenance = false;
      });
      
      if (finalMaintenanceList.isEmpty) {
        print('DEBUG: No maintenance records found for asset: $assetId');
      } else {
        print('DEBUG: Found maintenance records: ${finalMaintenanceList.map((m) => '${m.serviceProviderCompany} - ${m.serviceType}').toList()}');
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
        print('DEBUG: No allocation data from API, adding sample data for UI testing');
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
        loadingAllocation = false;
      });
      
      if (finalAllocationList.isEmpty) {
        print('DEBUG: No allocation records found for asset: $assetId');
      } else {
        print('DEBUG: Found allocation records: ${finalAllocationList.map((a) => '${a.employeeName} - ${a.purpose}').toList()}');
      }
    } catch (e) {
      print('DEBUG: Error loading allocation data: $e');
      setState(() {
        loadingAllocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100, // Ensure minimum height
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Reduced from 16
                  child: _buildUnifiedCard(),
                ),
              ),
            ),
    );
  }

  Widget _buildUnifiedCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Card Section - Compact
          _buildProductCardContent(),
          
          // Divider
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFE5E7EB),
          ),
          
          // Tabs Section
          _buildTabs(),
          
          // Tab Content Section - Constrained height to prevent overflow
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6, // More responsive height
              minHeight: 350, // Reduced minimum height
            ),
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Reduced from 12,6
                      decoration: BoxDecoration(
                        color: _getStatusBadgeColor(productData?.availabilityStatus),
                        borderRadius: BorderRadius.circular(12), // Reduced from 16
                      ),
                      child: Text(
                        productData?.availabilityStatus ?? 'In use',
                        style: TextStyle(
                          fontSize: 10, // Reduced from 12
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(productData?.availabilityStatus),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced from 12
                    // Edit Icon
                    Container(
                      padding: const EdgeInsets.all(6), // Reduced from 8
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4), // Reduced from 6
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 14, // Reduced from 16
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced from 20
                
                // Product Info Grid - Two rows
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Item Type', productData?.itemType ?? 'Main article'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Type/Category', productData?.type ?? 'Manufacturing'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Asset ID', productData?.assetId ?? widget.id),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Supplier', productData?.supplier ?? 'Unknown'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Location', productData?.location ?? 'Unknown'),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // Reduced from 16
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Created Date', 
                        productData != null 
                          ? "${productData!.createdDate.day}/${productData!.createdDate.month}/${productData!.createdDate.year}"
                          : '27/1/2024'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Responsible Team', productData?.responsibleTeam ?? 'Unknown'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Next Service Due', 
                        productData?.nextServiceDue != null 
                          ? "${productData!.nextServiceDue!.day}/${productData!.nextServiceDue!.month}/${productData!.nextServiceDue!.year}"
                          : 'N/A'),
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
              border: Border.all(color: const Color(0xFFE5E7EB)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusBadgeColor(productData?.availabilityStatus),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        productData?.availabilityStatus ?? 'In use',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getStatusTextColor(productData?.availabilityStatus),
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
                      child: _buildInfoColumn('Item Type', productData?.itemType ?? 'Main article'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Type/Category', productData?.type ?? 'Manufacturing'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Asset ID', productData?.assetId ?? widget.id),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Supplier', productData?.supplier ?? 'Unknown'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Location', productData?.location ?? 'Unknown'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Created Date', 
                        productData != null 
                          ? "${productData!.createdDate.day}/${productData!.createdDate.month}/${productData!.createdDate.year}"
                          : '27/1/2024'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Responsible Team', productData?.responsibleTeam ?? 'Unknown'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Next Service Due', 
                        productData?.nextServiceDue != null 
                          ? "${productData!.nextServiceDue!.day}/${productData!.nextServiceDue!.month}/${productData!.nextServiceDue!.year}"
                          : 'N/A'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // Reduced from 20
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF2563EB),
        unselectedLabelColor: const Color(0xFF6B7280),
        indicatorColor: const Color(0xFF2563EB),
        indicatorWeight: 2,
        indicatorPadding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.only(right: 32, top: 8, bottom: 8), // Reduced padding
        isScrollable: true, // Enable scrollable to allow left alignment
        tabAlignment: TabAlignment.start, // Left align tabs
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 13, // Reduced from 14
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13, // Reduced from 14
          fontWeight: FontWeight.w400,
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
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 12,
                      ),
                    ),
                  ],
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
                      onServiceAdded: () {
                        _loadMaintenanceData(productData?.assetId ?? widget.id);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced from 16,12
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
        Expanded(
          child: _buildMaintenanceTable(),
        ),
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
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xFF9CA3AF),
                        size: 12,
                      ),
                    ),
                  ],
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
                      onAllocationAdded: () {
                        _loadAllocationData(productData?.assetId ?? widget.id);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced from 16,12
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
        Expanded(
          child: _buildAllocationTable(),
        ),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      onServiceAdded: () {
                        // Refresh maintenance data
                        _loadMaintenanceData(productData?.assetId ?? widget.id);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new service',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Table
        Expanded(
          child: _buildMaintenanceTable(),
        ),
      ],
    );
  }

  Widget _buildMaintenanceTable() {
    if (loadingMaintenance) {
      return const Center(child: CircularProgressIndicator());
    }

    if (maintenanceRecords.isEmpty) {
      return const Center(
        child: Text(
          'No maintenance records found for this item.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)), // Reduced from 16
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Reduced from 20
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeaderWithFilter('Service Date', flex: 2),
                _buildTableHeaderWithFilter('Service provider name', flex: 2),
                _buildTableHeaderWithFilter('Service engineer name', flex: 2),
                _buildTableHeaderWithFilter('Service Type', flex: 2),
                _buildTableHeaderWithFilter('Responsible Team', flex: 2),
                _buildTableHeaderWithFilter('Next Service Due', flex: 2),
                _buildTableHeaderWithFilter('Cost', flex: 1),
                _buildTableHeaderWithFilter('Status', flex: 1),
                const SizedBox(width: 32), // Reduced from 40
              ],
            ),
          ),
          
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: maintenanceRecords.length,
              itemBuilder: (context, index) {
                final record = maintenanceRecords[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: index == maintenanceRecords.length - 1 
                            ? Colors.transparent 
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTableCell(
                        _formatDate(record.serviceDate),
                        flex: 2,
                      ),
                      _buildTableCell(record.serviceProviderCompany, flex: 2),
                      _buildTableCell(record.serviceEngineerName, flex: 2),
                      _buildTableCell(record.serviceType, flex: 2),
                      _buildTableCell(record.responsibleTeam, flex: 2),
                      _buildTableCell(
                        _formatDate(record.nextServiceDue),
                        flex: 2,
                      ),
                      _buildTableCell(
                        '₹${record.cost.toStringAsFixed(0)}',
                        flex: 1,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced from 8,4
                          decoration: BoxDecoration(
                            color: _getMaintenanceStatusColor(record.maintenanceStatus),
                            borderRadius: BorderRadius.circular(10), // Reduced from 12
                          ),
                          child: Text(
                            record.maintenanceStatus,
                            style: TextStyle(
                              color: _getMaintenanceStatusTextColor(record.maintenanceStatus),
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32, // Reduced from 40
                        child: IconButton(
                          onPressed: () {
                            // Open edit dialog with existing maintenance data
                            DialogPannelHelper().showAddPannel(
                              context: context,
                              addingItem: AddMaintenanceService(
                                assetId: productData?.assetId ?? widget.id,
                                itemName: productData?.name ?? 'Unknown',
                                assetType: productData?.itemType ?? 'Unknown',
                                existingMaintenance: record, // Pass the existing record for editing
                                onServiceAdded: () {
                                  _loadMaintenanceData(productData?.assetId ?? widget.id);
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 14, // Reduced from 16
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pagination
          _buildPagination(maintenanceRecords.length),
        ],
      ),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      onAllocationAdded: () {
                        // Refresh allocation data
                        _loadAllocationData(productData?.assetId ?? widget.id);
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Add new allocation',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Table
        Expanded(
          child: _buildAllocationTable(),
        ),
      ],
    );
  }

  Widget _buildAllocationTable() {
    if (loadingAllocation) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allocationRecords.isEmpty) {
      return const Center(
        child: Text(
          'No allocation records found for this item.',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)), // Reduced from 16
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // Reduced from 20
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildTableHeaderWithFilter('Issue Date', flex: 2),
                _buildTableHeaderWithFilter('Employee name', flex: 2),
                _buildTableHeaderWithFilter('Team name', flex: 2),
                _buildTableHeaderWithFilter('Purpose', flex: 2),
                _buildTableHeaderWithFilter('Expected return date', flex: 2),
                _buildTableHeaderWithFilter('Actual return date', flex: 2),
                _buildTableHeaderWithFilter('Status', flex: 1),
                const SizedBox(width: 32), // Reduced from 40
              ],
            ),
          ),
          
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: allocationRecords.length,
              itemBuilder: (context, index) {
                final record = allocationRecords[index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10), // Reduced from 12
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: index == allocationRecords.length - 1 
                            ? Colors.transparent 
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildTableCell(
                        _formatDate(record.issuedDate),
                        flex: 2,
                      ),
                      _buildTableCell(record.employeeName, flex: 2),
                      _buildTableCell(record.teamName, flex: 2),
                      _buildTableCell(record.purpose, flex: 2),
                      _buildTableCell(
                        _formatDate(record.expectedReturnDate),
                        flex: 2,
                      ),
                      _buildTableCell(
                        _formatDate(record.actualReturnDate),
                        flex: 2,
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // Reduced from 8,4
                          decoration: BoxDecoration(
                            color: _getAllocationStatusColor(record.availabilityStatus),
                            borderRadius: BorderRadius.circular(10), // Reduced from 12
                          ),
                          child: Text(
                            record.availabilityStatus,
                            style: TextStyle(
                              color: _getAllocationStatusTextColor(record.availabilityStatus),
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 32, // Reduced from 40
                        child: IconButton(
                          onPressed: () {
                            // Open edit dialog with existing allocation data
                            DialogPannelHelper().showAddPannel(
                              context: context,
                              addingItem: AddAllocation(
                                assetId: productData?.assetId ?? widget.id,
                                itemName: productData?.name ?? 'Unknown',
                                assetType: productData?.itemType ?? 'Unknown',
                                existingAllocation: record, // Pass the existing record for editing
                                onAllocationAdded: () {
                                  _loadAllocationData(productData?.assetId ?? widget.id);
                                },
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 14, // Reduced from 16
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pagination
          _buildPagination(allocationRecords.length),
        ],
      ),
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
          Icon(
            Icons.filter_list,
            size: 14, // Reduced from 16
            color: const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 1), // Reduced from 2
          Icon(
            Icons.keyboard_arrow_down,
            size: 14, // Reduced from 16
            color: const Color(0xFF9CA3AF),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Reduced from 16,12
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
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
                  margin: const EdgeInsets.symmetric(horizontal: 1), // Reduced from 2
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: i == 1 ? const Color(0xFF2563EB) : Colors.transparent,
                      foregroundColor: i == 1 ? Colors.white : const Color(0xFF374151),
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
                const Text('...', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)), // Reduced font size
                TextButton(
                  onPressed: () {},
                  child: Text(
                    ((totalItems / 10).ceil()).toString(),
                    style: const TextStyle(color: Color(0xFF374151), fontSize: 12), // Reduced font size
                  ),
                ),
              ],
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: Color(0xFF6B7280), size: 18), // Reduced from default
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