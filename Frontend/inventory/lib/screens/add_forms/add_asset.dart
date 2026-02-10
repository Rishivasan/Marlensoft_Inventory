import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/services/next_service_calculation_service.dart';
import 'package:provider/provider.dart';

class AddAsset extends StatefulWidget {
  const AddAsset({
    super.key, 
    required this.submit,
    this.existingData, // Add parameter for existing Asset data
  });

  final VoidCallback submit;
  final MasterListModel? existingData; // Existing data for editing

  @override
  State<AddAsset> createState() => _AddAssetState();
}

class _AddAssetState extends State<AddAsset> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false; // Add submission state tracking

  // Asset information
  final _assetIdCtrl = TextEditingController();
  final _assetNameCtrl = TextEditingController();
  String? selectedCategory;

  final _supplierNameCtrl = TextEditingController();
  final _productsCtrl = TextEditingController();
  final _toolSpecificationsCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _storageLocationCtrl = TextEditingController();

  // Purchase information
  final _poNumberCtrl = TextEditingController();
  DateTime? selectedPoDate;

  final _invoiceNumberCtrl = TextEditingController();
  DateTime? selectedInvoiceDate;

  final _assetCostCtrl = TextEditingController();
  final _extraChargesCtrl = TextEditingController();
  final _totalAssetCostCtrl = TextEditingController(text: "0.00");

  // Maintenance and Audit information
  final _depreciationPeriodCtrl = TextEditingController();
  String? selectedMaintenanceFrequency;
  String? selectedAssetStatus;

  final _responsiblePersonCtrl = TextEditingController();
  final _stockMsiAssetCtrl = TextEditingController();
  final _additionalNotesCtrl = TextEditingController();

  // Dropdown values
  // Dropdown values - made mutable to allow adding database values
  final List<String> categoryList = [
    "Electrical",
    "Mechanical",
    "IT",
    "Furniture",
  ];

  final List<String> maintenanceFrequencyList = [
    "Daily",
    "Weekly",
    "Monthly",
    "Quarterly",
    "Yearly",
  ];

  final List<String> assetStatusList = [
    "Active",
    "Inactive",
    "Under Maintenance",
    "Scrapped",
  ];

  @override
  void initState() {
    super.initState();
    _assetCostCtrl.addListener(_calculateTotalCost);
    _extraChargesCtrl.addListener(_calculateTotalCost);
    
    // Pre-populate form if existing data is provided
    if (widget.existingData != null) {
      _populateFormWithExistingData();
    } else {
      // Set default values for new assets
      selectedAssetStatus = "Active"; // Default to Active for new items
    }
  }
  
  void _populateFormWithExistingData() {
    final data = widget.existingData!;
    
    // Basic information from MasterListModel
    _assetIdCtrl.text = data.assetId;
    _assetNameCtrl.text = data.name;
    _supplierNameCtrl.text = data.supplier;
    _storageLocationCtrl.text = data.location;
    
    print('DEBUG: Pre-populated Asset form with basic data: ${data.name}');
    
    // Fetch complete Asset details from the Asset table
    _fetchCompleteAssetDetails(data.assetId);
  }
  
  Future<void> _fetchCompleteAssetDetails(String assetId) async {
    print('DEBUG: Fetching complete Asset details for ID: $assetId using V2 API');
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetailsV2(assetId, 'asset');
      
      if (completeData != null) {
        print('DEBUG: Complete Asset data received from V2 API: $completeData');
        
        final masterData = completeData['MasterData'] != null 
            ? Map<String, dynamic>.from(completeData['MasterData'] as Map) 
            : null;
        final detailedData = completeData['DetailedData'] != null 
            ? Map<String, dynamic>.from(completeData['DetailedData'] as Map) 
            : null;
        final hasDetailedData = completeData['HasDetailedData'] == true;
        
        print('DEBUG: MasterData keys: ${masterData?.keys.toList()}');
        print('DEBUG: DetailedData keys: ${detailedData?.keys.toList()}');
        print('DEBUG: HasDetailedData: $hasDetailedData');
        
        // Populate all Asset-specific fields
        setState(() {
          // Always populate basic fields from master data
          if (masterData != null) {
            _assetIdCtrl.text = masterData['itemID']?.toString() ?? _assetIdCtrl.text;
            _assetNameCtrl.text = masterData['itemName']?.toString() ?? _assetNameCtrl.text;
            _supplierNameCtrl.text = masterData['vendor']?.toString() ?? _supplierNameCtrl.text;
            _storageLocationCtrl.text = masterData['storageLocation']?.toString() ?? _storageLocationCtrl.text;
            _responsiblePersonCtrl.text = masterData['responsibleTeam']?.toString() ?? _responsiblePersonCtrl.text;
          }
          
          // If we have detailed data, populate all detailed fields - using camelCase field names
          if (hasDetailedData && detailedData != null) {
            // Category - show actual database value, add to list if not present
            final categoryValue = detailedData['category']?.toString();
            selectedCategory = categoryValue;
            // Add the database value to dropdown list if it doesn't exist
            if (categoryValue != null && categoryValue.isNotEmpty && !categoryList.contains(categoryValue)) {
              categoryList.add(categoryValue);
            }
            _productsCtrl.text = detailedData['product']?.toString() ?? '';
            _toolSpecificationsCtrl.text = detailedData['specifications']?.toString() ?? '';
            _quantityCtrl.text = detailedData['quantity']?.toString() ?? '';
            
            // Purchase information - using camelCase field names
            _poNumberCtrl.text = detailedData['poNumber']?.toString() ?? '';
            _invoiceNumberCtrl.text = detailedData['invoiceNumber']?.toString() ?? '';
            _assetCostCtrl.text = detailedData['assetCost']?.toString() ?? '';
            _extraChargesCtrl.text = detailedData['extraCharges']?.toString() ?? '';
            
            // Dates - using camelCase field names
            if (detailedData['poDate'] != null) {
              selectedPoDate = DateTime.tryParse(detailedData['poDate'].toString());
            }
            if (detailedData['invoiceDate'] != null) {
              selectedInvoiceDate = DateTime.tryParse(detailedData['invoiceDate'].toString());
            }
            
            // Maintenance info - using camelCase field names
            _depreciationPeriodCtrl.text = detailedData['depreciationPeriod']?.toString() ?? '';
            // Maintenance frequency - show actual database value, add to list if not present
            final maintenanceFreqValue = detailedData['maintenanceFrequency']?.toString();
            selectedMaintenanceFrequency = maintenanceFreqValue;
            // Add the database value to dropdown list if it doesn't exist
            if (maintenanceFreqValue != null && maintenanceFreqValue.isNotEmpty && !maintenanceFrequencyList.contains(maintenanceFreqValue)) {
              maintenanceFrequencyList.add(maintenanceFreqValue);
            }
            
            // Status handling
            final statusValue = detailedData['status'];
            if (statusValue != null) {
              selectedAssetStatus = statusValue == true ? 'Active' : 'Inactive';
            }
            
            // Override responsible person from detailed data if available
            if (detailedData['responsibleTeam']?.toString().isNotEmpty == true) {
              _responsiblePersonCtrl.text = detailedData['responsibleTeam']?.toString() ?? '';
            }
            
            _stockMsiAssetCtrl.text = detailedData['msiTeam']?.toString() ?? '';
            _additionalNotesCtrl.text = detailedData['remarks']?.toString() ?? '';
          } else {
            // No detailed data - show message and populate only basic fields
            print('DEBUG: No detailed data found, populating basic fields only');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Loading basic information. You can add detailed information and save to create a complete record.'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        });
        
        // Recalculate total cost
        _calculateTotalCost();
        
        if (hasDetailedData) {
          print('DEBUG: Successfully populated all Asset fields using V2 API with detailed data');
        } else {
          print('DEBUG: Successfully populated basic Asset fields using V2 API (no detailed data)');
        }
      } else {
        print('DEBUG: No complete Asset data found from V2 API, using basic data only');
        // Show a user-friendly message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load asset data from API. Please check if the item exists.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error fetching complete Asset details from V2 API: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading asset details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _assetIdCtrl.dispose();
    _assetNameCtrl.dispose();
    _supplierNameCtrl.dispose();
    _productsCtrl.dispose();
    _toolSpecificationsCtrl.dispose();
    _quantityCtrl.dispose();
    _storageLocationCtrl.dispose();

    _poNumberCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _assetCostCtrl.dispose();
    _extraChargesCtrl.dispose();
    _totalAssetCostCtrl.dispose();

    _depreciationPeriodCtrl.dispose();
    _responsiblePersonCtrl.dispose();
    _stockMsiAssetCtrl.dispose();
    _additionalNotesCtrl.dispose();

    super.dispose();
  }

  // ✅ Required label style (UI team)
  Widget _requiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Color.fromRGBO(88, 88, 88, 1),
        ),
        children: const [
          TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  // helper: section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }

  // ✅ Common InputDecoration
  InputDecoration _inputDecoration({
    required Widget label,
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      label: label,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(144, 144, 144, 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 154, 1), width: 1.2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? current,
    required Function(DateTime) onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(0, 89, 154, 1),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onPicked(picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  void _calculateTotalCost() {
    final assetCost = double.tryParse(_assetCostCtrl.text.trim()) ?? 0;
    final extra = double.tryParse(_extraChargesCtrl.text.trim()) ?? 0;
    final total = assetCost + extra;
    _totalAssetCostCtrl.text = total.toStringAsFixed(2);
  }

  // Method to collect form data and submit to API
  Future<void> _submitAsset() async {
    print('DEBUG: _submitAsset called - Current submitting state: $_isSubmitting');
    
    // Prevent multiple submissions
    if (_isSubmitting) {
      print('DEBUG: Submission already in progress, ignoring duplicate call');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Form validation failed');
      return;
    }

    print('DEBUG: Form validation passed, setting submitting state');

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('DEBUG: Proceeding with asset submission');

      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Collect form data
      final assetData = {
        "AssetId": _assetIdCtrl.text.trim(),
        "AssetName": _assetNameCtrl.text.trim(),
        "Category": selectedCategory ?? "",
        "Product": _productsCtrl.text.trim(),
        "Vendor": _supplierNameCtrl.text.trim(),
        "Specifications": _toolSpecificationsCtrl.text.trim(),
        "Quantity": int.tryParse(_quantityCtrl.text) ?? 0,
        "StorageLocation": _storageLocationCtrl.text.trim(),
        "PoNumber": _poNumberCtrl.text.trim(),
        "PoDate": selectedPoDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "InvoiceNumber": _invoiceNumberCtrl.text.trim(),
        "InvoiceDate": selectedInvoiceDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "AssetCost": double.tryParse(_assetCostCtrl.text) ?? 0.0,
        "ExtraCharges": double.tryParse(_extraChargesCtrl.text) ?? 0.0,
        "TotalCost": double.tryParse(_totalAssetCostCtrl.text) ?? 0.0,
        "DepreciationPeriod": _depreciationPeriodCtrl.text.trim(),
        "MaintenanceFrequency": selectedMaintenanceFrequency ?? "",
        "ResponsibleTeam": _responsiblePersonCtrl.text.trim(),
        "MsiTeam": _stockMsiAssetCtrl.text.trim(),
        "Remarks": _additionalNotesCtrl.text.trim(),
        "ItemTypeKey": 1, // 1 for Asset, 2 for Consumable
        "CreatedBy": "User",
        "UpdatedBy": "User",
        "CreatedDate": DateTime.now().toIso8601String(),
        "UpdatedDate": DateTime.now().toIso8601String(),
        "Status": (selectedAssetStatus ?? "Active") == "Active" ? true : false, // ENSURE Status = true for new items
      };

      // CRITICAL: Ensure Status is always true for new Assets
      if (widget.existingData == null) {
        assetData["Status"] = true; // Force Status = 1 for new items
        print('DEBUG: Asset - FORCED Status = true for new item');
      }

      print('DEBUG: Asset data prepared: $assetData');
      print('DEBUG: selectedAssetStatus: "${selectedAssetStatus ?? "NULL"}"');
      print('DEBUG: Final Status value: ${assetData["Status"]}');

      bool success = false;
      String successMessage = '';

      // Check if this is an update or new creation
      if (widget.existingData != null) {
        // Update existing asset using V2 API
        print('DEBUG: Updating existing asset using V2 API');
        success = await ApiService().updateCompleteItemDetailsV2(
          _assetIdCtrl.text.trim(),
          'asset',
          assetData,
        );
        successMessage = 'Asset updated successfully!';
      } else {
        // Create new asset using existing API
        print('DEBUG: Creating new asset using existing API');
        await ApiService().addAssetConsumable(assetData);
        success = true;
        successMessage = 'Asset added successfully!';
        
        // Calculate and store next service date for new asset
        if (selectedMaintenanceFrequency != null && selectedMaintenanceFrequency!.isNotEmpty) {
          try {
            final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
            final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
            
            await nextServiceCalculationService.calculateNextServiceDateForNewItem(
              assetId: _assetIdCtrl.text.trim(),
              assetType: 'Asset',
              createdDate: DateTime.now(),
              maintenanceFrequency: selectedMaintenanceFrequency!,
            );
            
            print('DEBUG: Next service date calculated for new asset');
          } catch (e) {
            print('DEBUG: Error calculating next service date: $e');
          }
        }
      }

      print('DEBUG: Asset operation successful: $success');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Close form dialog
        if (mounted) Navigator.of(context).pop();

        // Call the submit callback
        widget.submit();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        print('DEBUG: Asset operation completed successfully');
      } else {
        // Show error message for update failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update asset. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error in _submitAsset: $e');
      
      // Close loading dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          print('DEBUG: Error closing loading dialog: $popError');
        }
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to ${widget.existingData != null ? 'update' : 'add'} asset: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      // Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        print('DEBUG: Submitting state reset to false');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // HEADER
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.existingData != null ? "Edit Asset" : "Add new asset",
              style: TextStyle(
                color: Color.fromRGBO(0, 0, 0, 1),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.existingData != null 
                ? "Please update the details below and click submit to save changes"
                : "Please enter the details below and click submit to add a new asset",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(88, 88, 88, 1),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // SCROLL BODY
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Asset information
                  _sectionTitle("Asset information"),

                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assetIdCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Asset ID"),
                            hint: "Enter the asset ID",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _assetNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Asset name"),
                            hint: "Enter the asset name",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 2
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: categoryList
                              .map((c) =>
                                  DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedCategory = value);
                          },
                          hint: const Text(
                            "Select the category",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Category"),
                            hint: "Select the category",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                "assets/Icons/drop_down_icon_light_grey.svg",
                                width: 10,
                                height: 10,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _productsCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Products"),
                            hint: "Enter the products",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 3
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _supplierNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Supplier name"),
                            hint: "Enter the supplier name",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _toolSpecificationsCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool specifications"),
                            hint: "Enter the tool specifications",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 4
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Quantity"),
                            hint: "Enter the quantity",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "The field cannot be empty";
                            }
                            if (int.tryParse(v) == null) {
                              return "Enter only numbers";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _storageLocationCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Storage location"),
                            hint: "Enter the storage location",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Purchase information
                  _sectionTitle("Purchase information"),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _poNumberCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("PO number"),
                            hint: "Enter the PO number",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            _pickDate(
                              context: context,
                              current: selectedPoDate,
                              onPicked: (d) => setState(() => selectedPoDate = d),
                            );
                          },
                          decoration: _inputDecoration(
                            label: _requiredLabel("PO date"),
                            hint: "Select the purchase order date",
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(
                            text: _formatDate(selectedPoDate),
                          ),
                          validator: (_) => (selectedPoDate == null)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _invoiceNumberCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Invoice number"),
                            hint: "Enter the invoice number",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            _pickDate(
                              context: context,
                              current: selectedInvoiceDate,
                              onPicked: (d) =>
                                  setState(() => selectedInvoiceDate = d),
                            );
                          },
                          decoration: _inputDecoration(
                            label: _requiredLabel("Invoice date"),
                            hint: "Select the invoice date",
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(
                            text: _formatDate(selectedInvoiceDate),
                          ),
                          validator: (_) => (selectedInvoiceDate == null)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _assetCostCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Asset cost"),
                            hint: "Enter the asset cost",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "The field cannot be empty";
                            }
                            if (double.tryParse(v) == null) {
                              return "Enter only numbers";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _extraChargesCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: const Text(
                              "Extra charges",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(88, 88, 88, 1),
                              ),
                            ),
                            hint: "Enter the extra charges",
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _totalAssetCostCtrl,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: const Text(
                              "Total asset cost",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(88, 88, 88, 1),
                              ),
                            ),
                            hint: "",
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Maintenance and Audit information
                  _sectionTitle("Maintenance and Audit information"),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _depreciationPeriodCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Depreciation period"),
                            hint: "Enter the depreciation period",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedMaintenanceFrequency,
                          isExpanded: true,
                          items: maintenanceFrequencyList
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedMaintenanceFrequency = value);
                          },
                          hint: const Text(
                            "Enter the maintenance frequency",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Maintenance frequency"),
                            hint: "Enter the maintenance frequency",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                "assets/Icons/drop_down_icon_light_grey.svg",
                                width: 10,
                                height: 10,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedAssetStatus,
                          isExpanded: true,
                          items: assetStatusList
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedAssetStatus = value);
                          },
                          hint: const Text(
                            "Select the asset status",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Asset status"),
                            hint: "Select the asset status",
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(14),
                              child: SvgPicture.asset(
                                "assets/Icons/drop_down_icon_light_grey.svg",
                                width: 10,
                                height: 10,
                              ),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12, color: Colors.black),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _responsiblePersonCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Responsible person/team"),
                            hint: "Enter the responsible person/team",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _stockMsiAssetCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Stock MSI asset"),
                            hint: "Enter the stock MSI asset",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _additionalNotesCtrl,
                    decoration: _inputDecoration(
                      label: _requiredLabel("Additional notes"),
                      hint: "Enter the additional notes",
                    ),
                    style: const TextStyle(fontSize: 12),
                    validator: (v) => (v == null || v.isEmpty)
                        ? "The field cannot be empty"
                        : null,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Cancel Button
              SizedBox(
                width: 120,
                height: 36,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color.fromRGBO(0, 89, 154, 1), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color.fromRGBO(0, 89, 154, 1),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Submit Button
              SizedBox(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAsset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting 
                        ? Colors.grey 
                        : const Color.fromRGBO(0, 89, 154, 1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.existingData != null ? "Update" : "Submit",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

