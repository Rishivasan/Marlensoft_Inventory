import 'package:flutter/material.dart';
import 'package:inventory/services/delete_service.dart';

class TestDeleteWidget extends StatefulWidget {
  const TestDeleteWidget({super.key});

  @override
  State<TestDeleteWidget> createState() => _TestDeleteWidgetState();
}

class _TestDeleteWidgetState extends State<TestDeleteWidget> {
  String _result = '';
  bool _isLoading = false;

  Future<void> _testDelete() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing delete...';
    });

    try {
      // Test with a known item (you can change this ID)
      final success = await DeleteService.deleteItem('consumable', 'CON089');
      setState(() {
        _result = 'Delete result: $success';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Delete')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testDelete,
              child: _isLoading 
                ? const CircularProgressIndicator()
                : const Text('Test Delete'),
            ),
            const SizedBox(height: 20),
            Text(_result),
          ],
        ),
      ),
    );
  }
}