import 'package:flutter/material.dart';

class NextServiceProvider extends ChangeNotifier {
  // Map to store calculated next service dates by asset ID
  final Map<String, DateTime?> _nextServiceDates = {};
  
  // Get next service date for an asset
  DateTime? getNextServiceDate(String assetId) {
    return _nextServiceDates[assetId];
  }
  
  // Calculate next service date based on created date and maintenance frequency
  DateTime? calculateNextServiceDate({
    required DateTime baseDate,
    required String maintenanceFrequency,
  }) {
    final frequency = maintenanceFrequency.toLowerCase();
    
    switch (frequency) {
      case 'daily':
        return baseDate.add(const Duration(days: 1));
      case 'weekly':
        return baseDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(baseDate.year, baseDate.month + 1, baseDate.day);
      case 'quarterly':
        return DateTime(baseDate.year, baseDate.month + 3, baseDate.day);
      case 'half-yearly':
      case 'halfyearly':
        return DateTime(baseDate.year, baseDate.month + 6, baseDate.day);
      case 'yearly':
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
      case '2nd year':
        return DateTime(baseDate.year + 2, baseDate.month, baseDate.day);
      case '3rd year':
        return DateTime(baseDate.year + 3, baseDate.month, baseDate.day);
      default:
        // Default to yearly if frequency is not recognized
        return DateTime(baseDate.year + 1, baseDate.month, baseDate.day);
    }
  }
  
  // Calculate and store next service date for an asset
  void calculateAndStoreNextServiceDate({
    required String assetId,
    required DateTime createdDate,
    required String maintenanceFrequency,
    DateTime? lastServiceDate,
  }) {
    // Use last service date if available, otherwise use created date
    final baseDate = lastServiceDate ?? createdDate;
    
    final nextServiceDate = calculateNextServiceDate(
      baseDate: baseDate,
      maintenanceFrequency: maintenanceFrequency,
    );
    
    _nextServiceDates[assetId] = nextServiceDate;
    notifyListeners();
  }
  
  // Update next service date after maintenance is performed
  void updateNextServiceDateAfterMaintenance({
    required String assetId,
    required DateTime serviceDate,
    required String maintenanceFrequency,
  }) {
    final nextServiceDate = calculateNextServiceDate(
      baseDate: serviceDate,
      maintenanceFrequency: maintenanceFrequency,
    );
    
    _nextServiceDates[assetId] = nextServiceDate;
    notifyListeners();
  }
  
  // Directly update next service date (used when we already have the calculated date)
  void updateNextServiceDate(String assetId, DateTime nextServiceDate) {
    _nextServiceDates[assetId] = nextServiceDate;
    notifyListeners();
  }
  
  // Clear next service date for an asset
  void clearNextServiceDate(String assetId) {
    _nextServiceDates.remove(assetId);
    notifyListeners();
  }
  
  // Clear all next service dates
  void clearAll() {
    _nextServiceDates.clear();
    notifyListeners();
  }
  
  // Get all next service dates
  Map<String, DateTime?> getAllNextServiceDates() {
    return Map.from(_nextServiceDates);
  }
  
  // Check if an asset has overdue maintenance
  bool isMaintenanceOverdue(String assetId) {
    final nextServiceDate = _nextServiceDates[assetId];
    if (nextServiceDate == null) return false;
    
    return DateTime.now().isAfter(nextServiceDate);
  }
  
  // Get days until next service (negative if overdue)
  int? getDaysUntilNextService(String assetId) {
    final nextServiceDate = _nextServiceDates[assetId];
    if (nextServiceDate == null) return null;
    
    return nextServiceDate.difference(DateTime.now()).inDays;
  }
  
  // Get maintenance status text
  String getMaintenanceStatus(String assetId) {
    final daysUntil = getDaysUntilNextService(assetId);
    if (daysUntil == null) return 'No Schedule';
    
    if (daysUntil < 0) {
      return 'Overdue (${daysUntil.abs()} days)';
    } else if (daysUntil == 0) {
      return 'Due Today';
    } else if (daysUntil <= 7) {
      return 'Due Soon ($daysUntil days)';
    } else {
      return 'Scheduled ($daysUntil days)';
    }
  }
}