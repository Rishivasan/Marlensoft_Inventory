import 'package:flutter/material.dart';
import '../services/quality_service.dart';
import '../dialogs/dialog_pannel_helper.dart';
import 'add_forms/add_control_point.dart';

class QCTemplateScreen extends StatefulWidget {
  const QCTemplateScreen({Key? key}) : super(key: key);

  @override
  State<QCTemplateScreen> createState() => _QCTemplateScreenState();
}

class _QCTemplateScreenState extends State<QCTemplateScreen> {
  String? selectedValidationType;
  String? selectedMaterialComponent;
  String? selectedFinalProduct;
  String toolsToQualityCheck = '';

  // Dynamic lists that will be populated from the backend
  List<Map<String, dynamic>> validationTypes = [];
  List<Map<String, dynamic>> materialComponents = [];
  List<Map<String, dynamic>> finalProducts = [];

  final List<Map<String, dynamic>> templates = [
    {'name': 'Untitled template', 'isActive': true},
    {'name': 'ABI 220 - Metal plate', 'isActive': false},
    {'name': 'ABC 110 - Temperature sensor', 'isActive': false},
    {'name': 'LMN 180 - Circuit breaker', 'isActive': false},
    {'name': 'GHI 250 - Power supply', 'isActive': false},
    {'name': 'JKL 400 - Voltage regulator', 'isActive': false},
    {'name': 'DEF 600 - Safety switch', 'isActive': false},
  ];

  final List<Map<String, dynamic>> controlPoints = [
    {'id': 1, 'name': 'Dimensions width', 'order': 1},
    {'id': 2, 'name': 'Dimensions height', 'order': 1},
    {'id': 3, 'name': 'Packaging material', 'order': 2},
    {'id': 4, 'name': 'Visual inspection', 'order': 3},
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      print('DEBUG: Starting to load dropdown data...');
      
      // Load validation types
      final validationTypesData = await QualityService.getValidationTypes();
      final finalProductsData = await QualityService.getFinalProducts();

      setState(() {
        validationTypes = validationTypesData.map((item) => {
          'id': item['ValidationTypeId'] ?? item['validationTypeId'],
          'name': item['ValidationName'] ?? item['validationName'] ?? item['name'],
        }).toList();

        finalProducts = finalProductsData.map((item) => {
          'id': item['FinalProductId'] ?? item['finalProductId'],
          'name': item['ProductName'] ?? item['productName'] ?? item['name'],
        }).toList();
      });

      print('DEBUG: Loaded ${validationTypes.length} validation types');
      print('DEBUG: Loaded ${finalProducts.length} final products');
      
      if (validationTypes.isNotEmpty) {
        print('DEBUG: First validation type: ${validationTypes[0]}');
      }
      if (finalProducts.isNotEmpty) {
        print('DEBUG: First final product: ${finalProducts[0]}');
      }
      
    } catch (e) {
      print('Error loading dropdown data: $e');
      // Show user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load data from server. Using sample data.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
      
      // Set fallback data if API fails
      setState(() {
        validationTypes = [
          {'id': 1, 'name': 'Dimensional Check'},
          {'id': 2, 'name': 'Visual Inspection'},
          {'id': 3, 'name': 'Performance Test'},
          {'id': 4, 'name': 'Material Analysis'},
        ];
        finalProducts = [
          {'id': 1, 'name': 'Product A'},
          {'id': 2, 'name': 'Product B'},
          {'id': 3, 'name': 'Product C'},
          {'id': 4, 'name': 'Product D'},
        ];
      });
    }
  }

  Future<void> _loadMaterialsForProduct(int productId) async {
    try {
      final materialsData = await QualityService.getMaterials(productId);
      setState(() {
        materialComponents = materialsData.map((item) => {
          'id': item['MaterialId'] ?? item['materialId'],
          'name': item['MaterialName'] ?? item['materialName'] ?? item['name'],
        }).toList();
      });
      print('DEBUG: Loaded ${materialComponents.length} materials for product $productId');
    } catch (e) {
      print('Error loading materials: $e');
      // Set fallback data if API fails
      setState(() {
        materialComponents = [
          {'id': 1, 'name': 'Steel Grade A'},
          {'id': 2, 'name': 'Aluminum Alloy'},
          {'id': 3, 'name': 'Plastic Polymer'},
          {'id': 4, 'name': 'Composite Material'},
        ];
      });
    }
  }

  void _showAddControlPointDialog() {
    DialogPannelHelper().showAddPannel(
      context: context,
      addingItem: AddControlPoint(
        submit: () {
          // Refresh the control points list
          setState(() {
            // Add the new control point to the list
            // This is a placeholder - in real implementation, you'd fetch from API
            controlPoints.add({
              'id': controlPoints.length + 1,
              'name': 'New Control Point',
              'order': controlPoints.length + 1,
            });
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header tabs at the very top without background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xff00599A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Quality check customization',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'Production process customization',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Description text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
            child: const Text(
              'Here, please define a rule for which open offers shall be followed-up at the customers and what shall happen, in case the follow-up is unsuccessful.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
          
          // Main content row with sidebar and form
          Expanded(
            child: Row(
              children: [
                // Left sidebar with templates
                Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add new template button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xff00599A)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'Add new template',
                              style: TextStyle(
                                color: Color(0xff00599A),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Templates list
                      Expanded(
                        child: ListView.builder(
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            final isActive = template['isActive'] as bool;
                            
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFFE3F2FD) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListTile(
                                title: Text(
                                  template['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isActive ? const Color(0xff00599A) : const Color(0xFF374151),
                                    fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                onTap: () {
                                  setState(() {
                                    for (var t in templates) {
                                      t['isActive'] = false;
                                    }
                                    template['isActive'] = true;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main content area
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Basic Information section
                        const Text(
                          'Basic information',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Form fields row
                        Row(
                          children: [
                            // Validation type dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Validation type ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedValidationType,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select the validation type',
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
                                      suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    hint: const Text(
                                      'Select the validation type',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    items: validationTypes.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['name'], style: const TextStyle(fontSize: 12, color: Colors.black)),
                                      );
                                    }).toList(),
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedValidationType = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Final product dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Final product ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedFinalProduct,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select the final product',
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
                                      suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    hint: const Text(
                                      'Select the final product',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    items: finalProducts.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['name'], style: const TextStyle(fontSize: 12, color: Colors.black)),
                                      );
                                    }).toList(),
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedFinalProduct = newValue;
                                        // Clear material selection when product changes
                                        selectedMaterialComponent = null;
                                        materialComponents.clear();
                                      });
                                      
                                      // Load materials for the selected product
                                      if (newValue != null) {
                                        _loadMaterialsForProduct(int.parse(newValue));
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Second row of form fields
                        Row(
                          children: [
                            // Material/Component dropdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Material/Component ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedMaterialComponent,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select the material/component',
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
                                      suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    hint: const Text(
                                      'Select the material/component',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                    ),
                                    items: materialComponents.map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['name'], style: const TextStyle(fontSize: 12, color: Colors.black)),
                                      );
                                    }).toList(),
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedMaterialComponent = newValue;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            // Tools to quality check text field
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Tools to quality check ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF374151),
                                        fontWeight: FontWeight.normal,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '*',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      hintText: 'Enter the required tools name',
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
                                    ),
                                    style: const TextStyle(fontSize: 12, color: Colors.black),
                                    onChanged: (value) {
                                      setState(() {
                                        toolsToQualityCheck = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // QC control points section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'QC control points configuration',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Here, please define a rule for which open offers shall be followed-up at the customers and what shall happen, in case the follow-up is unsuccessful.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showAddControlPointDialog();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff00599A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Add control point',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Control points list
                        Expanded(
                          child: ListView.builder(
                            itemCount: controlPoints.length,
                            itemBuilder: (context, index) {
                              final point = controlPoints[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    // Drag handle
                                    Icon(Icons.drag_indicator, color: const Color(0xFF9CA3AF), size: 16),
                                    const SizedBox(width: 8),
                                    
                                    // Order number
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFDF7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${point['order']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 12),
                                    
                                    // Control point name
                                    Expanded(
                                      child: Text(
                                        point['name'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    
                                    // Delete button
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          controlPoints.removeAt(index);
                                        });
                                      },
                                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Bottom buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 35,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Color(0xFF374151),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 35,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B7280),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Add new template',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}