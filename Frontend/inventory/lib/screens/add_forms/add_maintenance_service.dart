import 'package:flutter/material.dart';
import 'package:inventory/services/api_service.dart';
import 'package:inventory/model/maintenance_model.dart';
import 'package:inventory/providers/next_service_provider.dart';
import 'package:inventory/services/next_service_calculation_service.dart';
import 'package:provider/provider.dart';

class AddMaintenanceService extends StatefulWidget {
  final String assetId;
  final String? itemName;
  final String? assetType;
  final String? currentNextServiceDue; // Add this parameter to pass the current Next Service Due
  final Function(String? nextServiceDue) onServiceAdded;
  final MaintenanceModel? existingMaintenance;

  const AddMaintenanceService({
    super.key,
    required this.assetId,
    this.itemName,
    this.assetType,
    this.currentNextServiceDue, // Add this parameter
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
  String? _maintenanceFrequency;
  DateTime? _currentNextServiceDue;

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
    
    // Fetch current next service due and maintenance frequency
    _loadItemData();
    
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
  
  // Load item data to get current next service due and maintenance frequency
  Future<void> _loadItemData() async {
    try {
      final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
      final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
      
      // PRIORITY 1: Use the Next Service Due passed from parent (dialog panel)
      // This ensures we use the SAME value displayed in the dialog
      DateTime? nextServiceDue;
      
      if (widget.currentNextServiceDue != null && widget.currentNextServiceDue!.isNotEmpty) {
        // Parse the date string from parent (format: YYYY-MM-DD)
        try {
          final parts = widget.currentNextServiceDue!.split('-');
          if (parts.length == 3) {
            nextServiceDue = DateTime(
              int.parse(parts[0]), 
              int.parse(parts[1]), 
              int.parse(parts[2])
            );
            print('DEBUG: Using Next Service Due from parent dialog: $nextServiceDue');
          }
        } catch (e) {
          print('DEBUG: Error parsing Next Service Due from parent: $e');
        }
      }
      
      // PRIORITY 2: Fallback to provider if not passed from parent
      if (nextServiceDue == null) {
        nextServiceDue = nextServiceProvider.getNextServiceDate(widget.assetId);
        print('DEBUG: Using Next Service Due from provider: $nextServiceDue');
      }
      
      // Get maintenance frequency
      final frequency = await nextServiceCalculationService.getMaintenanceFrequency(
        widget.assetId,
        widget.assetType ?? 'Unknown'
      );
      
      if (mounted) {
        setState(() {
          _currentNextServiceDue = nextServiceDue;
          _maintenanceFrequency = frequency;
          
          // IMPORTANT: Auto-populate Service Date with CURRENT Next Service Due
          // This is the date when the service is scheduled to happen
          if (nextServiceDue != null && widget.existingMaintenance == null) {
            _serviceDateController.text = _formatDateForInput(nextServiceDue);
            // Auto-calculate the NEXT Next Service Due Date (after this service)
            _calculateNextServiceDue(nextServiceDue);
          }
        });
        
        print('DEBUG: Loaded item data - Current NextServiceDue: $nextServiceDue, Frequency: $frequency');
        print('DEBUG: Service Date auto-populated with Next Service Due: $nextServiceDue');
      }
    } catch (e) {
      print('DEBUG: Error loading item data: $e');
    }
  }
  
  // Calculate next service due based on service date and maintenance frequency
  // This calculates when the service AFTER this one should happen
  void _calculateNextServiceDue(DateTime serviceDate) {
    if (_maintenanceFrequency == null || _maintenanceFrequency!.isEmpty) {
      print('DEBUG: No maintenance frequency available for calculation');
      return;
    }
    
    final frequency = _maintenanceFrequency!.toLowerCase().trim();
    DateTime? nextServiceDue;
    
    switch (frequency) {
      case 'daily':
        nextServiceDue = serviceDate.add(const Duration(days: 1));
        break;
      case 'weekly':
        nextServiceDue = serviceDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 1, serviceDate.day);
        break;
      case 'quarterly':
        nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 3, serviceDate.day);
        break;
      case 'half-yearly':
      case 'halfyearly':
        nextServiceDue = DateTime(serviceDate.year, serviceDate.month + 6, serviceDate.day);
        break;
      case 'yearly':
      case 'annual':
        nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
        break;
      case '2nd year':
        nextServiceDue = DateTime(serviceDate.year + 2, serviceDate.month, serviceDate.day);
        break;
      case '3rd year':
        nextServiceDue = DateTime(serviceDate.year + 3, serviceDate.month, serviceDate.day);
        break;
      default:
        // Default to yearly
        nextServiceDue = DateTime(serviceDate.year + 1, serviceDate.month, serviceDate.day);
    }
    
    if (nextServiceDue != null) {
      setState(() {
        _nextServiceDateController.text = _formatDateForInput(nextServiceDue!);
      });
      print('DEBUG: Calculated Next Service Due: ServiceDate=$serviceDate, Frequency=$frequency, NextDue=$nextServiceDue');
    }
  }
  
  String _formatDateForInput(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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

  Future<void> _selectDate(TextEditingController controller, {bool isServiceDate = false}) async {
    // For Next Service Due Date, validate that Service Date is selected first
    if (!isServiceDate && _serviceDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select the service date first'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
    // Parse the current date from the controller, fallback to DateTime.now()
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(controller.text);
        // Ensure the parsed date is within the valid range
        final minDate = DateTime(2000);
        final maxDate = DateTime(2100);
        if (parsedDate.isAfter(minDate) && parsedDate.isBefore(maxDate)) {
          initialDate = parsedDate;
        }
      } catch (e) {
        // If parsing fails, use current date
        initialDate = DateTime.now();
      }
    }
    
    // Determine the minimum selectable date based on the field type
    DateTime firstDate = DateTime(2000);
    
    // For Next Service Due Date, it cannot be before the Service Date
    if (!isServiceDate) {
      // This is the Next Service Due Date field
      if (_serviceDateController.text.isNotEmpty) {
        try {
          final serviceDate = DateTime.parse(_serviceDateController.text);
          // Next service due must be on or after the service date
          firstDate = serviceDate;
          
          // If the current initial date is before the service date, set it to service date
          if (initialDate.isBefore(serviceDate)) {
            initialDate = serviceDate;
          }
        } catch (e) {
          // If service date parsing fails, use default range
          firstDate = DateTime(2000);
        }
      }
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
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
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      
      // If this is the service date field, validate and handle next service due date
      if (isServiceDate) {
        // Check if next service due date is already set and is before the new service date
        if (_nextServiceDateController.text.isNotEmpty) {
          try {
            final nextServiceDate = DateTime.parse(_nextServiceDateController.text);
            if (nextServiceDate.isBefore(picked)) {
              // Clear the next service due date as it's now invalid
              _nextServiceDateController.clear();
              
              // Show a message to inform the user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Next service due date cleared as it was before the new service date'),
                  backgroundColor: Colors.blue,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            // If parsing fails, just continue
          }
        }
        
        // Auto-calculate next service due
        _calculateNextServiceDue(picked);
      }
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
      
      // Parse dates (YYYY-MM-DD format)
      DateTime? serviceDate;
      DateTime? nextServiceDate;
      
      if (_serviceDateController.text.isNotEmpty) {
        final parts = _serviceDateController.text.split('-');
        if (parts.length == 3) {
          serviceDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }
      
      if (_nextServiceDateController.text.isNotEmpty) {
        final parts = _nextServiceDateController.text.split('-');
        if (parts.length == 3) {
          nextServiceDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
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
      
      // After successful maintenance record creation/update, update next service date via provider
      if (nextServiceDate != null && widget.assetType != null) {
        try {
          final nextServiceProvider = Provider.of<NextServiceProvider>(context, listen: false);
          
          // Update the next service date in provider (this will trigger UI updates everywhere)
          nextServiceProvider.updateNextServiceDate(widget.assetId, nextServiceDate);
          
          // Also update via API to persist in database
          final nextServiceCalculationService = NextServiceCalculationService(nextServiceProvider);
          await nextServiceCalculationService.calculateNextServiceDateAfterMaintenance(
            assetId: widget.assetId,
            assetType: widget.assetType!,
            serviceDate: serviceDate!,
            maintenanceFrequency: _maintenanceFrequency ?? 'Yearly',
          );
          
          print('DEBUG: Next service date updated after maintenance: $nextServiceDate');
        } catch (e) {
          print('DEBUG: Error updating next service date after maintenance: $e');
        }
      }
      
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
                        child: GestureDetector(
                          onTap: () => _selectDate(_serviceDateController, isServiceDate: true),
                          child: AbsorbPointer(
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
                              validator: (v) => (v == null || v.isEmpty)
                                  ? "The field cannot be empty"
                                  : null,
                            ),
                          ),
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
                        child: GestureDetector(
                          onTap: () => _selectDate(_nextServiceDateController),
                          child: AbsorbPointer(
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
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return "The field cannot be empty";
                                }
                                
                                // Validate that next service due is not before service date
                                if (_serviceDateController.text.isNotEmpty) {
                                  try {
                                    final serviceDate = DateTime.parse(_serviceDateController.text);
                                    final nextServiceDate = DateTime.parse(v);
                                    
                                    if (nextServiceDate.isBefore(serviceDate)) {
                                      return "Next service due cannot be before service date";
                                    }
                                  } catch (e) {
                                    return "Invalid date format";
                                  }
                                }
                                
                                return null;
                              },
                            ),
                          ),
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