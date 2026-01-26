import 'package:flutter/material.dart';
import 'package:inventory/services/api_service.dart';

class AddAllocation extends StatefulWidget {
  final String assetId;
  final String? itemName;
  final String? assetType;
  final VoidCallback onAllocationAdded;

  const AddAllocation({
    super.key,
    required this.assetId,
    this.itemName,
    this.assetType,
    required this.onAllocationAdded,
  });

  @override
  State<AddAllocation> createState() => _AddAllocationState();
}

class _AddAllocationState extends State<AddAllocation> {
  final _formKey = GlobalKey<FormState>();
  final _issueDateController = TextEditingController();
  final _employeeNameController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _expectedReturnDateController = TextEditingController();
  final _actualReturnDateController = TextEditingController();

  String _selectedStatus = '';
  bool _isSubmitting = false;

  final List<String> _statusOptions = [
    'Allocated',
    'Available',
    'Returned',
    'Overdue',
    'In Use',
    'Under Maintenance',
  ];

  @override
  void dispose() {
    _issueDateController.dispose();
    _employeeNameController.dispose();
    _teamNameController.dispose();
    _purposeController.dispose();
    _expectedReturnDateController.dispose();
    _actualReturnDateController.dispose();
    super.dispose();
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

    if (_selectedStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
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
      
      // Create allocation data
      final allocationData = {
        'assetId': widget.assetId,
        'assetType': widget.assetType ?? 'Unknown',
        'itemName': widget.itemName ?? 'Unknown',
        'employeeId': 'EMP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}', // Generate employee ID
        'employeeName': _employeeNameController.text,
        'teamName': _teamNameController.text,
        'purpose': _purposeController.text,
        'issuedDate': _issueDateController.text.isNotEmpty ? _issueDateController.text : null,
        'expectedReturnDate': _expectedReturnDateController.text.isNotEmpty ? _expectedReturnDateController.text : null,
        'actualReturnDate': _actualReturnDateController.text.isNotEmpty ? _actualReturnDateController.text : null,
        'availabilityStatus': _selectedStatus,
      };

      print('DEBUG: Submitting allocation data: $allocationData');

      // Call API to add allocation record
      final response = await apiService.addAllocationRecord(allocationData);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Allocation record added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Close dialog and refresh data
        Navigator.of(context).pop();
        widget.onAllocationAdded();
      }
    } catch (e) {
      print('DEBUG: Full error details: $e');
      if (mounted) {
        // Show more detailed error message
        String errorMessage = 'Error adding allocation record: ';
        if (e.toString().contains('connection')) {
          errorMessage += 'Cannot connect to server. Please check if backend is running.';
        } else if (e.toString().contains('404')) {
          errorMessage += 'API endpoint not found. Please check backend configuration.';
        } else if (e.toString().contains('500')) {
          errorMessage += 'Server error. Please check backend logs for details.';
        } else {
          errorMessage += e.toString();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
                  'Add new tool for usage & allocation',
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
                  // Row 1: Issue Date & Employee Name
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Issue date *',
                          'Select the issue date',
                          _issueDateController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Employee name *',
                          'Enter the employee name',
                          _employeeNameController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Row 2: Team Name & Purpose
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          'Team name *',
                          'Enter the team name',
                          _teamNameController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          'Purpose *',
                          'Enter the purpose',
                          _purposeController,
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Row 3: Expected Return Date & Actual Return Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          'Expected return date *',
                          'Select the expected return date',
                          _expectedReturnDateController,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          'Actual return date *',
                          'Select the actual return date',
                          _actualReturnDateController,
                          required: false, // Optional since item might still be allocated
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Status Dropdown (Half Width)
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: _buildDropdownField(
                      'Status',
                      'Select the available status',
                      _selectedStatus,
                      _statusOptions,
                      (value) {
                        setState(() {
                          _selectedStatus = value ?? '';
                        });
                      },
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
}