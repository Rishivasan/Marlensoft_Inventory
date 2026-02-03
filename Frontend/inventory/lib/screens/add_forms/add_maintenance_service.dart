import 'package:flutter/material.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/maintenance_model.dart';

class AddMaintenanceService extends StatefulWidget {
  final String assetId;
  final String? itemName;
  final String? assetType;
  final Function(String? nextServiceDue) onServiceAdded;
  final MaintenanceModel? existingMaintenance;

  const AddMaintenanceService({
    super.key,
    required this.assetId,
    this.itemName,
    this.assetType,
    required this.onServiceAdded,
    this.existingMaintenance,
  });

  @override
  State<AddMaintenanceService> createState() => _AddMaintenanceServiceState();
}

class _AddMaintenanceServiceState extends State<AddMaintenanceService> {
  final _formKey = GlobalKey<FormState>();
  final _serviceDateController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _serviceEngineerController = TextEditingController();
  final _responsibleTeamController = TextEditingController();
  final _nextServiceDateController = TextEditingController();
  final _serviceNotesController = TextEditingController();
  final _toolCostController = TextEditingController();
  final _extraChargesController = TextEditingController();
  final _totalCostController = TextEditingController(text: '0.00');

  String? _selectedServiceType;
  bool _isSubmitting = false;

  final List<String> _serviceTypes = [
    'Preventive',
    'Breakdown',
    'Predictive',
    'Corrective',
    'Adaptive',
    'Emergency',
    'Calibration',
  ];

  @override
  void initState() {
    super.initState();
    _toolCostController.addListener(_calculateTotal);
    _extraChargesController.addListener(_calculateTotal);
    
    // Pre-populate fields if editing existing maintenance record
    if (widget.existingMaintenance != null) {
      final maintenance = widget.existingMaintenance!;
      if (maintenance.serviceDate != null) {
        _serviceDateController.text = _formatDateForInput(maintenance.serviceDate!);
      }
      _serviceProviderController.text = maintenance.serviceProviderCompany;
      _serviceEngineerController.text = maintenance.serviceEngineerName;
      _selectedServiceType = maintenance.serviceType;
      _responsibleTeamController.text = maintenance.responsibleTeam;
      if (maintenance.nextServiceDue != null) {
        _nextServiceDateController.text = _formatDateForInput(maintenance.nextServiceDue!);
      }
      _serviceNotesController.text = maintenance.serviceNotes ?? '';
      _toolCostController.text = maintenance.cost.toStringAsFixed(2);
      _extraChargesController.text = '0.00';
    }
  }
  
  String _formatDateForInput(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  void dispose() {
    _serviceDateController.dispose();
    _serviceProviderController.dispose();
    _serviceEngineerController.dispose();
    _responsibleTeamController.dispose();
    _nextServiceDateController.dispose();
    _serviceNotesController.dispose();
    _toolCostController.dispose();
    _extraChargesController.dispose();
    _totalCostController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    final toolCost = double.tryParse(_toolCostController.text) ?? 0.0;
    final extraCharges = double.tryParse(_extraChargesController.text) ?? 0.0;
    final total = toolCost + extraCharges;
    _totalCostController.text = total.toStringAsFixed(2);
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    if (picked != null) {
      controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceType == null || _selectedServiceType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();
      
      // Parse dates
      DateTime? serviceDate;
      DateTime? nextServiceDate;
      
      if (_serviceDateController.text.isNotEmpty) {
        final parts = _serviceDateController.text.split('/');
        if (parts.length == 3) {
          serviceDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
      
      if (_nextServiceDateController.text.isNotEmpty) {
        final parts = _nextServiceDateController.text.split('/');
        if (parts.length == 3) {
          nextServiceDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        }
      }
      
      // Create maintenance data
      final maintenanceData = <String, dynamic>{
        'assetId': widget.assetId,
        'assetType': widget.assetType ?? 'Unknown',
        'itemName': widget.itemName ?? 'Unknown',
        'serviceDate': serviceDate?.toIso8601String(),
        'serviceProviderCompany': _serviceProviderController.text,
        'serviceEngineerName': _serviceEngineerController.text,
        'serviceType': _selectedServiceType!,
        'nextServiceDue': nextServiceDate?.toIso8601String(),
        'serviceNotes': _serviceNotesController.text,
        'maintenanceStatus': 'Completed',
        'cost': double.tryParse(_totalCostController.text) ?? 0.0,
        'responsibleTeam': _responsibleTeamController.text,
      };

      if (widget.existingMaintenance != null) {
        maintenanceData['maintenanceId'] = widget.existingMaintenance!.maintenanceId;
        maintenanceData['createdDate'] = widget.existingMaintenance!.createdDate.toIso8601String();
      }

      final response = widget.existingMaintenance != null
          ? await apiService.updateMaintenanceRecord(widget.existingMaintenance!.maintenanceId, maintenanceData)
          : await apiService.addMaintenanceRecord(maintenanceData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingMaintenance != null 
                ? 'Maintenance service updated successfully!'
                : 'Maintenance service added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
        widget.onServiceAdded(_nextServiceDateController.text.isNotEmpty ? _nextServiceDateController.text : null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingMaintenance != null 
                ? 'Error updating maintenance service: $e'
                : 'Error adding maintenance service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Required label style matching the reference
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

  // Section title style
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

  // Common InputDecoration matching the reference
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
          // HEADER - matching the reference exactly
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.existingMaintenance != null ? "Edit maintenance service" : "Add new maintenance service",
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
              widget.existingMaintenance != null 
                ? "Please update the details below and click submit to save changes"
                : "Please enter the details below and click submit to add a new maintenance service",
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
                  // Service information section
                  _sectionTitle("Service information"),

                  // Row 1: Service Date & Service Provider Company
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _serviceDateController,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Service date"),
                            hint: "Select the service date",
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          onTap: () => _selectDate(_serviceDateController),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: TextFormField(
                          controller: _serviceProviderController,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Service provider company"),
                            hint: "Enter the service provider company",
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

                  // Row 2: Service Engineer Name & Service Type
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _serviceEngineerController,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Service engineer name"),
                            hint: "Enter the service engineer name",
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
                          value: _selectedServiceType,
                          isExpanded: true,
                          items: _serviceTypes
                              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedServiceType = value;
                            });
                          },
                          hint: const Text(
                            "Select the service type",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          decoration: _inputDecoration(
                            label: _requiredLabel("Service type"),
                            hint: "Select the service type",
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

                  // Row 3: Responsible Team & Next Service Due Date
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _responsibleTeamController,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Responsible team"),
                            hint: "Enter the responsible team",
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
                          controller: _nextServiceDateController,
                          readOnly: true,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Next service due date"),
                            hint: "Select the next service due date",
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Color.fromRGBO(144, 144, 144, 1),
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          onTap: () => _selectDate(_nextServiceDateController),
                          validator: (v) => (v == null || v.isEmpty)
                              ? "The field cannot be empty"
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Service Notes (Full Width)
                  TextFormField(
                    controller: _serviceNotesController,
                    maxLines: 3,
                    decoration: _inputDecoration(
                      label: const Text(
                        "Service notes",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(88, 88, 88, 1),
                        ),
                      ),
                      hint: "Enter the service notes",
                    ),
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // Cost information section
                  _sectionTitle("Cost information"),

                  // Row 4: Service Cost & Extra Charges
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _toolCostController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            label: _requiredLabel("Service cost"),
                            hint: "Enter the service cost",
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
                          controller: _extraChargesController,
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

                  // Total Cost (Half Width)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: TextFormField(
                      controller: _totalCostController,
                      enabled: false,
                      decoration: _inputDecoration(
                        label: const Text(
                          "Total service cost",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(88, 88, 88, 1),
                          ),
                        ),
                        hint: "0.00",
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
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
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
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
                  onPressed: _isSubmitting ? null : _submitForm,
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
                          widget.existingMaintenance != null ? 'Update' : 'Submit',
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