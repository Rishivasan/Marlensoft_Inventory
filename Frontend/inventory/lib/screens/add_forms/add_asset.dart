import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/master_list_model.dart';

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
    print('DEBUG: Fetching complete Asset details for ID: $assetId');
    try {
      final apiService = ApiService();
      final completeData = await apiService.getCompleteItemDetails(assetId, 'Asset');
      
      if (completeData != null) {
        print('DEBUG: Complete Asset data received: $completeData');
        
        // Populate all Asset-specific fields
        setState(() {
          // Basic fields
          _assetIdCtrl.text = completeData['AssetId']?.toString() ?? _assetIdCtrl.text;
          _assetNameCtrl.text = completeData['AssetName']?.toString() ?? _assetNameCtrl.text;
          _supplierNameCtrl.text = completeData['Vendor']?.toString() ?? _supplierNameCtrl.text;
          _storageLocationCtrl.text = completeData['StorageLocation']?.toString() ?? _storageLocationCtrl.text;
          
          // Asset-specific fields
          selectedCategory = completeData['Category']?.toString();
          _productsCtrl.text = completeData['Product']?.toString() ?? '';
          _toolSpecificationsCtrl.text = completeData['Specifications']?.toString() ?? '';
          _quantityCtrl.text = completeData['Quantity']?.toString() ?? '';
          
          // Purchase information
          _poNumberCtrl.text = completeData['PoNumber']?.toString() ?? '';
          _invoiceNumberCtrl.text = completeData['InvoiceNumber']?.toString() ?? '';
          _assetCostCtrl.text = completeData['AssetCost']?.toString() ?? '';
          _extraChargesCtrl.text = completeData['ExtraCharges']?.toString() ?? '';
          
          // Dates
          if (completeData['PoDate'] != null) {
            selectedPoDate = DateTime.tryParse(completeData['PoDate'].toString());
          }
          if (completeData['InvoiceDate'] != null) {
            selectedInvoiceDate = DateTime.tryParse(completeData['InvoiceDate'].toString());
          }
          
          // Maintenance info
          _depreciationPeriodCtrl.text = completeData['DepreciationPeriod']?.toString() ?? '';
          selectedMaintenanceFrequency = completeData['MaintenanceFrequency']?.toString();
          selectedAssetStatus = completeData['Status'] == true ? 'Active' : 'Inactive';
          _responsiblePersonCtrl.text = completeData['ResponsibleTeam']?.toString() ?? '';
          _stockMsiAssetCtrl.text = completeData['MsiTeam']?.toString() ?? '';
          _additionalNotesCtrl.text = completeData['Remarks']?.toString() ?? '';
        });
        
        // Recalculate total cost
        _calculateTotalCost();
        
        print('DEBUG: Successfully populated all Asset fields');
      } else {
        print('DEBUG: No complete Asset data found, using basic data only');
      }
    } catch (e) {
      print('DEBUG: Error fetching complete Asset details: $e');
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
        "UpdatedDate": null,
        "Status": selectedAssetStatus == "Active",
      };

      print('DEBUG: Asset data prepared: $assetData');

      // Call API to add asset
      print('DEBUG: Calling API to add asset');
      await ApiService().addAssetConsumable(assetData);
      print('DEBUG: API call successful');

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
            content: Text("Asset added successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      print('DEBUG: Asset creation completed successfully');
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
            content: Text("Failed to add asset: $e"),
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
                                  onPicked: (d) => setState(() => selectedPoDate = d),
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
                  onPressed: _isSubmitting ? null : _submitAsset,
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

