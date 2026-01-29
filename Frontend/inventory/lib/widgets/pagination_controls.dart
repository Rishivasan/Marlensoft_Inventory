import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Centralized pagination controls widget that can be used across multiple areas
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int rowsPerPage;
  final int totalItems;
  final List<int> rowsPerPageOptions;
  final Function(int page) onPageChanged;
  final Function(int rowsPerPage) onRowsPerPageChanged;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.rowsPerPage,
    required this.totalItems,
    this.rowsPerPageOptions = const [5, 7, 10, 15, 20],
    required this.onPageChanged,
    required this.onRowsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffD9D9D9))),
      ),
      child: Row(
        children: [
          // Left side - Show entries dropdown
          _buildShowEntriesSection(),
          
          // Center - Page numbers
          Expanded(
            child: Center(
              child: totalPages > 1 
                  ? _buildPageNumbers()
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowEntriesSection() {
    return Row(
      children: [
        const Text(
          "Show", 
          style: TextStyle(
            fontSize: 13, 
            color: Color(0xff6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffD1D5DB)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<int>(
            value: rowsPerPage,
            underline: const SizedBox(),
            isDense: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: Color(0xff6B7280),
            ),
            style: const TextStyle(
              fontSize: 13, 
              color: Color(0xff374151),
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              if (value != null) {
                onRowsPerPageChanged(value);
              }
            },
            items: rowsPerPageOptions.map((e) => DropdownMenuItem(
              value: e, 
              child: Text("$e")
            )).toList(),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "entries", 
          style: TextStyle(
            fontSize: 13, 
            color: Color(0xff6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildPageNumbers() {
    List<Widget> pageButtons = [];
    
    // Previous button
    pageButtons.add(
      _buildPageButton(
        icon: Icons.chevron_left,
        onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        isEnabled: currentPage > 1,
      ),
    );
    
    // Calculate which page numbers to show
    List<int> pagesToShow = _calculatePagesToShow();
    
    for (int i = 0; i < pagesToShow.length; i++) {
      int pageNum = pagesToShow[i];
      
      // Add ellipsis if there's a gap between consecutive pages
      if (i > 0 && pagesToShow[i] - pagesToShow[i-1] > 1) {
        pageButtons.add(_buildEllipsis());
      }
      
      pageButtons.add(
        _buildPageButton(
          text: pageNum.toString(),
          onPressed: () => onPageChanged(pageNum),
          isActive: pageNum == currentPage,
          isEnabled: true,
        ),
      );
    }
    
    // Next button
    pageButtons.add(
      _buildPageButton(
        icon: Icons.chevron_right,
        onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        isEnabled: currentPage < totalPages,
      ),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pageButtons,
    );
  }

  List<int> _calculatePagesToShow() {
    List<int> pages = [];
    
    // Debug output
    print('DEBUG: Pagination - currentPage: $currentPage, totalPages: $totalPages');
    
    if (totalPages <= 5) {
      // Show all pages if 5 or fewer
      print('DEBUG: Showing all pages (≤5)');
      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      // Smart pagination logic based on current page position (6+ pages)
      if (currentPage <= 3) {
        // Near the beginning: 1 2 3 4 ... last
        print('DEBUG: Near beginning - showing 1-4 ... last');
        for (int i = 1; i <= 4; i++) {
          pages.add(i);
        }
        pages.add(totalPages);
      } else if (currentPage >= totalPages - 2) {
        // Near the end: 1 ... (last-3) (last-2) (last-1) last
        print('DEBUG: Near end - showing 1 ... last-3 to last');
        pages.add(1);
        for (int i = totalPages - 3; i <= totalPages; i++) {
          pages.add(i);
        }
      } else {
        // In the middle: 1 ... (current-1) current (current+1) ... last
        print('DEBUG: In middle - showing 1 ... current±1 ... last');
        pages.add(1);
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          pages.add(i);
        }
        pages.add(totalPages);
      }
    }
    
    print('DEBUG: Pages to show: $pages');
    return pages;
  }

  Widget _buildPageButton({
    String? text,
    IconData? icon,
    VoidCallback? onPressed,
    bool isActive = false,
    bool isEnabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xff3B82F6) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: text != null
                  ? Text(
                      text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isActive 
                            ? Colors.white 
                            : isEnabled 
                                ? const Color(0xff374151)
                                : const Color(0xff9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 18,
                      color: isEnabled 
                          ? const Color(0xff6B7280) 
                          : const Color(0xff9CA3AF),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      width: 36,
      height: 36,
      child: const Center(
        child: Text(
          "...",
          style: TextStyle(
            fontSize: 14,
            color: Color(0xff6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Helper class to manage pagination state
class PaginationState {
  final int currentPage;
  final int rowsPerPage;
  final int totalItems;

  const PaginationState({
    required this.currentPage,
    required this.rowsPerPage,
    required this.totalItems,
  });

  int get totalPages => (totalItems / rowsPerPage).ceil();
  int get firstRowIndex => (currentPage - 1) * rowsPerPage;
  int get lastRowIndex => math.min(firstRowIndex + rowsPerPage, totalItems);
  
  PaginationState copyWith({
    int? currentPage,
    int? rowsPerPage,
    int? totalItems,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      rowsPerPage: rowsPerPage ?? this.rowsPerPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  /// Get the items for the current page
  List<T> getPageItems<T>(List<T> allItems) {
    final start = firstRowIndex;
    final end = math.min(start + rowsPerPage, allItems.length);
    return allItems.sublist(start, end);
  }
}