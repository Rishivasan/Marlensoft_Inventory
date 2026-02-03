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
  final Function(T item)? onRowTap; // Add row tap callback

  const GenericPaginatedTable({
    super.key,
    required this.data,
    required this.rowBuilder,
    required this.headers,
    this.rowsPerPage = 10,
    this.minWidth,
    this.onSelectionChanged,
    this.showCheckboxColumn = true,
    this.onRowTap, // Add to constructor
  });

  @override
  State<GenericPaginatedTable<T>> createState() => _GenericPaginatedTableState<T>();
}

class _GenericPaginatedTableState<T> extends State<GenericPaginatedTable<T>> {
  late PaginationState _paginationState;
  Set<T> _selectedItems = {};

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
  void didUpdateWidget(GenericPaginatedTable<T> oldWidget) {     //covarient try to use 
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      setState(() {
        _paginationState = _paginationState.copyWith(
          totalItems: widget.data.length,
        );
        
        // Remove any selected items that are no longer in the dataset
        _selectedItems = _selectedItems.where((item) => widget.data.contains(item)).toSet();
      });
    } else {
      // Data might have changed due to sorting/filtering
      setState(() {
        // Remove any selected items that are no longer in the dataset
        _selectedItems = _selectedItems.where((item) => widget.data.contains(item)).toSet();
      });
    }
  }

  // Selection methods
  void _toggleSelectAll(bool? value) {
    setState(() {
      if (value == true) {
        // Select ALL items in the entire dataset, not just current page
        _selectedItems = Set.from(widget.data);
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
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  // Helper method to determine checkbox state
  bool? _getSelectAllCheckboxValue() {
    if (_selectedItems.isEmpty) {
      return false; // Nothing selected
    } else if (widget.data.every((item) => _selectedItems.contains(item))) {
      return true; // Everything selected
    } else {
      return null; // Some items selected (indeterminate state)
    }
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
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                              value: _getSelectAllCheckboxValue(),
                              tristate: true, // Enable indeterminate state
                              onChanged: _toggleSelectAll,
                              activeColor: const Color(0xFF00599A),
                              checkColor: Colors.white,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                        
                        return InkWell(
                          onTap: widget.onRowTap != null ? () => widget.onRowTap!(item) : null,
                          hoverColor: Colors.grey.shade100,
                          child: Container(
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
                                        activeColor: const Color(0xFF00599A),
                                        checkColor: Colors.white,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ),
                                ...widget.rowBuilder(item, isSelected, (value) => _toggleItemSelection(item, value)),
                              ],
                            ),
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