import 'package:flutter/material.dart';
import 'package:inventory/widgets/pagination_controls.dart';

/// Simple pagination widget that can be used independently without a table
/// Perfect for paginating any list of data
class SimplePagination extends StatefulWidget {
  final List<dynamic> data;
  final int initialRowsPerPage;
  final List<int> rowsPerPageOptions;
  final Widget Function(List<dynamic> pageItems) itemBuilder;
  final Widget? emptyWidget;

  const SimplePagination({
    super.key,
    required this.data,
    this.initialRowsPerPage = 10,
    this.rowsPerPageOptions = const [5, 7, 10, 15, 20],
    required this.itemBuilder,
    this.emptyWidget,
  });

  @override
  State<SimplePagination> createState() => _SimplePaginationState();
}

class _SimplePaginationState extends State<SimplePagination> {
  late PaginationState _paginationState;

  @override
  void initState() {
    super.initState();
    _paginationState = PaginationState(
      currentPage: 1,
      rowsPerPage: widget.initialRowsPerPage,
      totalItems: widget.data.length,
    );
  }

  @override
  void didUpdateWidget(SimplePagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      setState(() {
        _paginationState = _paginationState.copyWith(
          totalItems: widget.data.length,
        );
      });
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _paginationState = _paginationState.copyWith(currentPage: page);
    });
  }

  void _onRowsPerPageChanged(int rowsPerPage) {
    setState(() {
      // Calculate which page we should be on after changing rows per page
      final currentFirstItem = (_paginationState.currentPage - 1) * _paginationState.rowsPerPage;
      final newPage = (currentFirstItem / rowsPerPage).floor() + 1;
      
      _paginationState = _paginationState.copyWith(
        currentPage: newPage,
        rowsPerPage: rowsPerPage,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return widget.emptyWidget ?? const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      );
    }

    final currentPageItems = _paginationState.getPageItems(widget.data);

    return Column(
      children: [
        // Content
        Expanded(
          child: widget.itemBuilder(currentPageItems),
        ),
        
        // Pagination controls
        PaginationControls(
          currentPage: _paginationState.currentPage,
          totalPages: _paginationState.totalPages,
          rowsPerPage: _paginationState.rowsPerPage,
          totalItems: _paginationState.totalItems,
          rowsPerPageOptions: widget.rowsPerPageOptions,
          onPageChanged: _onPageChanged,
          onRowsPerPageChanged: _onRowsPerPageChanged,
        ),
      ],
    );
  }
}

/// Example usage:
/// 
/// SimplePagination(
///   data: myDataList,
///   initialRowsPerPage: 7,
///   itemBuilder: (pageItems) {
///     return ListView.builder(
///       itemCount: pageItems.length,
///       itemBuilder: (context, index) {
///         final item = pageItems[index];
///         return ListTile(
///           title: Text(item.name),
///           subtitle: Text(item.description),
///         );
///       },
///     );
///   },
/// )