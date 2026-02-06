import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationState {
  final int currentPage;
  final int pageSize;
  final int totalPages;
  final String searchText;

  PaginationState({
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalPages = 0,
    this.searchText = '',
  });

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalPages,
    String? searchText,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalPages: totalPages ?? this.totalPages,
      searchText: searchText ?? this.searchText,
    );
  }
}

class PaginationNotifier extends Notifier<PaginationState> {
  @override
  PaginationState build() {
    return PaginationState();
  }

  void setPage(int page) {
    if (page >= 1 && page <= state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }

  void nextPage() {
    if (state.currentPage < state.totalPages) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 1) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void setPageSize(int size) {
    state = state.copyWith(
      pageSize: size,
      currentPage: 1, // Reset to first page when changing page size
    );
  }

  void setTotalPages(int total) {
    if (total == state.totalPages) {
      return;
    }
    state = state.copyWith(totalPages: total);
  }

  void setSearchText(String text) {
    state = state.copyWith(
      searchText: text,
      currentPage: 1, // Reset to first page when searching
    );
  }

  void reset() {
    state = PaginationState();
  }
}

final paginationProvider =
    NotifierProvider<PaginationNotifier, PaginationState>(() {
  return PaginationNotifier();
});
