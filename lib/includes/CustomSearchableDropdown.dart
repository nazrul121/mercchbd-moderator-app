import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class CustomSearchableDropdown<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabelBuilder;
  final Function(T?) onSelected;
  final bool enabled;

  const CustomSearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.itemLabelBuilder,
    required this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      enabled: enabled,
      items: (String filter, loadProps) {
        if (filter.isEmpty) return items;
        return items.where((item) =>
            itemLabelBuilder(item).toLowerCase().contains(filter.toLowerCase())
        ).toList();
      },
      selectedItem: selectedItem,
      itemAsString: itemLabelBuilder,
      compareFn: (item, selectedItem) => item == selectedItem,
      onChanged: onSelected,

      popupProps: PopupProps.menu(
        showSearchBox: true,
        // OPTIONAL: Add a small delay to prevent rapid-fire rebuilding
        searchDelay: const Duration(milliseconds: 200),
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Search $label...",
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        constraints: const BoxConstraints(maxHeight: 300),
      ),

      // Styling the main field
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          filled: !enabled,
          fillColor: enabled ? Colors.transparent : Colors.grey.shade100,
        ),
      ),
    );
  }
}