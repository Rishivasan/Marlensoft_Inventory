import 'dart:math' as math;
import 'package:flutter/material.dart';

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
  static const _defaultRowsPerPageOptions = [5, 10, 15, 20];
  
  late int _rowsPerPage;
  int _firstRowIndex = 0;
  Set<T> _selectedItems = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _rowsPerPage = widget.rowsPerPage;
  }

  // Pagination calculations
  int get _rowCount => widget.data.length;
  int get _maxFirstRowIndex => math.max(0, _rowCount - _rowsPerPage);
  bool get _canGoNext => _firstRowIndex < _maxFirstRowIndex;
  bool get _canGoPrev => _firstRowIndex > 0;

  int _clampIndex(int index) {
    return math.max(0, math.min(index, _maxFirstRowIndex));
  }

  // Navigation methods
  void _goNext() {
    if (!_canGoNext) return;
    setState(() {
      _firstRowIndex = math.min(_firstRowIndex + _rowsPerPage, _maxFirstRowIndex);
    });
  }

  void _goPrev() {
    if (!_canGoPrev) return;
    setState(() {
      _firstRowIndex = math.max(0, _firstRowIndex - _rowsPerPage);
    });
  }

  void _goToFirstPage() {
    setState(() {
      _firstRowIndex = 0;
    });
  }

  void _goToLastPage() {
    setState(() {
      _firstRowIndex = _maxFirstRowIndex;
    });
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
    final end = math.min(_firstRowIndex + _rowsPerPage, _rowCount);
    return widget.data.sublist(_firstRowIndex, end);
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
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (_rowCount / _rowsPerPage).ceil();
    final currentPage = (_firstRowIndex / _rowsPerPage).floor() + 1;
    
    final options = {..._defaultRowsPerPageOptions, _rowsPerPage}.toList()..sort();

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xffD9D9D9))),
      ),
      child: Row(
        children: [
          // Left side - Show entries dropdown
          Row(
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
                  value: _rowsPerPage,
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
                    if (value == null) return;
                    setState(() {
                      final page = _firstRowIndex ~/ _rowsPerPage;
                      _rowsPerPage = value;
                      _firstRowIndex = page * _rowsPerPage;
                      _firstRowIndex = _clampIndex(_firstRowIndex);
                    });
                  },
                  items: options.map((e) => DropdownMenuItem(
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
          ),
          
          // Center - Page numbers
          Expanded(
            child: Center(
              child: totalPages > 1 
                  ? _buildPageNumbers(currentPage, totalPages)
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers(int currentPage, int totalPages) {
    List<Widget> pageButtons = [];
    
    // Previous button
    pageButtons.add(
      _buildPageButton(
        icon: Icons.chevron_left,
        onPressed: _canGoPrev ? _goPrev : null,
        isEnabled: _canGoPrev,
      ),
    );
    
    // Calculate which page numbers to show
    List<int> pagesToShow = _calculatePagesToShow(currentPage, totalPages);
    
    for (int i = 0; i < pagesToShow.length; i++) {
      int pageNum = pagesToShow[i];
      
      // Add ellipsis if there's a gap
      if (i > 0 && pagesToShow[i] - pagesToShow[i-1] > 1) {
        pageButtons.add(_buildEllipsis());
      }
      
      pageButtons.add(
        _buildPageButton(
          text: pageNum.toString(),
          onPressed: () => _goToPage(pageNum),
          isActive: pageNum == currentPage,
          isEnabled: true,
        ),
      );
    }
    
    // Next button
    pageButtons.add(
      _buildPageButton(
        icon: Icons.chevron_right,
        onPressed: _canGoNext ? _goNext : null,
        isEnabled: _canGoNext,
      ),
    );
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: pageButtons,
    );
  }

  List<int> _calculatePagesToShow(int currentPage, int totalPages) {
    List<int> pages = [];
    
    if (totalPages <= 7) {
      // Show all pages if 7 or fewer
      for (int i = 1; i <= totalPages; i++) {
        pages.add(i);
      }
    } else {
      // Always show first page
      pages.add(1);
      
      if (currentPage <= 4) {
        // Show 1, 2, 3, 4, 5, ..., last
        for (int i = 2; i <= 5; i++) {
          pages.add(i);
        }
        pages.add(totalPages);
      } else if (currentPage >= totalPages - 3) {
        // Show 1, ..., last-4, last-3, last-2, last-1, last
        for (int i = totalPages - 4; i <= totalPages; i++) {
          pages.add(i);
        }
      } else {
        // Show 1, ..., current-1, current, current+1, ..., last
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          pages.add(i);
        }
        pages.add(totalPages);
      }
    }
    
    return pages.toSet().toList()..sort();
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

  void _goToPage(int page) {
    setState(() {
      _firstRowIndex = (page - 1) * _rowsPerPage;
      _firstRowIndex = _clampIndex(_firstRowIndex);
    });
  }
}