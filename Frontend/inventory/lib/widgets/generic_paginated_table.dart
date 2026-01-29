import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:inventory/widgets/pagination_controls.dart';

/// A simple, clean paginated table widget
class GenericPaginatedTable<T> extends StatefulWidget {
  final List<T> data;
  final List<Widget> Function(T item, bool isSelected, Function(bool?) onChanged) rowBuilder;
  final List<Widget> headers;
  final int rowsPerPage;
  final double? minWidth;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final bool showCheckboxColumn;

  const GenericPaginatedTable({
    super.key,
    required this.data,
    required this.rowBuilder,
    required this.headers,
    this.rowsPerPage = 10,
    this.minWidth,
    this.onSelectionChanged,
    this.showCheckboxColumn = true,
  });

  @override
  State<GenericPaginatedTable<T>> createState() => _GenericPaginatedTableState<T>();
}

class _GenericPaginatedTableState<T> extends State<GenericPaginatedTable<T>> {
  late PaginationState _paginationState;
  Set<T> _selectedItems = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _paginationState = PaginationState(
      currentPage: 1,
      rowsPerPage: widget.rowsPerPage,
      totalItems: widget.data.length,
    );
  }

  @override
  void didUpdateWidget(GenericPaginatedTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      setState(() {
        _paginationState = _paginationState.copyWith(
          totalItems: widget.data.length,
        );
      });
    }
  }

  // Selection methods
  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedItems = Set.from(_getCurrentPageItems());
      } else {
        _selectedItems.clear();
      }
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  void _toggleItemSelection(T item, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedItems.add(item);
      } else {
        _selectedItems.remove(item);
      }
      
      // Update select all state
      final currentPageItems = _getCurrentPageItems();
      _selectAll = currentPageItems.every((item) => _selectedItems.contains(item));
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  List<T> _getCurrentPageItems() {
    return _paginationState.getPageItems(widget.data);
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
    final currentPageItems = _getCurrentPageItems();
    final ScrollController horizontalScrollController = ScrollController();

    return Column(
      children: [
        // Table content
        Expanded(
          child: Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            thickness: 4.0,
            radius: const Radius.circular(4.0),
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: widget.minWidth ?? 1800,
                child: Column(
                  children: [
                    // Header
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                      ),
                      child: Row(
                        children: [
                          if (widget.showCheckboxColumn)
                            Container(
                              width: 60,
                              alignment: Alignment.center,
                              child: Transform.scale(
                                scale: 0.7,
                                child: Checkbox(
                                  value: _selectAll,
                                  onChanged: _toggleSelectAll,
                                ),
                              ),
                            ),
                          ...widget.headers,
                        ],
                      ),
                    ),
                    // Data rows
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: currentPageItems.map((item) {
                            final isSelected = _selectedItems.contains(item);
                            
                            return Container(
                              height: 54,
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: Row(
                                children: [
                                  if (widget.showCheckboxColumn)
                                    Container(
                                      width: 60,
                                      alignment: Alignment.center,
                                      child: Transform.scale(
                                        scale: 0.7,
                                        child: Checkbox(
                                          value: isSelected,
                                          onChanged: (value) => _toggleItemSelection(item, value),
                                        ),
                                      ),
                                    ),
                                  ...widget.rowBuilder(item, isSelected, (value) => _toggleItemSelection(item, value)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Pagination controls
        PaginationControls(
          currentPage: _paginationState.currentPage,
          totalPages: _paginationState.totalPages,
          rowsPerPage: _paginationState.rowsPerPage,
          totalItems: _paginationState.totalItems,
          onPageChanged: _onPageChanged,
          onRowsPerPageChanged: _onRowsPerPageChanged,
        ),
      ],
    );
  }
}