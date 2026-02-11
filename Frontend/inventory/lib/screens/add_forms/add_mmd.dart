import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/services/next_service_calculation_service.dart';
import 'package:provider/provider.dart';

class AddMmd extends StatefulWidget {
  const AddMmd({
    super.key, 
    required this.submit,
    this.existingData, // Add parameter for existing MMD data
  });

  final VoidCallback submit;
  final MasterListModel? existingData; // Existing data for editing

  @override
  State<AddMmd> createState() => _AddMmdState();
}

class _AddMmdState extends State<AddMmd> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false; // Add submission state tracking

  // Measuring and monitoring device information
  final _assetIdCtrl = TextEditingController();
  final _assetNameCtrl = TextEditingController();

  final _brandNameCtrl = TextEditingController();
  final _accuracyClassCtrl = TextEditingController();

  final _supplierNameCtrl = TextEditingController();
  final _calibratedByCtrl = TextEditingController();

  final _toolSpecificationsCtrl = TextEditingController();
  final _modelNumberCtrl = TextEditingController();

  final _serialNumberCtrl = TextEditingController();
  final _quantityAvailableCtrl = TextEditingController();

  final _calibrationCertificateNumberCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  // Purchase information
  final _poNumberCtrl = TextEditingController();
  DateTime? selectedPoDate;

  final _invoiceNumberCtrl = TextEditingController();
  DateTime? selectedInvoiceDate;

  final _costCtrl = TextEditingController();
  final _extraChargesCtrl = TextEditingController();
  final _totalCostCtrl = TextEditingController(text: "0.00");

  // Calibration information
  String? selectedCalibrationFrequency;
  DateTime? selectedLastCalibrationDate;
  DateTime? selectedNextCalibrationDate;

  String? selectedCalibrationStatus;
  final _warrantyPeriodCtrl = TextEditingController();

  final _operatingInstructionsManualCtrl = TextEditingController();
  final _responsiblePersonCtrl = TextEditingController();
  final _stockMsiAssetCtrl = TextEditingController();
  final _additionalNotesCtrl = TextEditingController();

  // Dropdown values
  final List<String> calibrationFrequencyList = [
    "Monthly",
    "Quarterly",
    "Half-yearly",
    "Yearly",
  ];

  final List<String> calibrationStatusList = [
    "Calibrated",
    "Due",
    "Overdue",
  ];

  @override
  void initState() {
    super.initState();
    _costCtrl.addListener(_calculateTotalCost);
    _extraChargesCtrl.addListener(_calculateTotalCost);
    
    // Pre-populate form if existing data is provided
    if (widget.existingData != null) {
      _populateFormWithExistingData();
    } else {
      // Set default values for new MMDs - ENSURE Status = 1 (true)
      selectedCalibrationStatus = "Calibrated"; // Default to Calibrated for new items
      print('DEBUG: MMD initState - Set default selectedCalibrationStatus = "Calibrated"');
    }
    
    // Add a post-frame callback to ensure the default value is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.existingData == null && selectedCalibrationStatus == null) {
        setState(() {
          selectedCalibrationStatus = "Calibrated";
        });
        print('DEBUG: MMD post-frame - Ensured selectedCalibrationStatus = "Calibrated"');
      }
    });
  }
  
  void _populateFormWithExistingData() {
    final data = widget.existingData!;
    
    // Basic information from MasterListModel
    _assetIdCtrl.text = data.assetId;
    _assetNameCtrl.text = data.name;
    _supplierNameCtrl.text = data.supplier;
    _locationCtrl.text = data.location;
    
    print('DEBUG: Pre-populated MMD form with basic data: ${data.name}');
    
    // Fetch complete MMD details from the MMD table
    _fetchCompleteMMDDetails(data.assetId);
  }
  
  Future<void> _fetchCompleteMMDDetails(String mmdId) async {
    print('DEBUG: Fetching complete MMD details for ID: $mmdId using V2 API');
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetailsV2(mmdId, 'mmd');
      
      if (completeData != null) {
        print('DEBUG: Complete MMD data received from V2 API: $completeData');
        
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
        
        // Populate all MMD-specific fields
        setState(() {
          // Always populate basic fields from master data
          if (masterData != null) {
            _assetIdCtrl.text = masterData['itemID']?.toString() ?? _assetIdCtrl.text;
            _assetNameCtrl.text = masterData['itemName']?.toString() ?? _assetNameCtrl.text;
            _supplierNameCtrl.text = masterData['vendor']?.toString() ?? _supplierNameCtrl.text;
            _locationCtrl.text = masterData['storageLocation']?.toString() ?? _locationCtrl.text;
            _responsiblePersonCtrl.text = masterData['responsibleTeam']?.toString() ?? _responsiblePersonCtrl.text;
          }
          
          // If we have detailed data, populate all detailed fields - using camelCase field names
          if (hasDetailedData && detailedData != null) {
            // Brand name field - handle if it exists in the data
            _brandNameCtrl.text = detailedData['brandName']?.toString() ?? '';
            _accuracyClassCtrl.text = detailedData['accuracyClass']?.toString() ?? '';
            _calibratedByCtrl.text = detailedData['calibratedBy']?.toString() ?? '';
            _toolSpecificationsCtrl.text = detailedData['specifications']?.toString() ?? '';
            _modelNumberCtrl.text = detailedData['modelNumber']?.toString() ?? '';
            _serialNumberCtrl.text = detailedData['serialNumber']?.toString() ?? '';
            _quantityAvailableCtrl.text = detailedData['quantity']?.toString() ?? '';
            _calibrationCertificateNumberCtrl.text = detailedData['calibrationCertNo']?.toString() ?? '';
            
            // Location field - try multiple possible field names and use the first non-empty one
            String locationValue = '';
            if (detailedData['location']?.toString().isNotEmpty == true) {
              locationValue = detailedData['location']?.toString() ?? '';
            } else if (detailedData['storageLocation']?.toString().isNotEmpty == true) {
              locationValue = detailedData['storageLocation']?.toString() ?? '';
            } else if (masterData != null && masterData['storageLocation']?.toString().isNotEmpty == true) {
              locationValue = masterData['storageLocation']?.toString() ?? '';
            }
            _locationCtrl.text = locationValue;
            
            print('DEBUG: Location field populated with: "$locationValue"');
            
            // Purchase information - using camelCase field names
            _poNumberCtrl.text = detailedData['poNumber']?.toString() ?? '';
            _invoiceNumberCtrl.text = detailedData['invoiceNumber']?.toString() ?? '';
            _costCtrl.text = detailedData['totalCost']?.toString() ?? '';
            _extraChargesCtrl.text = detailedData['extraCharges']?.toString() ?? '';
            
            // Dates - using camelCase field names
            if (detailedData['poDate'] != null) {
              selectedPoDate = DateTime.tryParse(detailedData['poDate'].toString());
            }
            if (detailedData['invoiceDate'] != null) {
              selectedInvoiceDate = DateTime.tryParse(detailedData['invoiceDate'].toString());
            }
            if (detailedData['lastCalibration'] != null) {
              selectedLastCalibrationDate = DateTime.tryParse(detailedData['lastCalibration'].toString());
            }
            if (detailedData['nextCalibration'] != null) {
              selectedNextCalibrationDate = DateTime.tryParse(detailedData['nextCalibration'].toString());
            }
            
            // Dropdowns - using camelCase field names and handling null/empty values
            final calibrationFreqValue = detailedData['calibrationFrequency']?.toString();
            if (calibrationFreqValue != null && calibrationFreqValue.isNotEmpty) {
              // Check if the value exists in the dropdown list
              if (calibrationFrequencyList.contains(calibrationFreqValue)) {
                selectedCalibrationFrequency = calibrationFreqValue;
              } else {
                // Add the database value to dropdown list if it doesn't exist
                calibrationFrequencyList.add(calibrationFreqValue);
                selectedCalibrationFrequency = calibrationFreqValue;
              }
            }
            
            // Status handling - convert boolean status to calibration status
            final statusValue = detailedData['status'];
            if (statusValue != null) {
              final statusString = statusValue == true ? 'Calibrated' : 'Due';
              // Check if the status exists in the dropdown list
              if (calibrationStatusList.contains(statusString)) {
                selectedCalibrationStatus = statusString;
              } else {
                // Add the status to dropdown list if it doesn't exist
                calibrationStatusList.add(statusString);
                selectedCalibrationStatus = statusString;
              }
            }
            
            // Other fields - using camelCase field names
            _warrantyPeriodCtrl.text = detailedData['warrantyYears']?.toString() ?? '';
            _operatingInstructionsManualCtrl.text = detailedData['manualLink']?.toString() ?? '';
            
            // Override responsible person from detailed data if available
            if (detailedData['responsibleTeam']?.toString().isNotEmpty == true) {
              _responsiblePersonCtrl.text = detailedData['responsibleTeam']?.toString() ?? '';
            }
            
            _stockMsiAssetCtrl.text = detailedData['stockMsi']?.toString() ?? '';
            _additionalNotesCtrl.text = detailedData['remarks']?.toString() ?? '';
          } else {
            // No detailed data - populate location from master data if available
            if (masterData != null && masterData['storageLocation']?.toString().isNotEmpty == true) {
              _locationCtrl.text = masterData['storageLocation']?.toString() ?? '';
              print('DEBUG: Location populated from master data: "${_locationCtrl.text}"');
            }
            
            // Show message and populate only basic fields
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
          print('DEBUG: Successfully populated all MMD fields using V2 API with detailed data');
        } else {
          print('DEBUG: Successfully populated basic MMD fields using V2 API (no detailed data)');
        }
      } else {
        print('DEBUG: No complete MMD data found from V2 API, using basic data only');
        // Show a user-friendly message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not load MMD data from API. Please check if the item exists.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error fetching complete MMD details from V2 API: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading MMD details: $e'),
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
    _brandNameCtrl.dispose();
    _accuracyClassCtrl.dispose();
    _supplierNameCtrl.dispose();
    _calibratedByCtrl.dispose();
    _toolSpecificationsCtrl.dispose();
    _modelNumberCtrl.dispose();
    _serialNumberCtrl.dispose();
    _quantityAvailableCtrl.dispose();
    _calibrationCertificateNumberCtrl.dispose();
    _locationCtrl.dispose();

    _poNumberCtrl.dispose();
    _invoiceNumberCtrl.dispose();
    _costCtrl.dispose();
    _extraChargesCtrl.dispose();
    _totalCostCtrl.dispose();

    _warrantyPeriodCtrl.dispose();
    _operatingInstructionsManualCtrl.dispose();
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
    final cost = double.tryParse(_costCtrl.text.trim()) ?? 0;
    final extra = double.tryParse(_extraChargesCtrl.text.trim()) ?? 0;
    final total = cost + extra;
    _totalCostCtrl.text = total.toStringAsFixed(2);
  }

  // Method to collect form data and submit to API
  Future<void> _submitMmd() async {
    print('DEBUG: _submitMmd called - Current submitting state: $_isSubmitting');
    
    // Prevent multiple submissions
    if (_isSubmitting) {
      print('DEBUG: MMD submission already in progress, ignoring duplicate call');
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: MMD Form validation failed');
      return;
    }

    print('DEBUG: MMD Form validation passed, setting submitting state');

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('DEBUG: Proceeding with MMD submission');

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

      // Collect form data (using PascalCase to match MmdsEntity properties)
      final mmdData = {
        "MmdId": _assetIdCtrl.text.trim(),
        "BrandName": _brandNameCtrl.text.trim(),  // Added BrandName field
        "AccuracyClass": _accuracyClassCtrl.text.trim(),
        "Vendor": _supplierNameCtrl.text.trim(),
        "CalibratedBy": _calibratedByCtrl.text.trim(),
        "Specifications": _toolSpecificationsCtrl.text.trim(),
        "ModelNumber": _modelNumberCtrl.text.trim(),
        "SerialNumber": _serialNumberCtrl.text.trim(),
        "Quantity": int.tryParse(_quantityAvailableCtrl.text) ?? 0,
        "CalibrationCertNo": _calibrationCertificateNumberCtrl.text.trim(),
        "Location": _locationCtrl.text.trim(),
        "PoNumber": _poNumberCtrl.text.trim(),
        "PoDate": selectedPoDate?.toIso8601String(),
        "InvoiceNumber": _invoiceNumberCtrl.text.trim(),
        "InvoiceDate": selectedInvoiceDate?.toIso8601String(),
        "TotalCost": double.tryParse(_totalCostCtrl.text) ?? 0.0,
        "CalibrationFrequency": selectedCalibrationFrequency ?? "",
        "LastCalibration": selectedLastCalibrationDate?.toIso8601String(),
        "NextCalibration": selectedNextCalibrationDate?.toIso8601String(),
        "WarrantyYears": int.tryParse(_warrantyPeriodCtrl.text) ?? 0,
        "CalibrationStatus": selectedCalibrationStatus ?? "Calibrated", // Fallback to Calibrated
        "ResponsibleTeam": _responsiblePersonCtrl.text.trim(),
        "ManualLink": _operatingInstructionsManualCtrl.text.trim(),
        "StockMsi": _stockMsiAssetCtrl.text.trim(),
        "Remarks": _additionalNotesCtrl.text.trim(),
        "CreatedBy": "User",
        "UpdatedBy": "User",
        "CreatedDate": DateTime.now().toIso8601String(),
        "UpdatedDate": DateTime.now().toIso8601String(),
        "Status": (selectedCalibrationStatus ?? "Calibrated") == "Calibrated" ? true : false, // ENSURE Status = true for new items
      };

      // CRITICAL: Ensure Status is always true for new MMDs
      if (widget.existingData == null) {
        mmdData["Status"] = true; // Force Status = 1 for new items
        print('DEBUG: MMD - FORCED Status = true for new item');
      }

      // print('DEBUG: MMD data prepared: $mmdData');
      // print('DEBUG: selectedCalibrationStatus: "${selectedCalibrationStatus ?? "NULL"}"');
      // print('DEBUG: Final Status value: ${mmdData["Status"]}');
      // print('DEBUG: Status will be set to: ${(selectedCalibrationStatus ?? "Calibrated") == "Calibrated" ? true : false}');

      bool success = false;
      String successMessage = '';

      // Check if this is an update or new creation
      if (widget.existingData != null) {
        // Update existing MMD using V2 API
        print('DEBUG: Updating existing MMD using V2 API');
        success = await ApiService().updateCompleteItemDetailsV2(
          _assetIdCtrl.text.trim(),
          'mmd',
          mmdData,
        );
        successMessage = 'MMD updated successfully!';
      } else {
        // Create new MMD using existing API
        print('DEBUG: Creating new MMD using existing API');
        await ApiService().addMmd(mmdData);
        success = true;
        successMessage = 'MMD added successfully!';
        
        // Calculate and store next service date for new MMD
        if (selectedCalibrationFrequency != null && selectedCalibrationFrequency!.isNotEmpty) {
          try {
            final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
            final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
            
            await nextServiceCalculationService.calculateNextServiceDateForNewItem(
              assetId: _assetIdCtrl.text.trim(),
              assetType: 'MMD',
              createdDate: DateTime.now(),
              maintenanceFrequency: selectedCalibrationFrequency!,
            );
            
            print('DEBUG: Next calibration date calculated for new MMD');
          } catch (e) {
            print('DEBUG: Error calculating next calibration date: $e');
          }
        }
      }

      print('DEBUG: MMD operation successful: $success');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Close form dialog
        if (mounted) Navigator.of(context).pop();

        // Show success message first
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Add a small delay to ensure database transaction is committed before refreshing
        await Future.delayed(const Duration(milliseconds: 500));

        // Call the submit callback to refresh the master list
        widget.submit();
        
        print('DEBUG: MMD operation completed successfully');
      } else {
        // Show error message for update failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update MMD. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error in _submitMmd: $e');
      
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
            content: Text("Failed to ${widget.existingData != null ? 'update' : 'add'} MMD: $e"),
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
        print('DEBUG: MMD submitting state reset to false');
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
              widget.existingData != null ? "Edit MMD" : "Add new MMDs",
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
                : "Please enter the details below and click submit to add a new MMDs",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(88, 88, 88, 1),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // SCROLL ONLY FIELDS
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Measuring and monitoring device information"),

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
                        child: TextFormField(
                          controller: _brandNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Brand name"),
                            hint: "Enter the brand name",
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
                          controller: _accuracyClassCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Accuracy class"),
                            hint: "Enter the accuracy class",
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
                          controller: _calibratedByCtrl,
                          decoration: _inputDecoration(
                            label:
                                _requiredLabel("Calibrated by (Accredited lab)"),
                            hint: "Enter the calibrated by name",
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
                          controller: _modelNumberCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Model number"),
                            hint: "Enter the model number",
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

                  // Row 5
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _serialNumberCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Serial number"),
                            hint: "Enter the serial number",
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
                          controller: _quantityAvailableCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Quantity available"),
                            hint: "Enter the available quantity",
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
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Row 6
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _calibrationCertificateNumberCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel(
                                "Calibration certificate number"),
                            hint: "Enter the calibration certificate number",
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
                          controller: _locationCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Location"),
                            hint: "Enter the location",
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
                              onPicked: (d) =>
                                  setState(() => selectedPoDate = d),
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
                          controller: _costCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Cost"),
                            hint: "Enter the cost",
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
                          controller: _totalCostCtrl,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: const Text(
                              "Total cost",
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

                  // Calibration information
                  _sectionTitle("Calibration information"),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCalibrationFrequency,
                          isExpanded: true,
                          items: calibrationFrequencyList
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedCalibrationFrequency = value);
                          },
                          hint: const Text(
                            "Enter the calibration frequency",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Calibration frequency"),
                            hint: "Enter the calibration frequency",
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
                          readOnly: true,
                          onTap: () {
                            _pickDate(
                              context: context,
                              current: selectedLastCalibrationDate,
                              onPicked: (d) => setState(
                                  () => selectedLastCalibrationDate = d),
                            );
                          },
                          decoration: _inputDecoration(
                            label: _requiredLabel("Last calibration date"),
                            hint: "Select the last calibration date",
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(
                            text: _formatDate(selectedLastCalibrationDate),
                          ),
                          validator: (_) => (selectedLastCalibrationDate == null)
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
                          readOnly: true,
                          onTap: () {
                            _pickDate(
                              context: context,
                              current: selectedNextCalibrationDate,
                              onPicked: (d) => setState(
                                  () => selectedNextCalibrationDate = d),
                            );
                          },
                          decoration: _inputDecoration(
                            label: _requiredLabel("Next calibration date"),
                            hint: "Select the next calibration date",
                            suffixIcon: const Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          controller: TextEditingController(
                            text: _formatDate(selectedNextCalibrationDate),
                          ),
                          validator: (_) => (selectedNextCalibrationDate == null)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _warrantyPeriodCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Warranty period (Years)"),
                            hint: "Enter the warranty period",
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
                          value: selectedCalibrationStatus,
                          isExpanded: true,
                          items: calibrationStatusList
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (value) {
                            setState(() => selectedCalibrationStatus = value);
                          },
                          hint: const Text(
                            "Select the calibration status",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Calibration status"),
                            hint: "Select the calibration status",
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
                          controller: _operatingInstructionsManualCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Operating instructions manual"),
                            hint: "Enter the operating instructions manual",
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
                  onPressed: _isSubmitting ? null : _submitMmd,
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

