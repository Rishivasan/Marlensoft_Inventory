import 'package:flutter/material.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/model/allocation_model.dart';
import 'package:inventory/services/api_service.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.id});
  
  final String id;
  
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with TickerProviderStateMixin {
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
    _loadProductData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
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
    try {
      final apiService = ApiService();
      final maintenance = await apiService.getMaintenanceByAssetId(assetId);
      
      print('DEBUG: Maintenance API returned ${maintenance.length} records');
      setState(() {
        maintenanceRecords = maintenance;
        loadingMaintenance = false;
      });
      
      if (maintenance.isEmpty) {
        print('DEBUG: No maintenance records found for asset: $assetId');
      } else {
        print('DEBUG: Found maintenance records: ${maintenance.map((m) => m.assetId).toList()}');
      }
    } catch (e) {
      print('DEBUG: Error loading maintenance data: $e');
      setState(() {
        loadingMaintenance = false;
      });
    }
  }
  
  Future<void> _loadAllocationData(String assetId) async {
    try {
      final apiService = ApiService();
      final allocations = await apiService.getAllocationsByAssetId(assetId);
      
      setState(() {
        allocationRecords = allocations;
        loadingAllocation = false;
      });
      
      // If no real data, show message instead of sample data
      if (allocations.isEmpty) {
        print('DEBUG: No allocation records found for asset: $assetId');
      }
    } catch (e) {
      setState(() {
        loadingAllocation = false;
      });
      print('Error loading allocation data: $e');
    }
  }
  
  Color getStatusColor(String? status) {
    if (status?.toLowerCase() == 'active') {
      return const Color.fromRGBO(227, 250, 232, 1);
    } else {
      return const Color.fromRGBO(255, 211, 211, 1);
    }
  }
  
  Color getStatusTextColor(String? status) {
    if (status?.toLowerCase() == 'active') {
      return const Color.fromRGBO(54, 90, 64, 1);
    } else {
      return const Color.fromRGBO(240, 78, 62, 1);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Products',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Text(
              'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage('assets/images/userprofile.jpg'),
                ),
                const SizedBox(width: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'John doe',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header Section
                  _buildProductHeader(),
                  const SizedBox(height: 24),
                  
                  // Tab Section
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: const Color(0xFF2196F3),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: const Color(0xFF2196F3),
                      indicatorWeight: 2,
                      tabs: const [
                        Tab(text: 'Maintenance & service management'),
                        Tab(text: 'Usage & allocation management'),
                      ],
                    ),
                  ),
                  
                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMaintenanceTab(),
                        _buildUsageTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/under_construction.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productData?.name ?? 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          productData?.assetId ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(productData?.availabilityStatus),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        productData?.availabilityStatus ?? 'Loading...',
                        style: TextStyle(
                          color: getStatusTextColor(productData?.availabilityStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        // Handle edit action
                      },
                      icon: const Icon(Icons.edit, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Product Info Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Item Type', productData?.itemType ?? 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Type/Category', productData?.type ?? 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Asset ID', productData?.assetId ?? 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Supplier', productData?.supplier ?? 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Location', productData?.location ?? 'Loading...'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoColumn('Created Date', 
                        productData != null 
                          ? "${productData!.createdDate.day}/${productData!.createdDate.month}/${productData!.createdDate.year}"
                          : 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Responsible Team', productData?.responsibleTeam ?? 'Loading...'),
                    ),
                    Expanded(
                      child: _buildInfoColumn('Next Service Due', 
                        productData?.nextServiceDue != null 
                          ? "${productData!.nextServiceDue!.day}/${productData!.nextServiceDue!.month}/${productData!.nextServiceDue!.year}"
                          : 'N/A'),
                    ),
                    const Expanded(child: SizedBox()), // Empty space
                    const Expanded(child: SizedBox()), // Empty space
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
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMaintenanceTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Search and Add Button
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Handle add new service
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Add new service'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Service Table
        Expanded(
          child: _buildServiceTable(),
        ),
      ],
    );
  }
  
  Widget _buildUsageTab() {
    if (loadingAllocation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (allocationRecords.isEmpty) {
      return const Center(
        child: Text(
          'No allocation records found for this item.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return Column(
      children: [
        const SizedBox(height: 16),
        
        // Search and Add Button
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Handle add new allocation
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('Add new allocation'),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Allocation Table
        Expanded(
          child: _buildAllocationTable(),
        ),
      ],
    );
  }
  
  Widget _buildAllocationTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Team Name', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Purpose', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Issued Date', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Expected Return', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Actual Return', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 40),
              ],
            ),
          ),
          
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: allocationRecords.length,
              itemBuilder: (context, index) {
                final allocation = allocationRecords[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(allocation.employeeId)),
                      Expanded(flex: 2, child: Text(allocation.employeeName)),
                      Expanded(flex: 2, child: Text(allocation.teamName)),
                      Expanded(flex: 2, child: Text(allocation.purpose)),
                      Expanded(
                        flex: 2, 
                        child: Text(
                          allocation.issuedDate != null 
                              ? "${allocation.issuedDate!.day}/${allocation.issuedDate!.month}/${allocation.issuedDate!.year}"
                              : 'N/A'
                        )
                      ),
                      Expanded(
                        flex: 2, 
                        child: Text(
                          allocation.expectedReturnDate != null 
                              ? "${allocation.expectedReturnDate!.day}/${allocation.expectedReturnDate!.month}/${allocation.expectedReturnDate!.year}"
                              : 'N/A'
                        )
                      ),
                      Expanded(
                        flex: 2, 
                        child: Text(
                          allocation.actualReturnDate != null 
                              ? "${allocation.actualReturnDate!.day}/${allocation.actualReturnDate!.month}/${allocation.actualReturnDate!.year}"
                              : 'Pending'
                        )
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getAllocationStatusColor(allocation.availabilityStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            allocation.availabilityStatus,
                            style: TextStyle(
                              color: _getAllocationStatusTextColor(allocation.availabilityStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          onPressed: () {
                            // Handle row action - could show allocation details
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Show ${allocationRecords.length} entries'),
                Row(
                  children: [
                    for (int i = 1; i <= (allocationRecords.length / 10).ceil() && i <= 5; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: i == 1 ? const Color(0xFF2196F3) : Colors.transparent,
                            foregroundColor: i == 1 ? Colors.white : Colors.black,
                            minimumSize: const Size(32, 32),
                          ),
                          child: Text(i.toString()),
                        ),
                      ),
                    if (allocationRecords.length > 50) ...[
                      const Text('...'),
                      TextButton(
                        onPressed: () {},
                        child: Text(((allocationRecords.length / 10).ceil()).toString()),
                      ),
                    ],
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getAllocationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'allocated':
        return const Color.fromRGBO(255, 243, 205, 1);
      case 'returned':
        return const Color.fromRGBO(227, 250, 232, 1);
      case 'overdue':
        return const Color.fromRGBO(255, 211, 211, 1);
      case 'available':
        return const Color.fromRGBO(227, 250, 232, 1);
      default:
        return Colors.grey.shade200;
    }
  }
  
  Color _getAllocationStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'allocated':
        return const Color.fromRGBO(184, 138, 0, 1);
      case 'returned':
        return const Color.fromRGBO(54, 90, 64, 1);
      case 'overdue':
        return const Color.fromRGBO(240, 78, 62, 1);
      case 'available':
        return const Color.fromRGBO(54, 90, 64, 1);
      default:
        return Colors.grey.shade800;
    }
  }
  
  Widget _buildServiceTable() {
    if (loadingMaintenance) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (maintenanceRecords.isEmpty) {
      return const Center(
        child: Text(
          'No maintenance records found for this item.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Service Date', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Service provider name', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Service engineer name', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Service Type', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Responsible Team', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 2, child: Text('Next Service Due', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Cost', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontWeight: FontWeight.w600))),
                SizedBox(width: 40),
              ],
            ),
          ),
          
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: maintenanceRecords.length,
              itemBuilder: (context, index) {
                final maintenance = maintenanceRecords[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2, 
                        child: Text(
                          maintenance.serviceDate != null 
                              ? "${maintenance.serviceDate!.day}/${maintenance.serviceDate!.month}/${maintenance.serviceDate!.year}"
                              : 'N/A'
                        )
                      ),
                      Expanded(flex: 2, child: Text(maintenance.serviceProviderCompany)),
                      Expanded(flex: 2, child: Text(maintenance.serviceEngineerName)),
                      Expanded(flex: 2, child: Text(maintenance.serviceType)),
                      Expanded(flex: 2, child: Text(maintenance.responsibleTeam)),
                      Expanded(
                        flex: 2, 
                        child: Text(
                          maintenance.nextServiceDue != null 
                              ? "${maintenance.nextServiceDue!.day}/${maintenance.nextServiceDue!.month}/${maintenance.nextServiceDue!.year}"
                              : 'N/A'
                        )
                      ),
                      Expanded(flex: 1, child: Text('₹${maintenance.cost.toStringAsFixed(0)}')),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getServiceStatusColor(maintenance.maintenanceStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            maintenance.maintenanceStatus,
                            style: TextStyle(
                              color: _getServiceStatusTextColor(maintenance.maintenanceStatus),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          onPressed: () {
                            // Handle row action - could show maintenance details
                          },
                          icon: const Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Pagination
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Show ${maintenanceRecords.length} entries'),
                Row(
                  children: [
                    for (int i = 1; i <= (maintenanceRecords.length / 10).ceil() && i <= 5; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: i == 1 ? const Color(0xFF2196F3) : Colors.transparent,
                            foregroundColor: i == 1 ? Colors.white : Colors.black,
                            minimumSize: const Size(32, 32),
                          ),
                          child: Text(i.toString()),
                        ),
                      ),
                    if (maintenanceRecords.length > 50) ...[
                      const Text('...'),
                      TextButton(
                        onPressed: () {},
                        child: Text(((maintenanceRecords.length / 10).ceil()).toString()),
                      ),
                    ],
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getServiceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromRGBO(227, 250, 232, 1);
      case 'pending':
        return const Color.fromRGBO(255, 243, 205, 1);
      case 'over due':
        return const Color.fromRGBO(255, 211, 211, 1);
      default:
        return Colors.grey.shade200;
    }
  }
  
  Color _getServiceStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color.fromRGBO(54, 90, 64, 1);
      case 'pending':
        return const Color.fromRGBO(184, 138, 0, 1);
      case 'over due':
        return const Color.fromRGBO(240, 78, 62, 1);
      default:
        return Colors.grey.shade800;
    }
  }
}