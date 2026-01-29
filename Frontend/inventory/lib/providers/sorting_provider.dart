import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SortDirection { ascending, descending, none }

class SortState {
  final String? sortColumn;
  final SortDirection direction;

  const SortState({
    this.sortColumn,
    this.direction = SortDirection.none,
  });

  SortState copyWith({
    String? sortColumn,
    SortDirection? direction,
  }) {
    return SortState(
      sortColumn: sortColumn ?? this.sortColumn,
      direction: direction ?? this.direction,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SortState &&
        other.sortColumn == sortColumn &&
        other.direction == direction;
  }

  @override
  int get hashCode => sortColumn.hashCode ^ direction.hashCode;
}

class SortNotifier extends Notifier<SortState> {
  @override
  SortState build() {
    return const SortState();
  }

  void sortBy(String column) {
    final currentState = state;
    
    if (currentState.sortColumn == column) {
      // Same column clicked - cycle through directions
      switch (currentState.direction) {
        case SortDirection.none:
          state = SortState(sortColumn: column, direction: SortDirection.ascending);
          break;
        case SortDirection.ascending:
          state = SortState(sortColumn: column, direction: SortDirection.descending);
          break;
        case SortDirection.descending:
          state = const SortState(sortColumn: null, direction: SortDirection.none);
          break;
      }
    } else {
      // Different column clicked - start with ascending
      state = SortState(sortColumn: column, direction: SortDirection.ascending);
    }
  }

  void clearSort() {
    state = const SortState();
  }
}

// Provider for master list sorting state
final sortProvider = NotifierProvider<SortNotifier, SortState>(() {
  return SortNotifier();
});

// Provider for maintenance table sorting state
final maintenanceSortProvider = NotifierProvider<SortNotifier, SortState>(() {
  return SortNotifier();
});

// Provider for allocation table sorting state
final allocationSortProvider = NotifierProvider<SortNotifier, SortState>(() {
  return SortNotifier();
});