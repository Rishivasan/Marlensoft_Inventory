import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/model/master_list_model.dart';
import 'package:inventory/model/pagination_model.dart';
import 'package:inventory/services/master_list_service.dart';
import 'package:inventory/providers/pagination_provider.dart';

final masterListServiceProvider = Provider((ref) => MasterListService());

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
      
      // Populate NextServiceProvider with the fetched next service dates
      // This is done in a separate microtask to avoid issues during build
      Future.microtask(() {
        try {
          // We can't access context here, so we'll need to handle this differently
          // The NextServiceProvider will be updated when items are displayed
          print('DEBUG: MasterListNotifier - Next service dates will be populated when items are displayed');
        } catch (e) {
          print('DEBUG: MasterListNotifier - Error in microtask: $e');
        }
      });
      
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

// Paginated Master List Provider
class PaginatedMasterListNotifier extends AsyncNotifier<PaginationModel<MasterListModel>> {
  @override
  Future<PaginationModel<MasterListModel>> build() async {
    // Watch pagination state to trigger rebuild when it changes
    final paginationState = ref.watch(paginationProvider);
    return await loadPaginatedData(
      pageNumber: paginationState.currentPage,
      pageSize: paginationState.pageSize,
      searchText: paginationState.searchText,
      sortColumn: paginationState.sortColumn,
      sortDirection: paginationState.sortDirection,
    );
  }

  Future<PaginationModel<MasterListModel>> loadPaginatedData({
    required int pageNumber,
    required int pageSize,
    String? searchText,
    String? sortColumn,
    String? sortDirection,
  }) async {
    try {
      print('DEBUG: PaginatedMasterListNotifier - Loading page $pageNumber with size $pageSize, sort: $sortColumn $sortDirection');
      final service = MasterListService();
      final paginationModel = await service.getMasterListPaginated(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchText: searchText,
        sortColumn: sortColumn,
        sortDirection: sortDirection,
      );

      // Update total pages in pagination provider
      ref.read(paginationProvider.notifier).setTotalPages(paginationModel.totalPages);

      print('DEBUG: PaginatedMasterListNotifier - Loaded ${paginationModel.items.length} items');
      return paginationModel;
    } catch (error, stackTrace) {
      print('DEBUG: PaginatedMasterListNotifier - Error loading: $error');
      rethrow;
    }
  }

  Future<void> refresh() async {
    print('DEBUG: PaginatedMasterListNotifier - Refreshing paginated data');
    state = const AsyncValue.loading();
    
    final paginationState = ref.read(paginationProvider);
    try {
      final paginationModel = await loadPaginatedData(
        pageNumber: paginationState.currentPage,
        pageSize: paginationState.pageSize,
        searchText: paginationState.searchText,
        sortColumn: paginationState.sortColumn,
        sortDirection: paginationState.sortDirection,
      );
      state = AsyncValue.data(paginationModel);
      print('DEBUG: PaginatedMasterListNotifier - Refresh complete');
    } catch (error, stackTrace) {
      print('DEBUG: PaginatedMasterListNotifier - Refresh failed: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final paginatedMasterListProvider = 
    AsyncNotifierProvider<PaginatedMasterListNotifier, PaginationModel<MasterListModel>>(() {
  return PaginatedMasterListNotifier();
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

// Helper provider to trigger paginated refresh
final refreshPaginatedMasterListProvider = Provider((ref) {
  return () async {
    print('DEBUG: Triggering paginated master list refresh');
    await ref.read(paginatedMasterListProvider.notifier).refresh();
  };
});
