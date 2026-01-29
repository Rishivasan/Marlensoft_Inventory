import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/providers/master_list_provider.dart';
import 'package:inventory/providers/sorting_provider.dart';
import 'package:inventory/utils/sorting_utils.dart';

// Provider to manage selected items
final selectedItemsProvider = NotifierProvider<SelectedItemsNotifier, Set<String>>(() {
  return SelectedItemsNotifier();
});

// Provider to manage select all state
final selectAllProvider = NotifierProvider<SelectAllNotifier, bool>(() {
  return SelectAllNotifier();
});

// Provider for sorted master list
final sortedMasterListProvider = Provider<AsyncValue<List<MasterListModel>>>((ref) {
  final masterListAsync = ref.watch(masterListProvider);
  final sortState = ref.watch(sortProvider);

  return masterListAsync.when(
    data: (items) {
      final sortedItems = SortingUtils.sortMasterList(
        items,
        sortState.sortColumn,
        sortState.direction,
      );
      return AsyncValue.data(sortedItems);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class SelectedItemsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return <String>{};
  }

  void toggleItem(String itemId) {
    if (state.contains(itemId)) {
      state = Set.from(state)..remove(itemId);
    } else {
      state = Set.from(state)..add(itemId);
    }
  }

  void selectAll(List<MasterListModel> items) {
    state = items.map((item) => item.refId).toSet();
  }

  void clearAll() {
    state = <String>{};
  }

  bool isSelected(String itemId) {
    return state.contains(itemId);
  }

  bool get hasSelection => state.isNotEmpty;
}

class SelectAllNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void toggle() {
    state = !state;
  }

  void set(bool value) {
    state = value;
  }
}