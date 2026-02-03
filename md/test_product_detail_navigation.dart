// Test file to verify Product Detail navigation and header state management
// This demonstrates how the header state changes when navigating to Product Detail

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/header_state.dart';
import 'package:inventory/screens/product_detail_screen.dart';

void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TestScreen(),
    );
  }
}

class TestScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final header = ref.watch(headerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Header Test'),
      ),
      body: Column(
        children: [
          // Display current header state
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Header State:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Title: ${header.title}'),
                Text('Subtitle: ${header.subtitle}'),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Button to navigate to Product Detail
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(id: 'test123'),
                ),
              );
            },
            child: Text('Go to Product Detail'),
          ),
          
          SizedBox(height: 20),
          
          // Button to manually set header
          ElevatedButton(
            onPressed: () {
              ref.read(headerProvider.notifier).state = HeaderModel(
                title: "Manual Test",
                subtitle: "This is a manual test of header state",
              );
            },
            child: Text('Set Manual Header'),
          ),
        ],
      ),
    );
  }
}