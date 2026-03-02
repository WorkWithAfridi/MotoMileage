import 'package:flutter/material.dart';

class AppDropdownFormField<T> extends StatelessWidget {
  const AppDropdownFormField({
    super.key,
    required this.items,
    required this.onChanged,
    this.initialValue,
    this.decoration,
    this.validator,
    this.selectedItemBuilder,
    this.autovalidateMode,
    this.menuMaxHeight,
    this.itemHeight = 52,
    this.isExpanded = true,
    this.isDense = true,
  });

  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final T? initialValue;
  final InputDecoration? decoration;
  final FormFieldValidator<T>? validator;
  final DropdownButtonBuilder? selectedItemBuilder;
  final AutovalidateMode? autovalidateMode;
  final double? menuMaxHeight;
  final double itemHeight;
  final bool isExpanded;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<T>(
      initialValue: initialValue,
      items: items,
      onChanged: onChanged,
      decoration: decoration,
      validator: validator,
      selectedItemBuilder: selectedItemBuilder,
      autovalidateMode: autovalidateMode,
      isExpanded: isExpanded,
      isDense: isDense,
      itemHeight: itemHeight,
      icon: const Icon(Icons.expand_more_rounded),
      iconEnabledColor: colorScheme.primary,
      iconDisabledColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      dropdownColor: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLowest,
      elevation: isDark ? 2 : 6,
      menuMaxHeight: menuMaxHeight ?? 340,
      alignment: AlignmentDirectional.centerStart,
      borderRadius: BorderRadius.circular(18),
    );
  }
}
