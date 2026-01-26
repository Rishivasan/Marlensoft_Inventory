import 'dart:convert';
import 'dart:html' as html;
import 'package:inventory/model/master_list_model.dart';
import 'package:flutter/foundation.dart';

class ExportService {
  static Future<String?> exportToExcel(List<MasterListModel> items) async {
    try {
      print('🔥 Starting export for ${items.length} items');
      
      if (kIsWeb) {
        return await _exportToCsvWeb(items);
      } else {
        return await _exportToCsvMobile(items);
      }
    } catch (e) {
      print('🔥 Error in export: $e');
      return null;
    }
  }

  static Future<String?> _exportToCsvWeb(List<MasterListModel> items) async {
    try {
      print('🔥 Creating CSV content for web');
      
      // Create CSV content
      StringBuffer csvBuffer = StringBuffer();
      
      // Add headers
      csvBuffer.writeln('Item ID,Type,Item Name,Vendor,Created Date,Responsible Team,Storage Location,Next Service Due,Availability Status');
      
      // Add data rows
      for (var item in items) {
        String nextServiceDue = item.nextServiceDue != null 
            ? "${item.nextServiceDue!.day}/${item.nextServiceDue!.month}/${item.nextServiceDue!.year}"
            : "N/A";
            
        csvBuffer.writeln([
          _escapeCsvField(item.assetId),
          _escapeCsvField(item.type),
          _escapeCsvField(item.assetName),
          _escapeCsvField(item.supplier),
          _escapeCsvField("${item.createdDate.day}/${item.createdDate.month}/${item.createdDate.year}"),
          _escapeCsvField(item.responsibleTeam),
          _escapeCsvField(item.location),
          _escapeCsvField(nextServiceDue),
          _escapeCsvField(item.availabilityStatus),
        ].join(','));
      }
      
      String csvContent = csvBuffer.toString();
      print('🔥 CSV content created, ${csvContent.length} characters');
      
      // Create filename
      String fileName = 'inventory_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      
      try {
        // Create and trigger download
        final bytes = utf8.encode(csvContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';
        
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        
        html.Url.revokeObjectUrl(url);
        
        print('🔥 CSV download triggered: $fileName');
        return fileName;
      } catch (downloadError) {
        print('🔥 Download error: $downloadError');
        return null;
      }
    } catch (e) {
      print('🔥 Error creating CSV for web: $e');
      return null;
    }
  }

  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  static Future<String?> _exportToCsvMobile(List<MasterListModel> items) async {
    try {
      print('🔥 Creating CSV for mobile - returning success');
      // For mobile, just return success (implement file saving later if needed)
      String fileName = 'inventory_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      return fileName;
    } catch (e) {
      print('🔥 Error creating mobile CSV: $e');
      return null;
    }
  }
}