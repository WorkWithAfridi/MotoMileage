import 'package:flutter/material.dart';

import '../../localization/localized_text.dart';

class AppDropdownFormField<T> extends StatefulWidget {
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
  State<AppDropdownFormField<T>> createState() =>
      _AppDropdownFormFieldState<T>();
}

class _AppDropdownFormFieldState<T> extends State<AppDropdownFormField<T>> {
  final GlobalKey _fieldKey = GlobalKey();

  Future<void> _showPopupMenu(FormFieldState<T> field) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final fieldBox = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (fieldBox == null) return;

    final topLeft = fieldBox.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = fieldBox.localToGlobal(
      fieldBox.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );
    final position = RelativeRect.fromRect(
      Rect.fromPoints(topLeft, bottomRight).translate(0, 4),
      Offset.zero & overlay.size,
    );

    final selectedIndex = widget.items.indexWhere(
      (item) => item.value == field.value,
    );
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final resultIndex = await showMenu<int>(
      context: context,
      position: position,
      elevation: isDark ? 6 : 10,
      color: isDark
          ? colorScheme.surfaceContainerHigh
          : colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      constraints: BoxConstraints(
        minWidth: fieldBox.size.width,
        maxWidth: fieldBox.size.width,
        maxHeight: widget.menuMaxHeight ?? 340,
      ),
      initialValue: selectedIndex >= 0 ? selectedIndex : null,
      items: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        return PopupMenuItem<int>(
          value: index,
          enabled: item.enabled,
          child: item.child,
        );
      }),
    );

    if (resultIndex == null) return;

    final selectedValue = widget.items[resultIndex].value;
    field.didChange(selectedValue);
    widget.onChanged?.call(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    );

    return FormField<T>(
      initialValue: widget.initialValue,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      builder: (field) {
        final enabled = widget.onChanged != null && widget.items.isNotEmpty;
        final decoration = (widget.decoration ?? InputDecoration())
            .applyDefaults(InputDecorationTheme.of(context))
            .copyWith(
              suffixIcon: Icon(
                Icons.expand_more_rounded,
                color: enabled
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
              errorText: field.errorText,
            );
        final selectedItem = widget.items
            .where((item) => item.value == field.value)
            .cast<DropdownMenuItem<T>?>()
            .firstOrNull;
        final displayChild =
            selectedItem?.child ??
            (decoration.hintText != null
                ? TrText(
                    decoration.hintText!,
                    style: textStyle?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : const SizedBox.shrink());

        return InkWell(
          key: _fieldKey,
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? () => _showPopupMenu(field) : null,
          child: InputDecorator(
            isEmpty: selectedItem == null,
            isFocused: false,
            decoration: decoration,
            child: DefaultTextStyle(
              style: textStyle ?? const TextStyle(),
              child: displayChild,
            ),
          ),
        );
      },
    );
  }
}
