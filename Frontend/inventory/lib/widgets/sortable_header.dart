import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inventory/providers/sorting_provider.dart';

class SortableHeader extends ConsumerWidget {
  final String title;
  final String sortKey;
  final double width;
  final NotifierProvider<SortNotifier, SortState> sortProvider;
  final VoidCallback? onTap;

  const SortableHeader({
    super.key,
    required this.title,
    required this.sortKey,
    required this.width,
    required this.sortProvider,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151), // Always gray, no highlight
              ),
            ),
          ),
          // Sort icon (clickable only)
          InkWell(
            onTap: () {
              ref.read(sortProvider.notifier).sortBy(sortKey);
              onTap?.call();
            },
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(2), // Small padding for better tap target
              child: _buildSortIcon(sortState, isCurrentSort),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortIcon(SortState sortState, bool isCurrentSort) {
    if (!isCurrentSort || sortState.direction == SortDirection.none) {
      // Default arrow down icon (gray)
      return SvgPicture.asset(
        "assets/images/Icon_arrowdown.svg", 
        width: 14, 
        height: 14, 
        colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
      );
    }

    // Active sort - show direction with blue color
    switch (sortState.direction) {
      case SortDirection.ascending:
        // Ascending: blue down arrow
        return SvgPicture.asset(
          "assets/images/Icon_arrowdown.svg", 
          width: 14, 
          height: 14, 
          colorFilter: const ColorFilter.mode(Color(0xFF00599A), BlendMode.srcIn),
        );
      case SortDirection.descending:
        // Descending: blue up arrow (rotated)
        return Transform.rotate(
          angle: 3.14159, // 180 degrees - arrow up
          child: SvgPicture.asset(
            "assets/images/Icon_arrowdown.svg", 
            width: 14, 
            height: 14, 
            colorFilter: const ColorFilter.mode(Color(0xFF00599A), BlendMode.srcIn),
          ),
        );
      case SortDirection.none:
        return SvgPicture.asset(
          "assets/images/Icon_arrowdown.svg", 
          width: 14, 
          height: 14, 
          colorFilter: const ColorFilter.mode(Color(0xFF9CA3AF), BlendMode.srcIn),
        );
    }
  }
}