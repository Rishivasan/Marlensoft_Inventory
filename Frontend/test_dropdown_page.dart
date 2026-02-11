import 'package:flutter/material.dart';
import 'services/quality_service.dart';

class TestDropdownPage extends StatefulWidget {
  const TestDropdownPage({super.key});

  @override
  State<TestDropdownPage> createState() => _TestDropdownPageState();
}

class _TestDropdownPageState extends State<TestDropdownPage> {
  String? selectedType;
  String? selectedUnit;
  
  List<Map<String, dynamic>> controlPointTypes = [];
  List<String> units = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final controlPointTypesData = await QualityService.getControlPointTypes();
      final unitsData = await QualityService.getUnits();

      print('DEBUG: Raw control point types: $controlPointTypesData');
      print('DEBUG: Raw units: $unitsData');

      setState(() {
        controlPointTypes = controlPointTypesData.map((item) => {
          'id': item['controlPointTypeId']?.toString() ?? item['ControlPointTypeId']?.toString() ?? '',
          'name': item['typeName']?.toString() ?? item['TypeName']?.toString() ?? '',
          'description': item['description']?.toString() ?? item['Description']?.toString() ?? '',
        }).toList();

        units = unitsData.map((unit) => unit.toString()).toList();
        isLoading = false;
      });

      print('DEBUG: Processed control point types: $controlPointTypes');
      print('DEBUG: Processed units: $units');
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Dropdowns'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Control Point Types:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select type',
                    ),
                    items: controlPointTypes
                        .map((t) => DropdownMenuItem<String>(
                            value: t['id'].toString(),
                            child: Text(t['name'].toString())))
                        .toList(),
                    onChanged: (value) {
                      print('Type selected: $value');
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Units:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select unit',
                    ),
                    items: units
                        .map((u) => DropdownMenuItem<String>(
                            value: u,
                            child: Text(u)))
                        .toList(),
                    onChanged: (value) {
                      print('Unit selected: $value');
                      setState(() {
                        selectedUnit = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Selected Type: $selectedType'),
                  Text('Selected Unit: $selectedUnit'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Current selections - Type: $selectedType, Unit: $selectedUnit');
                    },
                    child: const Text('Test Selections'),
                  ),
                ],
              ),
      ),
    );
  }
}