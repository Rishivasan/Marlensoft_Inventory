import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inventory/providers/pagination_provider.dart';

class PaginationBar extends ConsumerWidget {
  final VoidCallback onPageChanged;

  const PaginationBar({
    super.key,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginationState = ref.watch(paginationProvider);
    final currentPage = paginationState.currentPage;
    final totalPages = paginationState.totalPages;
    final pageSize = paginationState.pageSize;

    // Generate page numbers to display
    List<int> getPageNumbers() {
      if (totalPages <= 7) {
        return List.generate(totalPages, (i) => i + 1);
      }

      // Show first page, current page with neighbors, and last page
      final pages = <int>{};
      pages.add(1);
      
      // Add current page and neighbors
      for (int i = currentPage - 1; i <= currentPage + 1; i++) {
        if (i > 1 && i < totalPages) {
          pages.add(i);
        }
      }
      
      pages.add(totalPages);
      return pages.toList()..sort();
    }

    final pageNumbers = getPageNumbers();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Page size selector
          Row(
            children: [
              const Text(
                'Show',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButton<int>(
                  value: pageSize,
                  underline: const SizedBox(),
                  isDense: true,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  items: [10, 20, 30, 50].map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text('$size'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(paginationProvider.notifier).setPageSize(value);
                      onPageChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'entries',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),

          // Center: Page navigation
          if (totalPages > 0)
            Row(
              children: [
                // Previous button
                IconButton(
                  onPressed: currentPage > 1
                      ? () {
                          ref.read(paginationProvider.notifier).previousPage();
                          onPageChanged();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  color: currentPage > 1 ? Colors.black : Colors.grey,
                ),

                // Page numbers
                ...pageNumbers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final page = entry.value;
                  final isActive = page == currentPage;

                  // Show ellipsis if there's a gap
                  final showEllipsisBefore = index > 0 && 
                      page - pageNumbers[index - 1] > 1;

                  return Row(
                    children: [
                      if (showEllipsisBefore)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text('...', style: TextStyle(color: Colors.grey)),
                        ),
                      InkWell(
                        onTap: () {
                          ref.read(paginationProvider.notifier).setPage(page);
                          onPageChanged();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF0066CC)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFF0066CC)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            '$page',
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive ? Colors.white : Colors.black,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),

                // Next button
                IconButton(
                  onPressed: currentPage < totalPages
                      ? () {
                          ref.read(paginationProvider.notifier).nextPage();
                          onPageChanged();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  color: currentPage < totalPages ? Colors.black : Colors.grey,
                ),
              ],
            ),

          // Right: Page info
          if (totalPages > 0)
            Text(
              'Page $currentPage of $totalPages',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
        ],
      ),
    );
  }
}
