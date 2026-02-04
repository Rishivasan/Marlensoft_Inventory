import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/services/master_list_service.dart';

final masterListServiceProvider = Provider((ref) => MasterListService());

// Use AsyncNotifier for Riverpod 3.x
class MasterListNotifier extends AsyncNotifier<List<MasterListModel>> {
  @override
  Future<List<MasterListModel>> build() async {
    return await loadMasterList();
  }

  Future<List<MasterListModel>> loadMasterList() async {
    try {
      print('DEBUG: MasterListNotifier - Loading master list');
      final masterList = await MasterListService().getMasterList();
      print('DEBUG: MasterListNotifier - Loaded ${masterList.length} items');
      return masterList;
    } catch (error, stackTrace) {
      print('DEBUG: MasterListNotifier - Error loading: $error');
      rethrow;
    }
  }

  Future<void> refresh() async {
    print('DEBUG: MasterListNotifier - Refreshing master list');
    state = const AsyncValue.loading();
    try {
      final masterList = await loadMasterList();
      state = AsyncValue.data(masterList);
      print('DEBUG: MasterListNotifier - Refresh complete with ${masterList.length} items');
    } catch (error, stackTrace) {
      print('DEBUG: MasterListNotifier - Refresh failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Force immediate refresh without loading state
  Future<void> forceRefresh() async {
    try {
      print('DEBUG: MasterListNotifier - Force refreshing master list');
      final masterList = await loadMasterList();
      state = AsyncValue.data(masterList);
      print('DEBUG: MasterListNotifier - Force refresh complete with ${masterList.length} items');
    } catch (error, stackTrace) {
      print('DEBUG: MasterListNotifier - Force refresh failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final masterListProvider = AsyncNotifierProvider<MasterListNotifier, List<MasterListModel>>(() {
  return MasterListNotifier();
});

// Helper provider to trigger refresh
final refreshMasterListProvider = Provider((ref) {
  return () async {
    print('DEBUG: Triggering master list refresh');
    await ref.read(masterListProvider.notifier).refresh();
  };
});

// Helper provider to trigger force refresh (immediate, no loading state)
final forceRefreshMasterListProvider = Provider((ref) {
  return () async {
    print('DEBUG: Triggering master list force refresh');
    await ref.read(masterListProvider.notifier).forceRefresh();
  };
});
