import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';

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

  // Dropdown values
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
        "UpdatedDate": null,
        "Status": selectedToolStatus == "Active" ? 1 : 0,
      };

      print('DEBUG: Tool data prepared: $toolData');

      // Call API to add tool
      print('DEBUG: Calling API to add tool');
      await ApiService().addTool(toolData);
      print('DEBUG: Tool API call successful');

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Close the add tool dialog
      if (mounted) Navigator.of(context).pop();

      // Call the submit callback to refresh the list
      widget.submit();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tool added successfully!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      print('DEBUG: Tool creation completed successfully');
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
            content: Text("Failed to add tool: ${e.toString()}"),
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
    print('DEBUG: Fetching complete Tool details for ID: $toolId');
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetails(toolId, 'Tool');
      
      if (completeData != null) {
        print('DEBUG: Complete Tool data received: $completeData');
        
        // Populate all Tool-specific fields
        setState(() {
          // Basic fields
          _toolIdCtrl.text = completeData['ToolsId']?.toString() ?? _toolIdCtrl.text;
          _toolNameCtrl.text = completeData['ToolName']?.toString() ?? _toolNameCtrl.text;
          _supplierNameCtrl.text = completeData['Vendor']?.toString() ?? _supplierNameCtrl.text;
          _storageLocationCtrl.text = completeData['StorageLocation']?.toString() ?? _storageLocationCtrl.text;
          
          // Tool-specific fields
          selectedToolType = completeData['ToolType']?.toString();
          _associatedProductNameCtrl.text = completeData['AssociatedProduct']?.toString() ?? '';
          _articleCodeCtrl.text = completeData['ArticleCode']?.toString() ?? '';
          _toolSpecificationsCtrl.text = completeData['Specifications']?.toString() ?? '';
          
          // Purchase information
          _poNumberCtrl.text = completeData['PoNumber']?.toString() ?? '';
          _invoiceNumberCtrl.text = completeData['InvoiceNumber']?.toString() ?? '';
          _toolCostCtrl.text = completeData['ToolCost']?.toString() ?? '';
          _extraChargesCtrl.text = completeData['ExtraCharges']?.toString() ?? '';
          
          // Dates
          if (completeData['PoDate'] != null) {
            selectedPoDate = DateTime.tryParse(completeData['PoDate'].toString());
          }
          if (completeData['InvoiceDate'] != null) {
            selectedInvoiceDate = DateTime.tryParse(completeData['InvoiceDate'].toString());
          }
          if (completeData['LastAuditDate'] != null) {
            selectedLastAuditDate = DateTime.tryParse(completeData['LastAuditDate'].toString());
          }
          
          // Maintenance & Audit info
          _toolLifespanCtrl.text = completeData['Lifespan']?.toString() ?? '';
          _auditIntervalCtrl.text = completeData['AuditInterval']?.toString() ?? '';
          selectedMaintenanceFrequency = completeData['MaintainanceFrequency']?.toString();
          toolHandlingCertificateAvailable = completeData['HandlingCertificate'] == true;
          _lastAuditNotesCtrl.text = completeData['LastAuditNotes']?.toString() ?? '';
          _maximumToolOutputCtrl.text = completeData['MaxOutput']?.toString() ?? '';
          selectedToolStatus = completeData['Status'] == 1 ? 'Active' : 'Inactive';
          _responsiblePersonCtrl.text = completeData['ResponsibleTeam']?.toString() ?? '';
          _stockMsiAssetCtrl.text = completeData['MsiAsset']?.toString() ?? '';
          _kermAssetCtrl.text = completeData['KernAsset']?.toString() ?? '';
          _additionalNotesCtrl.text = completeData['Notes']?.toString() ?? '';
        });
        
        // Recalculate total cost
        _calculateTotalCost();
        
        print('DEBUG: Successfully populated all Tool fields');
      } else {
        print('DEBUG: No complete Tool data found, using basic data only');
      }
    } catch (e) {
      print('DEBUG: Error fetching complete Tool details: $e');
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
                            label: _requiredLabel("KERM asset"),
                            hint: "Enter the KERM asset",
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
                  onPressed: _isSubmitting ? null : _submitTool,
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