import 'package:flutter_riverpod/flutter_riverpod.dart';

// Product state model to hold reactive data
class ProductState {
  final String? nextServiceDue;
  final String? availabilityStatus;
  final DateTime lastUpdated;

  ProductState({
    this.nextServiceDue,
    this.availabilityStatus,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  ProductState copyWith({
    String? nextServiceDue,
    String? availabilityStatus,
    DateTime? lastUpdated,
  }) {
    return ProductState(
      nextServiceDue: nextServiceDue ?? this.nextServiceDue,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductState &&
        other.nextServiceDue == nextServiceDue &&
        other.availabilityStatus == availabilityStatus;
  }

  @override
  int get hashCode {
    return nextServiceDue.hashCode ^ availabilityStatus.hashCode;
  }
}

// Global state map for product states
final Map<String, ProductState> _productStates = {};

// Helper provider to get state for a specific product
final productStateByIdProvider = Provider.family<ProductState?, String>((ref, assetId) {
  return _productStates[assetId];
});

// Helper provider to update next service due
final updateNextServiceDueProvider = Provider((ref) {
  return (String assetId, String? nextServiceDue) {
    print('DEBUG: Updating Next Service Due for $assetId: $nextServiceDue');
    
    final currentState = _productStates[assetId] ?? ProductState();
    _productStates[assetId] = currentState.copyWith(
      nextServiceDue: nextServiceDue,
      lastUpdated: DateTime.now(),
    );
    
    // Invalidate the provider to trigger rebuild
    ref.invalidate(productStateByIdProvider(assetId));
    
    print('DEBUG: Updated Next Service Due state for $assetId');
  };
});

// Helper provider to update availability status
final updateAvailabilityStatusProvider = Provider((ref) {
  return (String assetId, String? availabilityStatus) {
    print('DEBUG: Updating Availability Status for $assetId: $availabilityStatus');
    
    final currentState = _productStates[assetId] ?? ProductState();
    _productStates[assetId] = currentState.copyWith(
      availabilityStatus: availabilityStatus,
      lastUpdated: DateTime.now(),
    );
    
    // Invalidate the provider to trigger rebuild
    ref.invalidate(productStateByIdProvider(assetId));
    
    print('DEBUG: Updated Availability Status state for $assetId');
  };
});

// Helper provider to update complete product state
final updateProductStateProvider = Provider((ref) {
  return (String assetId, {String? nextServiceDue, String? availabilityStatus}) {
    print('DEBUG: Updating Product State for $assetId');
    print('  - Next Service Due: $nextServiceDue');
    print('  - Availability Status: $availabilityStatus');
    
    final currentState = _productStates[assetId] ?? ProductState();
    _productStates[assetId] = currentState.copyWith(
      nextServiceDue: nextServiceDue,
      availabilityStatus: availabilityStatus,
      lastUpdated: DateTime.now(),
    );
    
    // Invalidate the provider to trigger rebuild
    ref.invalidate(productStateByIdProvider(assetId));
    
    print('DEBUG: Updated complete Product State for $assetId');
  };
});