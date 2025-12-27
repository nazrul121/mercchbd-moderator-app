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
      items: (filter, loadProps) => items,
      selectedItem: selectedItem,
      // Logic for how to display the item in the list
      itemAsString: itemLabelBuilder,
      // Logic for the search filter
      compareFn: (item, selectedItem) => item == selectedItem,
      onChanged: onSelected,

      // Styling the search box and dropdown
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Search $label...",
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        // This ensures the dropdown doesn't take infinite height
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