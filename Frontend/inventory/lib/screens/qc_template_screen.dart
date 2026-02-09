import 'package:flutter/material.dart';
import '../services/quality_service.dart';
import '../dialogs/dialog_pannel_helper.dart';
import '../widgets/searchable_dropdown.dart';
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
  int? selectedTemplateId; // Track the selected template ID

  // Text controller for Tools to quality check field
  final TextEditingController _toolsController = TextEditingController();
  
  // Text controller for template search
  final TextEditingController _templateSearchController = TextEditingController();
  
  // GlobalKeys for searchable dropdowns to control them
  final GlobalKey<SearchableDropdownState> _finalProductDropdownKey = GlobalKey();
  final GlobalKey<SearchableDropdownState> _materialDropdownKey = GlobalKey();

  // Dynamic lists that will be populated from the backend
  List<Map<String, dynamic>> validationTypes = [];
  List<Map<String, dynamic>> materialComponents = [];
  List<Map<String, dynamic>> finalProducts = [];
  List<Map<String, dynamic>> templates = [];
  List<Map<String, dynamic>> filteredTemplates = []; // Filtered templates for search

  // Control points loaded from API - no dummy data
  List<Map<String, dynamic>> controlPoints = [];
  bool isLoadingControlPoints = false;
  bool isLoadingTemplates = false;
  
  // Temporary control points for untitled template (before saving)
  List<Map<String, dynamic>> tempControlPoints = [];
  
  // Duplicate material tracking
  bool hasDuplicateMaterial = false;
  String? duplicateTemplateName;
  
  // Close all searchable dropdowns
  void _closeAllDropdowns() {
    _finalProductDropdownKey.currentState?.closeDropdown();
    _materialDropdownKey.currentState?.closeDropdown();
  }
  
  // Filter templates based on search query
  void _filterTemplates(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTemplates = templates;
      } else {
        filteredTemplates = templates.where((template) {
          final templateName = template['name'].toString().toLowerCase();
          return templateName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  
  // Helper function to get display number based on control point type
  String _getTypeBasedNumber(dynamic typeId) {
    // Map control point type ID to display number
    // 1 = Measure → Show 1
    // 2 = Take a picture → Show 2  
    // 3 = Visual inspection → Show 3
    
    // Handle null or 0
    if (typeId == null || typeId == 0) {
      print('WARNING: typeId is null or 0, defaulting to 1');
      return '1';
    }
    
    // Convert to int if it's a string
    int typeIdInt;
    if (typeId is String) {
      typeIdInt = int.tryParse(typeId) ?? 1;
    } else if (typeId is int) {
      typeIdInt = typeId;
    } else {
      print('WARNING: typeId is unexpected type: ${typeId.runtimeType}');
      return '1';
    }
    
    return typeIdInt.toString();
  }

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

  @override
  void dispose() {
    _toolsController.dispose();
    _templateSearchController.dispose();
    super.dispose();
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
          'toolsToQualityCheck': item['ToolsToQualityCheck'] ?? item['toolsToQualityCheck'] ?? '',
          'isActive': false,
        }).toList();
        
        // Initialize filtered templates
        filteredTemplates = templates;
        
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
        filteredTemplates = [];
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
        // Clear material selection first to avoid dropdown error
        selectedMaterialComponent = null;
        
        // Load materials for this product
        _loadMaterialsForProduct(template['finalProductId']).then((_) {
          // After materials are loaded, set the selected material if it exists in the list
          if (template['materialId'] != null) {
            final materialIdStr = template['materialId'].toString();
            // Check if this material ID exists in the loaded materials
            final materialExists = materialComponents.any((m) => m['id'].toString() == materialIdStr);
            
            setState(() {
              if (materialExists) {
                selectedMaterialComponent = materialIdStr;
              } else {
                print('WARNING: Material ID $materialIdStr not found in materials list');
                selectedMaterialComponent = null;
              }
            });
          }
        });
      } else {
        selectedFinalProduct = null;
        selectedMaterialComponent = null;
      }
      
      // Load tools field from template data
      _toolsController.text = template['toolsToQualityCheck'] ?? '';
    });
  }

  Future<void> _loadMaterialsForProduct(int productId) async {
    try {
      final materialsData = await QualityService.getMaterials(productId);
      
      // Remove duplicates by material ID
      final Map<int, Map<String, dynamic>> uniqueMaterials = {};
      for (var item in materialsData) {
        final id = item['MaterialId'] ?? item['materialId'];
        if (id != null && !uniqueMaterials.containsKey(id)) {
          uniqueMaterials[id] = {
            'id': id,
            'name': item['MaterialName'] ?? item['materialName'] ?? item['name'],
            'msiCode': item['MSICode'] ?? item['msiCode'] ?? '',
          };
        }
      }
      
      setState(() {
        materialComponents = uniqueMaterials.values.toList();
      });
      print('DEBUG: Loaded ${materialComponents.length} unique materials for product $productId');
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
        controlPoints = controlPointsData.map((item) {
          // Debug: Print the raw item to see what we're getting
          print('DEBUG Control Point: ${item}');
          
          return {
            'id': item['qcControlPointId'] ?? item['QCControlPointId'],
            'name': item['controlPointName'] ?? item['ControlPointName'],
            'order': item['sequenceOrder'] ?? item['SequenceOrder'] ?? 1,
            'typeId': item['controlPointTypeId'] ?? item['ControlPointTypeId'],
            'targetValue': item['targetValue'] ?? item['TargetValue'],
            'unit': item['unit'] ?? item['Unit'],
            'tolerance': item['tolerance'] ?? item['Tolerance'],
          };
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

    // NEW VALIDATION: Check for duplicate material
    if (hasDuplicateMaterial) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A template already exists for this material: "$duplicateTemplateName"'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // NEW VALIDATION: Check if at least one control point exists
    if (tempControlPoints.isEmpty && controlPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one control point before creating the template'),
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
        'toolsToQualityCheck': _toolsController.text.trim(),
      };

      print('DEBUG: Creating template with name: $templateName');

      // Call API to create template
      final newTemplateId = await QualityService.createTemplate(templateData);

      if (newTemplateId > 0) {
        // NEW: Add all temporary control points to the newly created template
        if (tempControlPoints.isNotEmpty) {
          print('DEBUG: Adding ${tempControlPoints.length} control points to template $newTemplateId');
          
          for (var controlPoint in tempControlPoints) {
            try {
              // Update the templateId for each control point
              final controlPointData = Map<String, dynamic>.from(controlPoint);
              controlPointData['qcTemplateId'] = newTemplateId;
              
              // Add control point via API
              await QualityService.addControlPoint(controlPointData);
            } catch (e) {
              print('ERROR: Failed to add control point: $e');
              // Continue with other control points even if one fails
            }
          }
          
          // Clear temporary control points after adding them
          tempControlPoints.clear();
        }
        
        // Close loading dialog
        if (mounted) Navigator.of(context).pop();
        
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
            _toolsController.clear();
          });
          
          // Load control points for new template (will show the ones we just added)
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
      
      // Update filtered templates
      filteredTemplates = templates;
      
      // Clear all form fields
      selectedValidationType = null;
      selectedFinalProduct = null;
      selectedMaterialComponent = null;
      materialComponents.clear();
      _toolsController.clear();
      selectedTemplateId = -1; // Set to untitled template ID
      
      // Clear both control point lists
      controlPoints.clear();
      tempControlPoints.clear();
      
      // Clear duplicate material flag
      hasDuplicateMaterial = false;
      duplicateTemplateName = null;
    });
  }

  void _cancelUntitledTemplate() {
    // Reset form and remove untitled template from sidebar
    setState(() {
      // Remove "Untitled template" from the list
      templates.removeWhere((t) => t['id'] == -1);
      
      // Clear all form fields
      selectedValidationType = null;
      selectedFinalProduct = null;
      selectedMaterialComponent = null;
      materialComponents.clear();
      _toolsController.clear();
      
      // Clear both control point lists
      controlPoints.clear();
      tempControlPoints.clear();
      
      // Clear duplicate material flag
      hasDuplicateMaterial = false;
      duplicateTemplateName = null;
      
      // If there are other templates, activate the first one
      if (templates.isNotEmpty) {
        templates[0]['isActive'] = true;
        selectedTemplateId = templates[0]['id'];
        // Load template details into form
        _loadTemplateDetails(templates[0]);
        // Load control points for the selected template
        _loadControlPoints();
      } else {
        selectedTemplateId = null;
      }
    });
  }

  void _showAddControlPointDialog() {
    // Allow adding control points even for untitled template
    // If it's an untitled template, we'll store them temporarily
    final isUntitledTemplate = selectedTemplateId == null || selectedTemplateId == -1;
    
    DialogPannelHelper().showAddPannel(
      context: context,
      addingItem: AddControlPoint(
        templateId: selectedTemplateId ?? -1,
        isTemporary: isUntitledTemplate,
        submit: (Map<String, dynamic>? controlPointData) {
          if (isUntitledTemplate && controlPointData != null) {
            // Add to temporary list for untitled template
            // Normalize the data structure to match what we expect from API
            final normalizedData = {
              'id': DateTime.now().millisecondsSinceEpoch, // Temporary ID
              'name': controlPointData['controlPointName'] ?? '',
              'order': tempControlPoints.length + 1,
              'typeId': controlPointData['controlPointTypeId'],
              'targetValue': controlPointData['targetValue'],
              'unit': controlPointData['unit'],
              'tolerance': controlPointData['tolerance'],
              // Keep original data for API submission
              '_originalData': controlPointData,
            };
            
            setState(() {
              tempControlPoints.add(controlPointData);
              // Add normalized data to display list
              controlPoints.add(normalizedData);
            });
          } else {
            // Refresh the control points list from API for existing templates
            _loadControlPoints();
          }
        },
      ),
    );
  }

  // Track active tab
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // Tab header at the top
          Container(
            color: const Color(0xFFF3F4F6),
            padding: const EdgeInsets.only(left: 0, top: 0, right: 24, bottom: 0),
            child: Row(
              children: [
                // Quality check customization tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTabIndex = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeTabIndex == 0 ? Colors.white :  Colors.transparent ,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Quality check customization',
                      style: TextStyle(
                        color: _activeTabIndex == 0 ?const Color(0xff00599A) : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: _activeTabIndex == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Production process customization tab
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTabIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeTabIndex == 1 ?  Colors.white :  Colors.transparent ,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Production process customization',
                      style: TextStyle(
                        color: _activeTabIndex == 1 ?const Color(0xff00599A) :const Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: _activeTabIndex == 1 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Conditional content based on active tab
          Expanded(
            child: _activeTabIndex == 1
                ? // Show full-page "Under Construction" screen for Production process customization
                  Container(
                    padding: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/Images/under_construction.png',
                            fit: BoxFit.contain,
                            width: 420,
                          ),
                        ],
                      ),
                    ),
                  )
                : // Show Quality Check Customization content with description and sidebar
                  Column(
                    children: [
                      // Description text
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 13, right: 24, top: 20, bottom: 20),
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
                            // Left sidebar with templates (25% of width)
                            Expanded(
                  flex: 25,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add new template button (full width, no padding)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),

                          //margin: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
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
                        
                        // Search field
                        Container(
                          //margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                          
                          margin: const EdgeInsets.all(12.0),
                          height: 40,
                          child: TextField(
                            controller: _templateSearchController,
                            onChanged: _filterTemplates,
                            decoration: InputDecoration(
                              hintText: 'Search templates...',
                              hintStyle: const TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: Color.fromRGBO(144, 144, 144, 1),
                              ),
                              suffixIcon: _templateSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        size: 18,
                                        color: Color.fromRGBO(144, 144, 144, 1),
                                      ),
                                      onPressed: () {
                                        _templateSearchController.clear();
                                        _filterTemplates('');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 154, 1), width: 1.2),
                              ),
                            ),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        
                        // Templates list
                        Expanded(
                          child: isLoadingTemplates
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : filteredTemplates.isEmpty
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
                                      itemCount: filteredTemplates.length,
                                      itemBuilder: (context, index) {
                                        final template = filteredTemplates[index];
                                        final isActive = template['isActive'] as bool;
                                        
                                        return Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isActive 
                                                ? const Color(0xFFE3F2FD) 
                                                : const Color.fromRGBO(247, 247, 247, 0.7),
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
                ),
                
                // Main content area (75% of width)
                Expanded(
                  flex: 75,
                  child: Container(
                    color: Colors.white,
                    //padding: const EdgeInsets.all(12),
                    padding: const EdgeInsets.only(left: 8, right: 16, top: 0, bottom: 16),

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
                              child: DropdownButtonFormField<String>(
                                value: selectedValidationType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: 'Validation type *',
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(144, 144, 144, 1),
                                  ),
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
                                  floatingLabelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(88, 88, 88, 1),
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
                                onChanged: (selectedTemplateId == -1 || selectedTemplateId == null) 
                                    ? (String? newValue) {
                                        // Close all searchable dropdowns when validation type changes
                                        _closeAllDropdowns();
                                        
                                        setState(() {
                                          selectedValidationType = newValue;
                                        });
                                      }
                                    : null, // Disable dropdown for existing templates
                              ),
                            ),
                            
                            const SizedBox(width: 24),
                            
                            // Final product dropdown (searchable)
                            Expanded(
                              child: SearchableDropdown(
                                key: _finalProductDropdownKey,
                                value: selectedFinalProduct,
                                items: finalProducts,
                                hintText: 'Select the final product',
                                labelText: 'Final product *',
                                enabled: (selectedTemplateId == -1 || selectedTemplateId == null) && selectedValidationType != null,
                                onOpen: () {
                                  // Close material dropdown when final product opens
                                  _materialDropdownKey.currentState?.closeDropdown();
                                },
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
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 14),
                        
                        // Second row of form fields
                        Row(
                          children: [
                            // Material/Component dropdown (searchable)
                            Expanded(
                              child: SearchableDropdown(
                                key: _materialDropdownKey,
                                value: selectedMaterialComponent,
                                items: materialComponents,
                                hintText: 'Select the material/component',
                                labelText: 'Material/Component *',
                                enabled: (selectedTemplateId == -1 || selectedTemplateId == null) && selectedFinalProduct != null,
                                onOpen: () {
                                  // Close final product dropdown when material opens
                                  _finalProductDropdownKey.currentState?.closeDropdown();
                                },
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMaterialComponent = newValue;
                                    
                                    // Check if a template already exists for this material
                                    if (newValue != null && selectedTemplateId == -1) {
                                      final existingTemplate = templates.firstWhere(
                                        (t) => t['materialId']?.toString() == newValue && t['id'] != -1,
                                        orElse: () => {},
                                      );
                                      
                                      if (existingTemplate.isNotEmpty) {
                                        hasDuplicateMaterial = true;
                                        duplicateTemplateName = existingTemplate['name'];
                                        
                                        // Show SnackBar warning
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.warning_amber_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Text(
                                                        'Template Already Exists',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        'A template already exists for this material: "${existingTemplate['name']}"',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFFF59E0B),
                                            duration: const Duration(seconds: 4),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        );
                                      } else {
                                        hasDuplicateMaterial = false;
                                        duplicateTemplateName = null;
                                      }
                                    } else {
                                      hasDuplicateMaterial = false;
                                      duplicateTemplateName = null;
                                    }
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(width: 24),
                            
                            // Tools to quality check text field
                            Expanded(
                              child: TextFormField(
                                controller: _toolsController,
                                enabled: (selectedTemplateId == -1 || selectedTemplateId == null),
                                decoration: InputDecoration(
                                  labelText: 'Tools to quality check *',
                                  labelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(144, 144, 144, 1),
                                  ),
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
                                  floatingLabelStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color.fromRGBO(88, 88, 88, 1),
                                  ),
                                ),
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        
                        // QC control points section
                        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [

    /// 👇 THIS MAKES TEXT WRAP PROPERLY
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'QC control points configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Here, please define a rule for which open offers shall be followed-up at the customers and what shall happen, in case the follow-up is unsuccessful.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
            softWrap: true,        // ensures wrapping
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    ),

    const SizedBox(width: 12), // small gap between text & button

    SizedBox(
      height: 35,
      child: ElevatedButton(
        onPressed: selectedTemplateId == -1
            ? () {
                _showAddControlPointDialog();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: selectedTemplateId == -1
              ? const Color(0xff00599A)
              : const Color(0xFFD1D5DB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          disabledBackgroundColor: const Color(0xFFD1D5DB),
          disabledForegroundColor: const Color(0xFF9CA3AF),
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
                                  ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(48),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5E7EB),
                                              borderRadius: BorderRadius.circular(32),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No QC control points added yet',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add your first inspection check above',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : (selectedTemplateId == -1) 
                                      // For untitled template: Use ReorderableListView (drag-and-drop enabled)
                                      ? ReorderableListView.builder(
                                          buildDefaultDragHandles: false, // Disable automatic drag handle!
                                          itemCount: controlPoints.length,
                                          onReorder: (oldIndex, newIndex) {
                                            setState(() {
                                              if (newIndex > oldIndex) {
                                                newIndex -= 1;
                                              }
                                              final item = controlPoints.removeAt(oldIndex);
                                              controlPoints.insert(newIndex, item);
                                              
                                              // Also reorder in tempControlPoints
                                              if (oldIndex < tempControlPoints.length && newIndex < tempControlPoints.length) {
                                                final tempItem = tempControlPoints.removeAt(oldIndex);
                                                tempControlPoints.insert(newIndex, tempItem);
                                              }
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final point = controlPoints[index];
                                            return ReorderableDragStartListener(
                                              key: ValueKey(point['id']), // Required for ReorderableListView
                                              index: index,
                                              child: Container(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Drag handle (6 dots) - This is the ONLY drag handle!
                                                    Icon(Icons.drag_indicator, color: const Color(0xFF9CA3AF), size: 16),
                                                    const SizedBox(width: 8),
                                    
                                    // Order number (based on type)
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFDF7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _getTypeBasedNumber(point['typeId']),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xff00599A),
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
                                    
                                    // Delete button (disabled for saved templates)
                                    IconButton(
                                      onPressed: selectedTemplateId == -1 ? () async {
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
                                          // Check if this is a temporary control point (untitled template)
                                          final isTemporary = selectedTemplateId == -1;
                                          
                                          if (isTemporary) {
                                            // For temporary control points, just remove from the list
                                            setState(() {
                                              // Remove from both lists using the temporary ID
                                              final pointId = point['id'];
                                              controlPoints.removeWhere((cp) => cp['id'] == pointId);
                                              // Also remove from temp list (find by name since we don't have normalized ID there)
                                              tempControlPoints.removeWhere((cp) => 
                                                cp['controlPointName'] == point['name']);
                                            });
                                            
                                            // Show success message
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Control point removed'),
                                                  backgroundColor: Colors.green,
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );
                                            }
                                          } else {
                                            // For saved control points, call the API
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
                                        }
                                      } : null,
                                      icon: Icon(
                                        Icons.delete_outline, 
                                        color: selectedTemplateId == -1 
                                            ? const Color(0xFFEF4444) 
                                            : const Color(0xFFD1D5DB), 
                                        size: 16
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                    ),
                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      // For existing templates: Use regular ListView (no drag-and-drop)
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
                                                  // Drag handle (disabled for existing templates)
                                                  Icon(Icons.drag_indicator, color: const Color(0xFFE5E7EB), size: 16),
                                                  const SizedBox(width: 8),
                                                  
                                                  // Order number (based on type)
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromRGBO(0, 89, 154, 0.1),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _getTypeBasedNumber(point['typeId']),
                                                        style: const TextStyle(
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.w500,
                                                          color: Color(0xff00599A),
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
                                                  
                                                  // Delete button (disabled for saved templates)
                                                  IconButton(
                                                    onPressed: selectedTemplateId != -1 ? null : () async {
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
                                                    icon: Icon(
                                                      Icons.delete_outline, 
                                                      color: selectedTemplateId == -1 
                                                          ? const Color(0xFFEF4444) 
                                                          : const Color(0xFFD1D5DB), 
                                                      size: 16
                                                    ),
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
                        
                        // Info banner for untitled template
                        if (selectedTemplateId == -1 && tempControlPoints.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFDF7),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF059669), width: 1),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF059669),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${tempControlPoints.length} control point${tempControlPoints.length > 1 ? 's' : ''} added. Click "Add new template" to save everything.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF059669),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // Bottom buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 35,
                              child: OutlinedButton(
                                // Disable for saved templates
                                onPressed: selectedTemplateId == -1 ? () {
                                  _cancelUntitledTemplate();
                                } : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  side: BorderSide(
                                    color: selectedTemplateId == -1 
                                        ? const Color(0xFFD1D5DB) 
                                        : const Color(0xFFE5E7EB)
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  disabledForegroundColor: const Color(0xFF9CA3AF),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: selectedTemplateId == -1 
                                        ? const Color(0xFF374151) 
                                        : const Color(0xFF9CA3AF),
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
                                // Only enable when on untitled template AND no duplicate material
                                onPressed: (selectedTemplateId == -1 && !hasDuplicateMaterial) 
                                    ? _createNewTemplate 
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: (selectedTemplateId == -1 && !hasDuplicateMaterial) 
                                      ? const Color(0xff00599A) 
                                      : const Color(0xFFD1D5DB), // Lighter grey when disabled
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                                  disabledForegroundColor: const Color(0xFF9CA3AF),
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
          ),
        ],
      
      ),
    );
  }
}