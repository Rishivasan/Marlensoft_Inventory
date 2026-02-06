import 'package:flutter/material.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/services/next_service_calculation_service.dart';
import 'package:provider/provider.dart';

class AddTool extends StatefulWidget {
  const AddTool({
    super.key, 
    required this.submit,
    this.existingData, // Add parameter for existing Tool data
  });

  final VoidCallback submit;
  final MasterListModel? existingData; // Existing data for editing

  @override
  State<AddTool> createState() => _AddToolState();
}

class _AddToolState extends State<AddTool> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false; // Add submission state tracking
  bool _isLoadingDetails = false; // Add loading state for fetching details

  // Tool information
  final _toolIdCtrl = TextEditingController();
  final _toolNameCtrl = TextEditingController();
  String? selectedToolType;

  final _articleCodeCtrl = TextEditingController();
  final _associatedProductNameCtrl = TextEditingController();
  final _supplierNameCtrl = TextEditingController();
  final _toolSpecificationsCtrl = TextEditingController();
  final _storageLocationCtrl = TextEditingController();

  // Purchase information
  final _poNumberCtrl = TextEditingController();
  DateTime? selectedPoDate;

  final _invoiceNumberCtrl = TextEditingController();
  DateTime? selectedInvoiceDate;

  final _toolCostCtrl = TextEditingController();
  final _extraChargesCtrl = TextEditingController();
  final _totalToolCostCtrl = TextEditingController(text: "0.00");

  // Maintenance & Audit info
  final _toolLifespanCtrl = TextEditingController();
  final _auditIntervalCtrl = TextEditingController();
  String? selectedMaintenanceFrequency;

  bool toolHandlingCertificateAvailable = false;

  final _lastAuditNotesCtrl = TextEditingController();
  DateTime? selectedLastAuditDate;

  final _maximumToolOutputCtrl = TextEditingController();
  String? selectedToolStatus;

  final _responsiblePersonCtrl = TextEditingController();
  final _stockMsiAssetCtrl = TextEditingController();
  final _kermAssetCtrl = TextEditingController();
  final _additionalNotesCtrl = TextEditingController();

  // Dropdown values - made mutable to allow adding database values
  final List<String> toolTypeList = [
    "Hand Tool",
    "Power Tool",
    "Measuring Tool",
    "Cutting Tool",
  ];

  final List<String> maintenanceFrequencyList = [
    "Daily",
    "Weekly",
    "Monthly",
    "Quarterly",
    "Yearly",
  ];

  final List<String> toolStatusList = [
    "Active",
    "Inactive",
    "Under Maintenance",
    "Scrapped",
  ];

  // Method to collect form data and submit to API
  Future<void> _submitTool() async {
    print('DEBUG: _submitTool called - Current submitting state: $_isSubmitting');
    
    // Prevent multiple submissions
    if (_isSubmitting) {
      print('DEBUG: Tool submission already in progress, ignoring duplicate call');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Tool Form validation failed');
      return;
    }

    print('DEBUG: Tool Form validation passed, setting submitting state');

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('DEBUG: Proceeding with Tool submission');

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
      final toolData = {
        "ToolsId": _toolIdCtrl.text.trim(),
        "ToolName": _toolNameCtrl.text.trim(),
        "ToolType": selectedToolType ?? "",
        "AssociatedProduct": _associatedProductNameCtrl.text.trim(),
        "ArticleCode": _articleCodeCtrl.text.trim(),
        "Vendor": _supplierNameCtrl.text.trim(),
        "Specifications": _toolSpecificationsCtrl.text.trim(),
        "StorageLocation": _storageLocationCtrl.text.trim(),
        "PoNumber": _poNumberCtrl.text.trim(),
        "PoDate": selectedPoDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "InvoiceNumber": _invoiceNumberCtrl.text.trim(),
        "InvoiceDate": selectedInvoiceDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "ToolCost": double.tryParse(_toolCostCtrl.text) ?? 0.0,
        "ExtraCharges": double.tryParse(_extraChargesCtrl.text) ?? 0.0,
        "TotalCost": double.tryParse(_totalToolCostCtrl.text) ?? 0.0,
        "Lifespan": _toolLifespanCtrl.text.trim(),
        "MaintainanceFrequency": selectedMaintenanceFrequency ?? "",
        "HandlingCertificate": toolHandlingCertificateAvailable,
        "AuditInterval": _auditIntervalCtrl.text.trim(),
        "MaxOutput": int.tryParse(_maximumToolOutputCtrl.text) ?? 0,
        "LastAuditDate": selectedLastAuditDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "LastAuditNotes": _lastAuditNotesCtrl.text.trim(),
        "ResponsibleTeam": _responsiblePersonCtrl.text.trim(),
        "Notes": _additionalNotesCtrl.text.trim(),
        "MsiAsset": _stockMsiAssetCtrl.text.trim(),
        "KernAsset": _kermAssetCtrl.text.trim(),
        "CreatedBy": "User",
        "UpdatedBy": "User",
        "CreatedDate": DateTime.now().toIso8601String(),
        "UpdatedDate": DateTime.now().toIso8601String(),
        "Status": (selectedToolStatus ?? "Active") == "Active" ? true : false, // ENSURE Status = true for new items
      };

      // CRITICAL: Ensure Status is always true for new Tools
      if (widget.existingData == null) {
        toolData["Status"] = true; // Force Status = 1 for new items
        print('DEBUG: Tool - FORCED Status = true for new item');
      }

      print('DEBUG: Tool data prepared: $toolData');
      print('DEBUG: selectedToolStatus: "${selectedToolStatus ?? "NULL"}"');
      print('DEBUG: Final Status value: ${toolData["Status"]}');

      bool success = false;
      String successMessage = '';

      // Check if this is an update or new creation
      if (widget.existingData != null) {
        // Update existing tool using V2 API
        print('DEBUG: Updating existing tool using V2 API');
        success = await ApiService().updateCompleteItemDetailsV2(
          _toolIdCtrl.text.trim(),
          'tool',
          toolData,
        );
        successMessage = 'Tool updated successfully!';
      } else {
        // Create new tool using existing API
        print('DEBUG: Creating new tool using existing API');
        await ApiService().addTool(toolData);
        success = true;
        successMessage = 'Tool added successfully!';
        
        // Calculate and store next service date for new tool
        if (selectedMaintenanceFrequency != null && selectedMaintenanceFrequency!.isNotEmpty) {
          try {
            final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
            final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
            
            await nextServiceCalculationService.calculateNextServiceDateForNewItem(
              assetId: _toolIdCtrl.text.trim(),
              assetType: 'Tool',
              createdDate: DateTime.now(),
              maintenanceFrequency: selectedMaintenanceFrequency!,
            );
            
            print('DEBUG: Next service date calculated for new tool');
          } catch (e) {
            print('DEBUG: Error calculating next service date: $e');
          }
        }
      }

      print('DEBUG: Tool operation successful: $success');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Close the add/edit tool dialog
        if (mounted) Navigator.of(context).pop();

        // Call the submit callback to refresh the list
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
        
        print('DEBUG: Tool operation completed successfully');
      } else {
        // Show error message for update failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update tool. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error in _submitTool: $e');
      
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
            content: Text("Failed to ${widget.existingData != null ? 'update' : 'add'} tool: ${e.toString()}"),
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
        print('DEBUG: Tool submitting state reset to false');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _toolCostCtrl.addListener(_calculateTotalCost);
    _extraChargesCtrl.addListener(_calculateTotalCost);
    
    // Pre-populate form if existing data is provided
    if (widget.existingData != null) {
      _populateFormWithExistingData();
    } else {
      // Set default values for new tools
      selectedToolStatus = "Active"; // Default to Active for new items
    }
  }
  
  void _populateFormWithExistingData() {
    final data = widget.existingData!;
    
    // Basic information from MasterListModel
    _toolIdCtrl.text = data.assetId;
    _toolNameCtrl.text = data.name;
    _supplierNameCtrl.text = data.supplier;
    _storageLocationCtrl.text = data.location;
    
    print('DEBUG: Pre-populated Tool form with basic data: ${data.name}');
    
    // Fetch complete Tool details from the Tool table
    _fetchCompleteToolDetails(data.assetId);
  }
  
  Future<void> _fetchCompleteToolDetails(String toolId) async {
    print('🔍 DEBUG: Fetching complete Tool details for ID: $toolId using V2 API');
    
    setState(() {
      _isLoadingDetails = true;
    });
    
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetailsV2(toolId, 'tool');
      
      print('📦 DEBUG: Raw API response: $completeData');
      
      if (completeData != null) {
        print('✅ DEBUG: Complete Tool data received from V2 API');
        
        final masterData = completeData['MasterData'] != null 
            ? Map<String, dynamic>.from(completeData['MasterData'] as Map) 
            : null;
        final detailedData = completeData['DetailedData'] != null 
            ? Map<String, dynamic>.from(completeData['DetailedData'] as Map) 
            : null;
        final hasDetailedData = completeData['HasDetailedData'] == true;
        
        print('🔍 DEBUG: MasterData: $masterData');
        print('🔍 DEBUG: DetailedData: $detailedData');
        print('🔍 DEBUG: HasDetailedData: $hasDetailedData');
        
        // Populate all Tool-specific fields
        print('🔧 DEBUG: About to call setState to populate fields');
        setState(() {
          print('🔧 DEBUG: Inside setState - starting field population');
          
          // Always populate basic fields from master data
          if (masterData != null) {
            print('🔧 DEBUG: Populating master data fields');
            _toolIdCtrl.text = masterData['itemID']?.toString() ?? _toolIdCtrl.text;
            _toolNameCtrl.text = masterData['itemName']?.toString() ?? _toolNameCtrl.text;
            _supplierNameCtrl.text = masterData['vendor']?.toString() ?? _supplierNameCtrl.text;
            _storageLocationCtrl.text = masterData['storageLocation']?.toString() ?? _storageLocationCtrl.text;
            _responsiblePersonCtrl.text = masterData['responsibleTeam']?.toString() ?? _responsiblePersonCtrl.text;
            print('🔧 DEBUG: Master data fields populated');
          }
          
          // If we have detailed data, populate all detailed fields
          if (hasDetailedData && detailedData != null) {
            print('🔧 DEBUG: Populating detailed data fields');
            
            // Basic Tool fields - using camelCase field names from backend
            // Tool type - show actual database value, add to list if not present
            final toolTypeValue = detailedData['toolType']?.toString();
            selectedToolType = toolTypeValue;
            // Add the database value to dropdown list if it doesn't exist
            if (toolTypeValue != null && toolTypeValue.isNotEmpty && !toolTypeList.contains(toolTypeValue)) {
              toolTypeList.add(toolTypeValue);
            }
            
            _associatedProductNameCtrl.text = detailedData['associatedProduct']?.toString() ?? '';
            _articleCodeCtrl.text = detailedData['articleCode']?.toString() ?? '';
            _toolSpecificationsCtrl.text = detailedData['specifications']?.toString() ?? '';
            
            // Purchase information - using camelCase field names
            _poNumberCtrl.text = detailedData['poNumber']?.toString() ?? '';
            _invoiceNumberCtrl.text = detailedData['invoiceNumber']?.toString() ?? '';
            _toolCostCtrl.text = detailedData['toolCost']?.toString() ?? '';
            _extraChargesCtrl.text = detailedData['extraCharges']?.toString() ?? '';
            
            // Dates - using camelCase field names
            if (detailedData['poDate'] != null) {
              selectedPoDate = DateTime.tryParse(detailedData['poDate'].toString());
            }
            if (detailedData['invoiceDate'] != null) {
              selectedInvoiceDate = DateTime.tryParse(detailedData['invoiceDate'].toString());
            }
            if (detailedData['lastAuditDate'] != null) {
              selectedLastAuditDate = DateTime.tryParse(detailedData['lastAuditDate'].toString());
            }
            
            // Maintenance & Audit info - using camelCase field names
            _toolLifespanCtrl.text = detailedData['lifespan']?.toString() ?? '';
            _auditIntervalCtrl.text = detailedData['auditInterval']?.toString() ?? '';
            // Maintenance frequency - show actual database value, add to list if not present
            final maintenanceFreqValue = detailedData['maintainanceFrequency']?.toString();
            selectedMaintenanceFrequency = maintenanceFreqValue;
            // Add the database value to dropdown list if it doesn't exist
            if (maintenanceFreqValue != null && maintenanceFreqValue.isNotEmpty && !maintenanceFrequencyList.contains(maintenanceFreqValue)) {
              maintenanceFrequencyList.add(maintenanceFreqValue);
            }
            toolHandlingCertificateAvailable = detailedData['handlingCertificate'] == true;
            _lastAuditNotesCtrl.text = detailedData['lastAuditNotes']?.toString() ?? '';
            _maximumToolOutputCtrl.text = detailedData['maxOutput']?.toString() ?? '';
            
            // Status handling
            final statusValue = detailedData['status'];
            if (statusValue != null) {
              selectedToolStatus = statusValue == true ? 'Active' : 'Inactive';
            }
            
            // Override responsible person from detailed data if available
            if (detailedData['responsibleTeam']?.toString().isNotEmpty == true) {
              _responsiblePersonCtrl.text = detailedData['responsibleTeam']?.toString() ?? '';
            }
            
            _stockMsiAssetCtrl.text = detailedData['msiAsset']?.toString() ?? '';
            _kermAssetCtrl.text = detailedData['kernAsset']?.toString() ?? '';
            _additionalNotesCtrl.text = detailedData['notes']?.toString() ?? '';
            
            print('✅ DEBUG: All detailed fields populated successfully');
          } else {
            // No detailed data - show message and populate only basic fields
            print('⚠️ DEBUG: No detailed data found, populating basic fields only');
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
          
          print('✅ DEBUG: setState completed - all fields should be populated');
        });
        
        // Recalculate total cost
        _calculateTotalCost();
        
        if (hasDetailedData) {
          print('✅ DEBUG: Successfully populated all Tool fields using V2 API with detailed data');
        } else {
          print('⚠️ DEBUG: Successfully populated basic Tool fields using V2 API (no detailed data)');
        }
      } else {
        print('❌ DEBUG: No complete Tool data found from V2 API, using basic data only');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load tool data from API. Please check if the item exists.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('💥 DEBUG: Error fetching complete Tool details from V2 API: $e');
      print('📋 DEBUG: Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tool details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDetails = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _toolIdCtrl.dispose();
    _toolNameCtrl.dispose();
    _articleCodeCtrl.dispose();
    _associatedProductNameCtrl.dispose();
    _supplierNameCtrl.dispose();
    _toolSpecificationsCtrl.dispose();
    _storageLocationCtrl.dispose();

    _poNumberCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _toolCostCtrl.dispose();
    _extraChargesCtrl.dispose();
    _totalToolCostCtrl.dispose();

    _toolLifespanCtrl.dispose();
    _auditIntervalCtrl.dispose();
    _lastAuditNotesCtrl.dispose();
    _maximumToolOutputCtrl.dispose();
    _responsiblePersonCtrl.dispose();
    _stockMsiAssetCtrl.dispose();
    _kermAssetCtrl.dispose();
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

  // ✅ Common InputDecoration for all fields
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
    final toolCost = double.tryParse(_toolCostCtrl.text.trim()) ?? 0;
    final extra = double.tryParse(_extraChargesCtrl.text.trim()) ?? 0;
    final total = toolCost + extra;
    _totalToolCostCtrl.text = total.toStringAsFixed(2);
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
              widget.existingData != null ? "Edit Tool" : "Add new tool",
              style: const TextStyle(
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
                : "Please enter the details below and click submit to add a new tool",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(88, 88, 88, 1),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Show loading indicator when fetching details
          if (_isLoadingDetails)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Loading detailed information...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // FIELDS SCROLL
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tool information
                  _sectionTitle("Tool information"),

                  // Row 1
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _toolIdCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool ID"),
                            hint: "Enter the tool ID",
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
                          controller: _toolNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool name"),
                            hint: "Enter the tool name",
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
                          value: selectedToolType,
                          isExpanded: true,
                          items: toolTypeList
                              .map((t) =>
                                  DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedToolType = value;
                            });
                          },
                          hint: const Text(
                            "Select the tool type",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool type"),
                            hint: "Select the tool type",
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
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
                          controller: _associatedProductNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Associated product name"),
                            hint: "Enter the associated product name",
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
                          controller: _articleCodeCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Article code"),
                            hint: "Enter the article code",
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
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 4
                  Row(
                    children: [
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
                          decoration: _inputDecoration(
                            label: _requiredLabel("PO date"),
                            hint: "Select the purchase order date",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              onPressed: () {
                                _pickDate(
                                  context: context,
                                  current: selectedPoDate,
                                  onPicked: (d) {
                                    setState(() => selectedPoDate = d);
                                  },
                                );
                              },
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
                          decoration: _inputDecoration(
                            label: _requiredLabel("Invoice date"),
                            hint: "Select the invoice date",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              onPressed: () {
                                _pickDate(
                                  context: context,
                                  current: selectedInvoiceDate,
                                  onPicked: (d) {
                                    setState(() => selectedInvoiceDate = d);
                                  },
                                );
                              },
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
                          controller: _toolCostCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool cost"),
                            hint: "Enter the tool cost",
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
                          controller: _totalToolCostCtrl,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: const Text(
                              "Total tool cost",
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

                  // Maintenance & Audit information
                  _sectionTitle("Maintenance & Audit information"),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _toolLifespanCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool lifespan"),
                            hint: "Enter the tool lifespan",
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
                          controller: _auditIntervalCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Audit interval"),
                            hint: "Enter the audit interval",
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
                        child: DropdownButtonFormField<String>(
                          value: selectedMaintenanceFrequency,
                          isExpanded: true,
                          items: maintenanceFrequencyList
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMaintenanceFrequency = value;
                            });
                          },
                          hint: const Text(
                            "Select the maintenance frequency",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Maintenance frequency"),
                            hint: "Select the maintenance frequency",
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
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
                        child: CheckboxListTile(
                          title: const Text(
                            "Tool handling certificate available",
                            style: TextStyle(fontSize: 12),
                          ),
                          value: toolHandlingCertificateAvailable,
                          onChanged: (v) {
                            setState(() {
                              toolHandlingCertificateAvailable = v ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lastAuditNotesCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Last audit notes"),
                            hint: "Enter the last audit notes",
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
                          decoration: _inputDecoration(
                            label: _requiredLabel("Last audit date"),
                            hint: "Select the last audit date",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              onPressed: () {
                                _pickDate(
                                  context: context,
                                  current: selectedLastAuditDate,
                                  onPicked: (d) {
                                    setState(() => selectedLastAuditDate = d);
                                  },
                                );
                              },
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(
                            text: _formatDate(selectedLastAuditDate),
                          ),
                          validator: (_) => (selectedLastAuditDate == null)
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
                          controller: _maximumToolOutputCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Maximum tool output"),
                            hint: "Enter the maximum tool output",
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
                        child: DropdownButtonFormField<String>(
                          value: selectedToolStatus,
                          isExpanded: true,
                          items: toolStatusList
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedToolStatus = value;
                            });
                          },
                          hint: const Text(
                            "Select the tool status",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Tool status"),
                            hint: "Select the tool status",
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
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
                      const SizedBox(width: 24),
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
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _kermAssetCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Kerm asset"),
                            hint: "Enter the kerm asset",
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
                          controller: _additionalNotesCtrl,
                          maxLines: 3,
                          decoration: _inputDecoration(
                            label: const Text(
                              "Additional notes",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color.fromRGBO(88, 88, 88, 1),
                              ),
                            ),
                            hint: "Enter additional notes",
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

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
                  onPressed: _isSubmitting ? null : _submitTool,
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