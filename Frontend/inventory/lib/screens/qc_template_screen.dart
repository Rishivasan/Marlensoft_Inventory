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
  int? selectedTemplateId; // Track the selected template ID

  // Dynamic lists that will be populated from the backend
  List<Map<String, dynamic>> validationTypes = [];
  List<Map<String, dynamic>> materialComponents = [];
  List<Map<String, dynamic>> finalProducts = [];
  List<Map<String, dynamic>> templates = [];

  // Control points loaded from API - no dummy data
  List<Map<String, dynamic>> controlPoints = [];
  bool isLoadingControlPoints = false;
  bool isLoadingTemplates = false;

  // Validation type code mapping
  final Map<String, String> validationTypeCodes = {
    'Incoming Goods Validation': 'IG',
    'In-progress Validation': 'IP',
    'Inprocess Validation': 'IP',
    'Final Inspection': 'FI',
  };

  @override
  void initState() {
    super.initState();
    _loadTemplates(); // Load templates from API first
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

  Future<void> _loadTemplates() async {
    setState(() {
      isLoadingTemplates = true;
    });

    try {
      final templatesData = await QualityService.getTemplates();
      setState(() {
        templates = templatesData.map((item) => {
          'id': item['QCTemplateId'] ?? item['qcTemplateId'],
          'name': item['TemplateName'] ?? item['templateName'] ?? 'Untitled Template',
          'validationTypeId': item['ValidationTypeId'] ?? item['validationTypeId'],
          'finalProductId': item['FinalProductId'] ?? item['finalProductId'],
          'materialId': item['MaterialId'] ?? item['materialId'],
          'productName': item['ProductName'] ?? item['productName'],
          'isActive': false,
        }).toList();
        
        // Set the first template as active if there are any templates
        if (templates.isNotEmpty) {
          templates[0]['isActive'] = true;
          selectedTemplateId = templates[0]['id'];
          // Load control points for the first template
          _loadControlPoints();
          // Load template details into form
          _loadTemplateDetails(templates[0]);
        }
        
        isLoadingTemplates = false;
      });
      
      print('DEBUG: Loaded ${templates.length} templates');
    } catch (e) {
      print('Error loading templates: $e');
      setState(() {
        templates = [];
        isLoadingTemplates = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load templates from server.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _loadTemplateDetails(Map<String, dynamic> template) {
    // Load template details into the form
    setState(() {
      // Set validation type if available
      if (template['validationTypeId'] != null) {
        selectedValidationType = template['validationTypeId'].toString();
      } else {
        selectedValidationType = null;
      }
      
      // Set final product if available and load materials
      if (template['finalProductId'] != null) {
        selectedFinalProduct = template['finalProductId'].toString();
        // Load materials for this product
        _loadMaterialsForProduct(template['finalProductId']).then((_) {
          // After materials are loaded, set the selected material
          if (template['materialId'] != null) {
            setState(() {
              selectedMaterialComponent = template['materialId'].toString();
            });
          }
        });
      } else {
        selectedFinalProduct = null;
        selectedMaterialComponent = null;
      }
      
      // Clear tools field as it's not stored in backend
      toolsToQualityCheck = '';
    });
  }

  Future<void> _loadMaterialsForProduct(int productId) async {
    try {
      final materialsData = await QualityService.getMaterials(productId);
      setState(() {
        materialComponents = materialsData.map((item) => {
          'id': item['MaterialId'] ?? item['materialId'],
          'name': item['MaterialName'] ?? item['materialName'] ?? item['name'],
          'msiCode': item['MSICode'] ?? item['msiCode'] ?? '',
        }).toList();
      });
      print('DEBUG: Loaded ${materialComponents.length} materials for product $productId');
    } catch (e) {
      print('Error loading materials: $e');
      // Set fallback data if API fails
      setState(() {
        materialComponents = [
          {'id': 1, 'name': 'Steel Grade A', 'msiCode': 'MSI-001'},
          {'id': 2, 'name': 'Aluminum Alloy', 'msiCode': 'MSI-002'},
          {'id': 3, 'name': 'Plastic Polymer', 'msiCode': 'MSI-003'},
          {'id': 4, 'name': 'Composite Material', 'msiCode': 'MSI-004'},
        ];
      });
    }
  }

  Future<void> _loadControlPoints() async {
    if (selectedTemplateId == null || selectedTemplateId == -1) {
      // For untitled template or no selection, just clear control points
      setState(() {
        controlPoints = [];
        isLoadingControlPoints = false;
      });
      return;
    }

    setState(() {
      isLoadingControlPoints = true;
    });

    try {
      final controlPointsData = await QualityService.getControlPoints(selectedTemplateId!);
      setState(() {
        controlPoints = controlPointsData.map((item) => {
          'id': item['qcControlPointId'] ?? item['QCControlPointId'],
          'name': item['controlPointName'] ?? item['ControlPointName'],
          'order': item['sequenceOrder'] ?? item['SequenceOrder'] ?? 1,
          'typeId': item['controlPointTypeId'] ?? item['ControlPointTypeId'],
          'targetValue': item['targetValue'] ?? item['TargetValue'],
          'unit': item['unit'] ?? item['Unit'],
          'tolerance': item['tolerance'] ?? item['Tolerance'],
        }).toList();
        isLoadingControlPoints = false;
      });
      print('Loaded ${controlPoints.length} control points for template $selectedTemplateId');
    } catch (e) {
      print('Error loading control points: $e');
      setState(() {
        controlPoints = [];
        isLoadingControlPoints = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to load control points: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _createNewTemplate() async {
    // Validate form fields
    if (selectedValidationType == null || selectedValidationType!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a validation type'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedFinalProduct == null || selectedFinalProduct!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a final product'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (selectedMaterialComponent == null || selectedMaterialComponent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a material/component'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get the validation type name and code
      final validationType = validationTypes.firstWhere(
        (v) => v['id'].toString() == selectedValidationType,
        orElse: () => {'name': 'Unknown'},
      );
      final validationTypeName = validationType['name'] as String;
      final validationTypeCode = validationTypeCodes[validationTypeName] ?? 'XX';

      // Get the product name
      final productName = finalProducts.firstWhere(
        (p) => p['id'].toString() == selectedFinalProduct,
        orElse: () => {'name': 'Unknown Product'},
      )['name'];

      // Get the material name and MSI code
      final material = materialComponents.firstWhere(
        (m) => m['id'].toString() == selectedMaterialComponent,
        orElse: () => {'name': 'Unknown Material', 'msiCode': 'MSI-XXX'},
      );
      final materialName = material['name'] as String;
      final msiCode = material['msiCode'] as String;

      // Generate template name in format: {ValidationTypeCode} - {FinalProductName} - {MSICode} - {MaterialName}
      final templateName = '$validationTypeCode - $productName - $msiCode - $materialName';

      // Create template data
      final templateData = {
        'templateName': templateName,
        'validationTypeId': int.tryParse(selectedValidationType!) ?? 0,
        'finalProductId': int.tryParse(selectedFinalProduct!) ?? 0,
        'materialId': int.tryParse(selectedMaterialComponent!) ?? 0,
        'productName': productName,
      };

      print('DEBUG: Creating template with name: $templateName');

      // Call API to create template
      final newTemplateId = await QualityService.createTemplate(templateData);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (newTemplateId > 0) {
        // Reload templates from API to get the latest list
        await _loadTemplates();
        
        // Remove "Untitled template" from the list
        templates.removeWhere((t) => t['id'] == -1);
        
        // Find and activate the newly created template
        final newTemplate = templates.firstWhere(
          (t) => t['id'] == newTemplateId,
          orElse: () => {},
        );
        
        if (newTemplate.isNotEmpty) {
          setState(() {
            // Deactivate all templates
            for (var t in templates) {
              t['isActive'] = false;
            }
            // Activate the new template
            newTemplate['isActive'] = true;
            selectedTemplateId = newTemplateId;
            
            // Clear the form fields
            selectedValidationType = null;
            selectedFinalProduct = null;
            selectedMaterialComponent = null;
            materialComponents.clear();
            toolsToQualityCheck = '';
          });
          
          // Load control points for new template (will be empty)
          _loadControlPoints();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Template created: $templateName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Failed to create template');
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create template: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _prepareNewTemplate() {
    // Add "Untitled template" to the sidebar and clear form for new template creation
    setState(() {
      // Deactivate all templates in the sidebar
      for (var t in templates) {
        t['isActive'] = false;
      }
      
      // Add "Untitled template" at the top if it doesn't exist
      final hasUntitled = templates.any((t) => t['id'] == -1);
      if (!hasUntitled) {
        templates.insert(0, {
          'id': -1, // Special ID for untitled template
          'name': 'Untitled template',
          'isActive': true,
        });
      } else {
        // If it exists, just activate it
        templates.firstWhere((t) => t['id'] == -1)['isActive'] = true;
      }
      
      // Clear all form fields
      selectedValidationType = null;
      selectedFinalProduct = null;
      selectedMaterialComponent = null;
      materialComponents.clear();
      toolsToQualityCheck = '';
      selectedTemplateId = -1; // Set to untitled template ID
      controlPoints.clear();
    });
  }

  void _showAddControlPointDialog() {
    // Ensure we have a selected template and it's not the untitled template
    if (selectedTemplateId == null || selectedTemplateId == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create the template first before adding control points'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    DialogPannelHelper().showAddPannel(
      context: context,
      addingItem: AddControlPoint(
        templateId: selectedTemplateId!,
        submit: () {
          // Refresh the control points list from API
          _loadControlPoints();
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
                            onPressed: _prepareNewTemplate,
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
                        child: isLoadingTemplates
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : templates.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 48,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No templates yet',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Click "Add new template" to create one',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
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
                                            // If clicking on "Untitled template", do nothing (it's already active)
                                            if (template['id'] == -1) {
                                              return;
                                            }
                                            
                                            setState(() {
                                              // Remove "Untitled template" if it exists
                                              templates.removeWhere((t) => t['id'] == -1);
                                              
                                              // Deactivate all templates
                                              for (var t in templates) {
                                                t['isActive'] = false;
                                              }
                                              
                                              // Activate the clicked template
                                              template['isActive'] = true;
                                              selectedTemplateId = template['id'];
                                            });
                                            
                                            // Load template details into form
                                            _loadTemplateDetails(template);
                                            
                                            // Load control points for the newly selected template
                                            _loadControlPoints();
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
                          child: isLoadingControlPoints
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : controlPoints.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.checklist,
                                            size: 48,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No control points yet',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Click "Add control point" to create one',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
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
                                      onPressed: () async {
                                        // Show confirmation dialog
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                              'Delete Control Point',
                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                            ),
                                            content: Text(
                                              'Are you sure you want to delete "${point['name']}"?',
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFFEF4444),
                                                ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirmed == true) {
                                          // Show loading
                                          if (context.mounted) {
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (context) => const Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            );
                                          }

                                          // Call delete API
                                          final success = await QualityService.deleteControlPoint(point['id']);

                                          // Close loading dialog
                                          if (context.mounted) {
                                            Navigator.of(context).pop();
                                          }

                                          if (success) {
                                            // Refresh the list
                                            _loadControlPoints();
                                            
                                            // Show success message
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Control point deleted successfully'),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } else {
                                            // Show error message
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Failed to delete control point'),
                                                  backgroundColor: Colors.red,
                                                  duration: Duration(seconds: 3),
                                                ),
                                              );
                                            }
                                          }
                                        }
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
                                onPressed: _createNewTemplate,
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