import 'package:flutter/material.dart';

class SearchableDropdown extends StatefulWidget {
  final String? value;
  final List<Map<String, dynamic>> items;
  final String hintText;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;

  const SearchableDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.hintText,
    required this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<SearchableDropdown> createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(SearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered items when widget items change
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDropdownOpen = false;
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    // Reset filtered items to show all items when opening
    _filteredItems = widget.items;
    _searchController.clear();
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color.fromRGBO(210, 210, 210, 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: const TextStyle(fontSize: 12),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color.fromRGBO(210, 210, 210, 1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 154, 1)),
                        ),
                      ),
                      style: const TextStyle(fontSize: 12),
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            // Show all items when search is empty
                            _filteredItems = widget.items;
                          } else {
                            // Filter items based on search
                            _filteredItems = widget.items
                                .where((item) => item['name']
                                    .toString()
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          }
                        });
                        // Rebuild overlay
                        _overlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  // Items list
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No items found',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = _filteredItems[index];
                              final isSelected = widget.value == item['id'].toString();
                              
                              return InkWell(
                                onTap: () {
                                  widget.onChanged(item['id'].toString());
                                  _searchController.clear();
                                  _filteredItems = widget.items;
                                  _removeOverlay();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  color: isSelected ? const Color(0xFFE3F2FD) : null,
                                  child: Text(
                                    item['name'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isSelected ? const Color(0xff00599A) : Colors.black,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getSelectedItemName() {
    if (widget.value == null) return '';
    final selectedItem = widget.items.firstWhere(
      (item) => item['id'].toString() == widget.value,
      orElse: () => {'name': ''},
    );
    return selectedItem['name'];
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isDropdownOpen 
                  ? const Color.fromRGBO(0, 89, 154, 1) 
                  : const Color.fromRGBO(210, 210, 210, 1),
              width: _isDropdownOpen ? 1.2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.value == null ? widget.hintText : _getSelectedItemName(),
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.value == null 
                        ? const Color.fromRGBO(144, 144, 144, 1) 
                        : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: const Color.fromRGBO(144, 144, 144, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
