import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';

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
  // -------------------------
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

  // -------------------------
  // Purchase information
  // -------------------------
  final _poNumberCtrl = TextEditingController();
  DateTime? selectedPoDate;

  final _invoiceNumberCtrl = TextEditingController();
  DateTime? selectedInvoiceDate;

  final _costCtrl = TextEditingController();
  final _extraChargesCtrl = TextEditingController();
  final _totalCostCtrl = TextEditingController(text: "0.00");

  // -------------------------
  // Calibration information
  // -------------------------
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
    }
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
    print('DEBUG: Fetching complete MMD details for ID: $mmdId');
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetails(mmdId, 'MMD');
      
      if (completeData != null) {
        print('DEBUG: Complete MMD data received: $completeData');
        
        // Populate all MMD-specific fields
        setState(() {
          // Basic fields (already set, but update if different)
          _assetIdCtrl.text = completeData['MmdId']?.toString() ?? _assetIdCtrl.text;
          _assetNameCtrl.text = completeData['ModelNumber']?.toString() ?? _assetNameCtrl.text;
          _supplierNameCtrl.text = completeData['Vendor']?.toString() ?? _supplierNameCtrl.text;
          _locationCtrl.text = completeData['Location']?.toString() ?? _locationCtrl.text;
          
          // MMD-specific fields
          _brandNameCtrl.text = completeData['BrandName']?.toString() ?? '';
          _accuracyClassCtrl.text = completeData['AccuracyClass']?.toString() ?? '';
          _calibratedByCtrl.text = completeData['CalibratedBy']?.toString() ?? '';
          _toolSpecificationsCtrl.text = completeData['Specifications']?.toString() ?? '';
          _modelNumberCtrl.text = completeData['ModelNumber']?.toString() ?? '';
          _serialNumberCtrl.text = completeData['SerialNumber']?.toString() ?? '';
          _quantityAvailableCtrl.text = completeData['Quantity']?.toString() ?? '';
          _calibrationCertificateNumberCtrl.text = completeData['CalibrationCertNo']?.toString() ?? '';
          
          // Purchase information
          _poNumberCtrl.text = completeData['PoNumber']?.toString() ?? '';
          _invoiceNumberCtrl.text = completeData['InvoiceNumber']?.toString() ?? '';
          _costCtrl.text = completeData['TotalCost']?.toString() ?? '';
          _extraChargesCtrl.text = completeData['ExtraCharges']?.toString() ?? '';
          
          // Dates
          if (completeData['PoDate'] != null) {
            selectedPoDate = DateTime.tryParse(completeData['PoDate'].toString());
          }
          if (completeData['InvoiceDate'] != null) {
            selectedInvoiceDate = DateTime.tryParse(completeData['InvoiceDate'].toString());
          }
          if (completeData['LastCalibration'] != null) {
            selectedLastCalibrationDate = DateTime.tryParse(completeData['LastCalibration'].toString());
          }
          if (completeData['NextCalibration'] != null) {
            selectedNextCalibrationDate = DateTime.tryParse(completeData['NextCalibration'].toString());
          }
          
          // Dropdowns
          selectedCalibrationFrequency = completeData['CalibrationFrequency']?.toString();
          selectedCalibrationStatus = completeData['CalibrationStatus']?.toString();
          
          // Other fields
          _warrantyPeriodCtrl.text = completeData['WarrantyYears']?.toString() ?? '';
          _operatingInstructionsManualCtrl.text = completeData['ManualLink']?.toString() ?? '';
          _responsiblePersonCtrl.text = completeData['ResponsibleTeam']?.toString() ?? '';
          _stockMsiAssetCtrl.text = completeData['StockMsi']?.toString() ?? '';
          _additionalNotesCtrl.text = completeData['Remarks']?.toString() ?? '';
        });
        
        // Recalculate total cost
        _calculateTotalCost();
        
        print('DEBUG: Successfully populated all MMD fields');
      } else {
        print('DEBUG: No complete MMD data found, using basic data only');
      }
    } catch (e) {
      print('DEBUG: Error fetching complete MMD details: $e');
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
        borderSide: const BorderSide(color: Color(0xff00599A), width: 1.2),
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
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return "$d/$m/$y";
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
        "CalibrationStatus": selectedCalibrationStatus ?? "",
        "ResponsibleTeam": _responsiblePersonCtrl.text.trim(),
        "ManualLink": _operatingInstructionsManualCtrl.text.trim(),
        "StockMsi": _stockMsiAssetCtrl.text.trim(),
        "Remarks": _additionalNotesCtrl.text.trim(),
        "CreatedBy": "User",
        "UpdatedBy": "User",
        "CreatedDate": DateTime.now().toIso8601String(),
        "Status": selectedCalibrationStatus == "Calibrated",
      };

      print('DEBUG: MMD data prepared: $mmdData');

      // Call API to add MMD
      print('DEBUG: Calling API to add MMD');
      await ApiService().addMmd(mmdData);
      print('DEBUG: MMD API call successful');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Close form dialog
      if (mounted) Navigator.of(context).pop();

      // Call the submit callback
      widget.submit();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("MMD added successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      print('DEBUG: MMD creation completed successfully');
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
            content: Text("Failed to add MMD: $e"),
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
                                  onPicked: (d) =>
                                      setState(() => selectedPoDate = d),
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
                                  onPicked: (d) =>
                                      setState(() => selectedInvoiceDate = d),
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
                          decoration: _inputDecoration(
                            label: _requiredLabel("Last calibration date"),
                            hint: "Select the last calibration date",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              onPressed: () {
                                _pickDate(
                                  context: context,
                                  current: selectedLastCalibrationDate,
                                  onPicked: (d) => setState(
                                      () => selectedLastCalibrationDate = d),
                                );
                              },
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
                          decoration: _inputDecoration(
                            label: _requiredLabel("Next calibration date"),
                            hint: "Select the next calibration date",
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              onPressed: () {
                                _pickDate(
                                  context: context,
                                  current: selectedNextCalibrationDate,
                                  onPicked: (d) => setState(
                                      () => selectedNextCalibrationDate = d),
                                );
                              },
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
              SizedBox(
                width: 100,
                height: 36,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xff00599A), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xff00599A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 120,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMmd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSubmitting 
                        ? Colors.grey 
                        : const Color(0xff00599A),
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
                      : const Text(
                          "Submit",
                          style: TextStyle(
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

