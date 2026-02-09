import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/providers/sorting_provider.dart';

class TableHeaderHelper {
  // Create a sortable header widget
  static Widget createSortableHeader({
    required String title,
    required String sortKey,
    required double width,
    required NotifierProvider<SortNotifier, SortState> sortProvider,
    required WidgetRef ref,
    VoidCallback? onTap,
  }) {
    final sortState = ref.watch(sortProvider);
    final isCurrentSort = sortState.sortColumn == sortKey;
    
    return Container(
      width: width,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Field name (non-clickable)
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
          // Filter icon (non-clickable)
          SvgPicture.asset(
            "assets/images/Icon_filter.svg", 
            width: 14, 
            height: 14, 
            colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
          ),
          const SizedBox(width: 1),
          // Sort icon (clickable only)
          InkWell(
            onTap: () {
              ref.read(sortProvider.notifier).sortBy(sortKey);
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: _buildSortIcon(sortState, isCurrentSort),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildSortIcon(SortState sortState, bool isCurrentSort) {
    // Show gray arrow for non-active columns
    if (!isCurrentSort) {
      return SvgPicture.asset(
        "assets/images/Icon_arrowdown.svg", 
        width: 14, 
        height: 14, 
        colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
      );
    }

    // Active sort - show direction with blue color
    if (sortState.direction == SortDirection.ascending) {
      // Ascending: blue up arrow (rotated)
      return Transform.rotate(
        angle: 3.14159, // 180 degrees - arrow up
        child: SvgPicture.asset(
          "assets/images/Icon_arrowdown.svg", 
          width: 14, 
          height: 14, 
          colorFilter: const ColorFilter.mode(Color(0xFF00599A), BlendMode.srcIn),
        ),
      );
    } else {
      // Descending: blue down arrow
      return SvgPicture.asset(
        "assets/images/Icon_arrowdown.svg", 
        width: 14, 
        height: 14, 
        colorFilter: const ColorFilter.mode(Color(0xFF00599A), BlendMode.srcIn),
      );
    }
  }
}