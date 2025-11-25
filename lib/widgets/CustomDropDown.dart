import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../theme/AppTheme.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<T>(
      value: value,
      decoration: InputDecoration(labelText: label),

      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down_rounded,
          color: AppTheme.primaryColor,
        ),
        iconSize: 28,
      ),

      isExpanded: true,

      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.secondaryColor),
        ),
      ),

      menuItemStyleData: const MenuItemStyleData(
        overlayColor:
        WidgetStatePropertyAll(AppTheme.secondaryColor),
      ),

      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item.value,
          child: DefaultTextStyle(
            style: AppTheme.subtitleText,  // ← estilo global del texto
            child: item.child,
          ),
        ),
      )
          .toList(),

      onChanged: onChanged,
      validator: validator,
    );
  }
}
