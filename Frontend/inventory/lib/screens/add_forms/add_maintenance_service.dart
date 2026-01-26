import 'package:flutter/material.dart';
import 'package:inventory/services/api_service.dart';

class AddMaintenanceService extends StatefulWidget {
  final String assetId;
  final String? itemName;
  final String? assetType;
  final VoidCallback onServiceAdded;

  const AddMaintenanceService({
    super.key,
    required this.assetId,
    this.itemName,
    this.assetType,
    required this.onServiceAdded,
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

  String _selectedServiceType = '';
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
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceType.isEmpty) {
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
      
      // Create maintenance data
      final maintenanceData = {
        'assetId': widget.assetId,
        'assetType': widget.assetType ?? 'Unknown',
        'itemName': widget.itemName ?? 'Unknown',
        'serviceDate': _serviceDateController.text,
        'serviceProviderCompany': _serviceProviderController.text,
        'serviceEngineerName': _serviceEngineerController.text,
        'serviceType': _selectedServiceType,
        'nextServiceDue': _nextServiceDateController.text.isNotEmpty ? _nextServiceDateController.text : null,
        'serviceNotes': _serviceNotesController.text,
        'maintenanceStatus': 'Completed',
        'cost': double.tryParse(_totalCostController.text) ?? 0.0,
        'responsibleTeam': _responsibleTeamController.text,
      };

      print('DEBUG: Submitting maintenance data: $maintenanceData');

      // Call API to add maintenance record
      final response = await apiService.addMaintenanceRecord(maintenanceData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance service added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close dialog and refresh data
        Navigator.of(context).pop();
        widget.onServiceAdded();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding maintenance service: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add new tool for maintenance and service',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Please enter the details below and click submit to add a new tool',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Form
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Service Date & Service Provider Company
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Service date *',
                          'Select the service date',
                          _serviceDateController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Service provider company *',
                          'Enter the service provider company',
                          _serviceProviderController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Row 2: Service Engineer Name & Service Type
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Service engineer name *',
                          'Enter the service engineer name',
                          _serviceEngineerController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          'Service type',
                          'Select the service type',
                          _selectedServiceType,
                          _serviceTypes,
                          (value) {
                            setState(() {
                              _selectedServiceType = value ?? '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Row 3: Responsible Team & Next Service Due Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Responsible team *',
                          'Enter the responsible team name',
                          _responsibleTeamController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          'Next service due date *',
                          'Select the next service due date',
                          _nextServiceDateController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Service Notes (Full Width)
                  _buildTextAreaField(
                    'Service notes',
                    'Enter the service notes',
                    _serviceNotesController,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Row 4: Tool Cost & Extra Charges
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Tool cost *',
                          'Enter the tool cost',
                          _toolCostController,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Extra charges',
                          'Enter the extra charges',
                          _extraChargesController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Total Tool Cost
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: _buildTextField(
                      'Total tool cost',
                      '0.00',
                      _totalCostController,
                      enabled: false,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        
        // Bottom Buttons
        Container(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7280),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
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
                        'Submit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller, {
    bool required = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            filled: !enabled,
            fillColor: enabled ? null : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label,
    String placeholder,
    TextEditingController controller, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            suffixIcon: const Icon(
              Icons.calendar_today,
              color: Color(0xFF6B7280),
              size: 18,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          onTap: () => _selectDate(controller),
          validator: required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String placeholder,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF111827),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextAreaField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}