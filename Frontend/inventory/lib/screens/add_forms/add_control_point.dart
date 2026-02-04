import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/quality_service.dart';

class AddControlPoint extends StatefulWidget {
  const AddControlPoint({
    super.key, 
    required this.submit,
    this.existingData,
  });

  final VoidCallback submit;
  final Map<String, dynamic>? existingData;

  @override
  State<AddControlPoint> createState() => _AddControlPointState();
}

class _AddControlPointState extends State<AddControlPoint> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form controllers
  final _controlPointNameCtrl = TextEditingController();
  final _targetValueCtrl = TextEditingController();
  final _toleranceValueCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _commentsCtrl = TextEditingController();
  
  String? selectedType;
  String? selectedUnit;
  
  // File upload
  PlatformFile? selectedFile;
  
  // Dynamic lists that will be populated from the backend
  List<Map<String, String>> controlPointTypes = [];
  List<String> units = [];
  
  // Dropdown values - keeping fallback values
  final List<String> fallbackTypeList = [
    "Measure",
    "Visual Check",
    "Performance Test",
    "Material Analysis",
  ];

  final List<String> fallbackUnitList = [
    "mm",
    "cm", 
    "m",
    "kg",
    "g",
    "°C",
    "%",
    "pcs",
  ];

  @override
  void initState() {
    super.initState();
    
    // Load dropdown data from backend
    _loadDropdownData();
    
    // Pre-populate form if existing data is provided
    if (widget.existingData != null) {
      _populateFormWithExistingData();
    }
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load control point types and units
      final controlPointTypesData = await QualityService.getControlPointTypes();
      final unitsData = await QualityService.getUnits();

      setState(() {
        // Process control point types
        controlPointTypes = controlPointTypesData.map((item) => <String, String>{
          'id': item['controlPointTypeId']?.toString() ?? '',
          'name': item['typeName']?.toString() ?? '',
          'description': item['description']?.toString() ?? '',
        }).toList();

        // Process units - ensure they are properly converted to strings
        if (unitsData is List) {
          units = unitsData.map((unit) {
            if (unit is String) {
              return unit;
            } else {
              return unit.toString();
            }
          }).toList();
        } else {
          units = [];
        }
        
        // Set default type to first available or "Measure"
        if (controlPointTypes.isNotEmpty && selectedType == null) {
          // Try to find "Measure" type, otherwise use first
          final measureType = controlPointTypes.firstWhere(
            (type) => type['name'].toString().toLowerCase().contains('measure'),
            orElse: () => controlPointTypes.first,
          );
          selectedType = measureType['id'].toString();
        }
      });
      
    } catch (e) {
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load data from server. Using fallback data.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Set fallback data if API fails
      setState(() {
        controlPointTypes = fallbackTypeList.asMap().entries.map((entry) => <String, String>{
          'id': (entry.key + 1).toString(),
          'name': entry.value,
          'description': '',
        }).toList();
        units = List<String>.from(fallbackUnitList);
        
        // Set default type to "Measure" (first item)
        if (selectedType == null) {
          selectedType = '1'; // Measure
        }
      });
    }
  }
  
  void _populateFormWithExistingData() {
    final data = widget.existingData!;
    
    _controlPointNameCtrl.text = data['name'] ?? '';
    selectedType = data['typeId']?.toString() ?? data['type'];
    
    // Populate type-specific fields
    _targetValueCtrl.text = data['targetValue']?.toString() ?? '';
    selectedUnit = data['unit'];
    _toleranceValueCtrl.text = data['toleranceValue']?.toString() ?? '';
    _instructionsCtrl.text = data['instructions']?.toString() ?? '';
    _commentsCtrl.text = data['comments']?.toString() ?? '';
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          selectedFile = result.files.first;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitControlPoint() async {
    // Prevent multiple submissions
    if (_isSubmitting) {
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
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

      // Collect form data based on selected type
      final selectedTypeData = controlPointTypes.firstWhere(
        (type) => type['id'].toString() == selectedType,
        orElse: () => {'name': ''},
      );
      final typeName = selectedTypeData['name'].toString();

      Map<String, dynamic> controlPointData = {
        "name": _controlPointNameCtrl.text.trim(),
        "controlPointTypeId": int.tryParse(selectedType ?? '1') ?? 1,
        "fileName": selectedFile?.name,
        "filePath": selectedFile?.path,
        "createdDate": DateTime.now().toIso8601String(),
        "updatedDate": DateTime.now().toIso8601String(),
      };

      // Add type-specific fields
      switch (typeName.toLowerCase()) {
        case 'measure':
          controlPointData.addAll({
            "targetValue": _targetValueCtrl.text.trim(),
            "unit": selectedUnit ?? "",
            "toleranceValue": _toleranceValueCtrl.text.trim(),
          });
          break;
        case 'visual inspection':
          controlPointData.addAll({
            "instructions": _instructionsCtrl.text.trim(),
          });
          break;
        case 'take a picture':
          controlPointData.addAll({
            "comments": _commentsCtrl.text.trim(),
          });
          break;
      }

      // TODO: Replace with actual API call when backend is ready
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));
      bool success = true;

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        String successMessage = widget.existingData != null 
            ? 'Control point updated successfully!' 
            : 'Control point added successfully!';
            
        // Close the add/edit control point dialog
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
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (popError) {
          // Dialog already closed
        }
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to ${widget.existingData != null ? 'update' : 'add'} control point: ${e.toString()}"),
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
      }
    }
  }

  @override
  void dispose() {
    _controlPointNameCtrl.dispose();
    _targetValueCtrl.dispose();
    _toleranceValueCtrl.dispose();
    _instructionsCtrl.dispose();
    _commentsCtrl.dispose();
    super.dispose();
  }

  // Required label style
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

  // Get type-specific description
  String _getTypeDescription(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'measure':
        return "Taking measures requires to enter the product's measurements during a transfer or during the manufacturing process. To use it, it necessary to specify the norm for your product's measurements, but also a tolerance threshold. Doing so, all the products with good measures are automatically accepted.";
      case 'visual inspection':
        return "This control point type allows giving instructions to workers during the transfer or during the manufacturing process.";
      case 'take a picture':
        return "This control point type asks to take a picture of the product applied in a transfer or when manufacturing it.";
      default:
        return "Control point for quality assurance during the manufacturing process.";
    }
  }

  // Build type-specific form fields
  Widget _buildTypeSpecificFields(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'measure':
        return _buildMeasureFields();
      case 'visual inspection':
        return _buildVisualInspectionFields();
      case 'take a picture':
        return _buildTakePictureFields();
      default:
        return const SizedBox.shrink();
    }
  }

  // Build fields for Measure type
  Widget _buildMeasureFields() {
    return Column(
      children: [
        // Row: Target value and Unit
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _targetValueCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  label: _requiredLabel("Target value"),
                  hint: "e.g., 10.5, 100",
                ),
                style: const TextStyle(fontSize: 12),
                validator: (v) => (v == null || v.isEmpty)
                    ? "The field cannot be empty"
                    : null,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (units.isEmpty) {
                    return TextFormField(
                      decoration: _inputDecoration(
                        label: _requiredLabel("Unit"),
                        hint: "Loading units...",
                      ),
                      enabled: false,
                    );
                  }

                  return DropdownButtonFormField<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: _requiredLabel("Unit"),
                      hint: "Select the unit",
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color.fromRGBO(144, 144, 144, 1),
                      ),
                    ),
                    hint: const Text(
                      "Select the unit",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromRGBO(144, 144, 144, 1),
                      ),
                    ),
                    items: units
                        .map((u) => DropdownMenuItem<String>(
                            value: u, 
                            child: Text(
                              u,
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                            )))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value;
                      });
                    },
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                    validator: (v) => (v == null || v.isEmpty)
                        ? "The field cannot be empty"
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row: Tolerance value
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _toleranceValueCtrl,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  label: _requiredLabel("Tolerance value"),
                  hint: "Enter the tolerance value",
                  suffixIcon: const Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: Color.fromRGBO(144, 144, 144, 1),
                  ),
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
        const SizedBox(height: 24),

        // File upload area
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(210, 210, 210, 1),
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selectedFile != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedFile!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                          });
                        },
                        child: const Text(
                          'Remove file',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Click to upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2196F3),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' or drag and drop',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(144, 144, 144, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Build fields for Visual Inspection type
  Widget _buildVisualInspectionFields() {
    return Column(
      children: [
        // File upload area FIRST
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(210, 210, 210, 1),
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selectedFile != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedFile!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                          });
                        },
                        child: const Text(
                          'Remove file',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Click to upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2196F3),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' or drag and drop',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(144, 144, 144, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),

        // Instructions field SECOND
        TextFormField(
          controller: _instructionsCtrl,
          maxLines: 3,
          decoration: _inputDecoration(
            label: _requiredLabel("Instructions"),
            hint: "e.g., Check if the product color is correct.",
          ),
          style: const TextStyle(fontSize: 12),
          validator: (v) => (v == null || v.isEmpty)
              ? "The field cannot be empty"
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Build fields for Take a Picture type
  Widget _buildTakePictureFields() {
    return Column(
      children: [
        // File upload area FIRST
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color.fromRGBO(210, 210, 210, 1),
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: selectedFile != null
              ? Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.description,
                        size: 32,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedFile!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4CAF50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(selectedFile!.size / 1024).toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
                          });
                        },
                        child: const Text(
                          'Remove file',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 32,
                          color: Color.fromRGBO(144, 144, 144, 1),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Click to upload',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2196F3),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ' or drag and drop',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(144, 144, 144, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 24),

        // Comments field SECOND
        TextFormField(
          controller: _commentsCtrl,
          maxLines: 3,
          decoration: _inputDecoration(
            label: _requiredLabel("Comments"),
            hint: "Enter your comments here.",
          ),
          style: const TextStyle(fontSize: 12),
          validator: (v) => (v == null || v.isEmpty)
              ? "The field cannot be empty"
              : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Common InputDecoration for all fields
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
              widget.existingData != null ? "Edit control point" : "Add control point",
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
                : "Please enter the details below and click submit to add a new control point",
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
                  // Row 1: Control point name and Type
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controlPointNameCtrl,
                          decoration: _inputDecoration(
                            label: _requiredLabel("QC control point name"),
                            hint: "Enter the control point name",
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            // Ensure we have valid data before building dropdown
                            if (controlPointTypes.isEmpty) {
                              return TextFormField(
                                decoration: _inputDecoration(
                                  label: _requiredLabel("Type"),
                                  hint: "Loading types...",
                                ),
                                enabled: false,
                              );
                            }

                            return DropdownButtonFormField<String>(
                              value: selectedType,
                              isExpanded: true,
                              decoration: _inputDecoration(
                                label: _requiredLabel("Type"),
                                hint: "Select the type",
                                suffixIcon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color.fromRGBO(144, 144, 144, 1),
                                ),
                              ),
                              hint: const Text(
                                "Select the type",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromRGBO(144, 144, 144, 1),
                                ),
                              ),
                              items: controlPointTypes
                                  .map((t) => DropdownMenuItem<String>(
                                      value: t['id'].toString(), 
                                      child: Text(
                                        t['name'].toString(),
                                        style: const TextStyle(fontSize: 12, color: Colors.black),
                                      )))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedType = value;
                                });
                              },
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "The field cannot be empty"
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Show type-specific info box and fields based on selected type
                  if (selectedType != null && controlPointTypes.isNotEmpty)
                    Builder(
                      builder: (context) {
                        final selectedTypeData = controlPointTypes.firstWhere(
                          (type) => type['id'].toString() == selectedType,
                          orElse: () => {'name': '', 'description': ''},
                        );
                        final typeName = selectedTypeData['name'].toString();
                        
                        return Column(
                          children: [
                            // Type-specific info box
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF2196F3), width: 1),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2196F3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.info,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          typeName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1976D2),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getTypeDescription(typeName),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF1976D2),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Type-specific form fields
                            _buildTypeSpecificFields(typeName),
                          ],
                        );
                      },
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
                width: 150,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitControlPoint,
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
                          widget.existingData != null ? "Update" : "Add control point",
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